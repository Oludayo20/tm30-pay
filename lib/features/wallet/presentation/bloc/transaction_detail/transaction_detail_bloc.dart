import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/error/failure.dart';
import '../../../../../core/error/result.dart';
import '../../../domain/transaction.dart';
import '../../../domain/wallet_repository.dart';

part 'transaction_detail_event.dart';
part 'transaction_detail_state.dart';

/// Loads a single transaction. If the user tapped a row, the transaction is
/// already known, so the bloc starts in the ready state and makes no request.
/// If the app was opened from a deep link, the bloc fetches the transaction
/// by its id.
class TransactionDetailBloc
    extends Bloc<TransactionDetailEvent, TransactionDetailState> {
  TransactionDetailBloc({
    required this._repository,
    required this.transactionId,
    Transaction? initial,
  }) : super(
         initial == null
             ? const TransactionDetailState()
             : TransactionDetailState(
                 status: TransactionDetailStatus.ready,
                 transaction: initial,
               ),
       ) {
    on<TransactionDetailRequested>(_onRequested, transformer: droppable());
  }

  final WalletRepository _repository;
  final String transactionId;

  Future<void> _onRequested(
    TransactionDetailRequested event,
    Emitter<TransactionDetailState> emit,
  ) async {
    if (state.status == TransactionDetailStatus.ready) return;
    emit(const TransactionDetailState(status: TransactionDetailStatus.loading));
    final result = await _repository.getTransaction(transactionId);
    emit(switch (result) {
      Ok(value: final transaction) => TransactionDetailState(
        status: TransactionDetailStatus.ready,
        transaction: transaction,
      ),
      Err(:final failure) => TransactionDetailState(
        status: TransactionDetailStatus.failure,
        failure: failure,
      ),
    });
  }
}
