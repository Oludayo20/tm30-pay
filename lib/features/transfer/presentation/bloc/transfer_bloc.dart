import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../core/utils/money.dart';
import '../../../wallet/domain/transfer.dart';
import '../../../wallet/domain/wallet_repository.dart';
import '../../domain/transfer_validators.dart';

part 'transfer_event.dart';
part 'transfer_state.dart';

/// Runs the send-money flow: editing, then confirming, then submitting,
/// then success or failure.
///
/// A transfer can't be sent twice. Four separate checks prevent it:
/// 1. `droppable()` ignores any confirm event that arrives while a submit is
///    running.
/// 2. [_onConfirmed] only submits when the status is `confirming`.
/// 3. The UI disables the button while submitting.
/// 4. The request carries an idempotency key, so even a retry after a
///    network failure can only move the money once.
class TransferBloc extends Bloc<TransferEvent, TransferState> {
  TransferBloc({required this._repository, IdGenerator? generateId})
    : _generateId = generateId ?? randomId,
      super(const TransferState()) {
    on<TransferFieldChanged>(_onFieldChanged);
    on<TransferFieldBlurred>(_onFieldBlurred);
    on<TransferReviewRequested>(_onReviewRequested);
    on<TransferReviewCancelled>(_onReviewCancelled);
    on<TransferConfirmed>(_onConfirmed, transformer: droppable());
  }

  final WalletRepository _repository;
  final IdGenerator _generateId;

  void _onFieldChanged(
    TransferFieldChanged event,
    Emitter<TransferState> emit,
  ) {
    if (state.isLocked) return;
    // Changing any field means this is a different transfer, so it needs a
    // new idempotency key.
    emit(state.withField(event.field, event.value));
  }

  void _onFieldBlurred(
    TransferFieldBlurred event,
    Emitter<TransferState> emit,
  ) {
    emit(state.copyWith(touched: {...state.touched, event.field}));
  }

  void _onReviewRequested(
    TransferReviewRequested event,
    Emitter<TransferState> emit,
  ) {
    if (state.isLocked) return;
    if (!state.isValid) {
      emit(state.copyWith(submitAttempted: true));
      return;
    }
    emit(
      state.copyWith(
        submitAttempted: true,
        status: TransferStatus.confirming,
        // Keep the key when retrying the same transfer after a failure.
        idempotencyKey: state.idempotencyKey ?? _generateId(),
      ),
    );
  }

  void _onReviewCancelled(
    TransferReviewCancelled event,
    Emitter<TransferState> emit,
  ) {
    if (state.status != TransferStatus.confirming) return;
    emit(state.copyWith(status: TransferStatus.editing));
  }

  Future<void> _onConfirmed(
    TransferConfirmed event,
    Emitter<TransferState> emit,
  ) async {
    if (state.status != TransferStatus.confirming) return;
    emit(state.copyWith(status: TransferStatus.submitting));

    final result = await _repository.sendMoney(state.toRequest());
    emit(switch (result) {
      Ok(value: final receipt) => state.copyWith(
        status: TransferStatus.success,
        receipt: receipt,
      ),
      Err(:final failure) => state.copyWith(
        status: TransferStatus.failure,
        failure: failure,
      ),
    });
  }
}
