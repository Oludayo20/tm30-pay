import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/error/failure.dart';
import '../../../../../core/error/result.dart';
import '../../../domain/transaction.dart';
import '../../../domain/transfer.dart';
import '../../../domain/wallet_repository.dart';
import '../../../domain/wallet_snapshot.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

/// Holds the balance and the transaction list.
///
/// Rules for concurrent events:
/// * Refresh and next page use `droppable()`. A pull-to-refresh or scroll
///   event that arrives while the same request is running is ignored, not
///   queued.
/// * A next page that arrives after a refresh has replaced the list is
///   thrown away (see [_onNextPageRequested]).
/// * Completed transfers come from the repository stream, so this bloc never
///   depends on the transfer bloc.
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc({required this._repository}) : super(const WalletState()) {
    on<WalletStarted>(_onStarted, transformer: droppable());
    on<WalletRefreshRequested>(_onRefreshRequested, transformer: droppable());
    on<WalletNextPageRequested>(_onNextPageRequested, transformer: droppable());
    on<_WalletTransferCompleted>(_onTransferCompleted);

    _transferSubscription = _repository.completedTransfers.listen(
      (receipt) => add(_WalletTransferCompleted(receipt)),
    );
  }

  final WalletRepository _repository;
  late final StreamSubscription<TransferReceipt> _transferSubscription;

  Future<void> _onStarted(
    WalletStarted event,
    Emitter<WalletState> emit,
  ) async {
    emit(state.copyWith(status: WalletStatus.loading));

    // Show the saved snapshot straight away, so the screen doesn't flash a
    // spinner on relaunch. A fresh fetch follows.
    final cached = await _repository.readCachedSnapshot();
    if (cached != null) {
      emit(
        state.withSnapshot(
          cached,
          isFromCache: true,
          status: WalletStatus.loading,
        ),
      );
    }

    await _fetchOverview(emit);
  }

  Future<void> _onRefreshRequested(
    WalletRefreshRequested event,
    Emitter<WalletState> emit,
  ) async {
    // The first load is already fetching. Starting a second overview fetch
    // would just race it.
    if (state.status == WalletStatus.loading) return;
    emit(state.copyWith(status: WalletStatus.loading));
    await _fetchOverview(emit);
  }

  Future<void> _fetchOverview(Emitter<WalletState> emit) async {
    final result = await _repository.fetchOverview();
    switch (result) {
      case Ok(value: final snapshot):
        emit(
          state.withSnapshot(
            snapshot,
            isFromCache: false,
            status: WalletStatus.ready,
          ),
        );
      case Err(:final failure):
        // Keep the data already on screen. The failure is shown as an
        // offline banner, or as a full error screen if there's no data.
        emit(state.copyWith(status: WalletStatus.failure, failure: failure));
    }
  }

  Future<void> _onNextPageRequested(
    WalletNextPageRequested event,
    Emitter<WalletState> emit,
  ) async {
    final cursor = state.nextCursor;
    if (cursor == null ||
        !state.hasData ||
        state.status == WalletStatus.loading) {
      return;
    }

    emit(state.copyWith(pageStatus: PageStatus.loading));
    final result = await _repository.getTransactions(cursor: cursor);

    // If a refresh replaced the list while this page was loading, the page
    // belongs to the old list. Drop it rather than append items that may
    // duplicate or skip transactions.
    if (state.nextCursor != cursor) {
      emit(state.copyWith(pageStatus: PageStatus.idle));
      return;
    }

    switch (result) {
      case Ok(value: final page):
        final known = state.transactions.map((t) => t.id).toSet();
        emit(
          state.copyWith(
            transactions: [
              ...state.transactions,
              ...page.items.where((t) => !known.contains(t.id)),
            ],
            nextCursor: page.nextCursor,
            clearNextCursor: page.nextCursor == null,
            pageStatus: PageStatus.idle,
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(pageStatus: PageStatus.failure, pageFailure: failure),
        );
    }
  }

  void _onTransferCompleted(
    _WalletTransferCompleted event,
    Emitter<WalletState> emit,
  ) {
    final transaction = event.receipt.transaction;
    // With no data loaded yet there's nothing to patch. The coming fetch
    // will include the transfer anyway.
    if (!state.hasData) return;
    final alreadyListed = state.transactions.any((t) => t.id == transaction.id);
    emit(
      state.copyWith(
        balance: event.receipt.newBalance,
        transactions: alreadyListed
            ? state.transactions
            : [transaction, ...state.transactions],
      ),
    );
  }

  @override
  Future<void> close() {
    _transferSubscription.cancel();
    return super.close();
  }
}
