part of 'transaction_detail_bloc.dart';

sealed class TransactionDetailEvent {
  const TransactionDetailEvent();
}

/// Load the transaction, or retry after a failure.
final class TransactionDetailRequested extends TransactionDetailEvent {
  const TransactionDetailRequested();
}
