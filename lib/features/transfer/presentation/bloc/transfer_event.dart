part of 'transfer_bloc.dart';

enum TransferField { recipientName, accountNumber, amount, note }

sealed class TransferEvent {
  const TransferEvent();
}

final class TransferFieldChanged extends TransferEvent {
  const TransferFieldChanged(this.field, this.value);
  final TransferField field;
  final String value;
}

/// A field lost focus. From then on its errors are shown.
final class TransferFieldBlurred extends TransferEvent {
  const TransferFieldBlurred(this.field);
  final TransferField field;
}

/// The user tapped Continue. If the form is valid, move to the confirmation
/// step.
final class TransferReviewRequested extends TransferEvent {
  const TransferReviewRequested();
}

final class TransferReviewCancelled extends TransferEvent {
  const TransferReviewCancelled();
}

final class TransferConfirmed extends TransferEvent {
  const TransferConfirmed();
}
