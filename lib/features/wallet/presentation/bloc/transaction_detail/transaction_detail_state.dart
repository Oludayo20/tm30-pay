part of 'transaction_detail_bloc.dart';

enum TransactionDetailStatus { loading, ready, failure }

final class TransactionDetailState extends Equatable {
  const TransactionDetailState({
    this.status = TransactionDetailStatus.loading,
    this.transaction,
    this.failure,
  });

  final TransactionDetailStatus status;
  final Transaction? transaction;
  final Failure? failure;

  @override
  List<Object?> get props => [status, transaction, failure];
}
