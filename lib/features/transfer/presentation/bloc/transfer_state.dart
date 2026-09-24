part of 'transfer_bloc.dart';

enum TransferStatus { editing, confirming, submitting, success, failure }

final class TransferState extends Equatable {
  const TransferState({
    this.recipientName = '',
    this.accountNumber = '',
    this.amount = '',
    this.note = '',
    this.touched = const {},
    this.submitAttempted = false,
    this.status = TransferStatus.editing,
    this.idempotencyKey,
    this.failure,
    this.receipt,
  });

  final String recipientName;
  final String accountNumber;

  /// Exactly what the user typed, such as "1,500.50". It is parsed only
  /// when the request is built.
  final String amount;
  final String note;
  final Set<TransferField> touched;
  final bool submitAttempted;
  final TransferStatus status;
  final String? idempotencyKey;
  final Failure? failure;
  final TransferReceipt? receipt;

  RecipientNameError? get recipientNameError =>
      TransferValidators.recipientName(recipientName);
  AccountNumberError? get accountNumberError =>
      TransferValidators.accountNumber(accountNumber);
  AmountError? get amountError => TransferValidators.amount(amount);
  NoteError? get noteError => TransferValidators.note(note);

  bool get isValid =>
      recipientNameError == null &&
      accountNumberError == null &&
      amountError == null &&
      noteError == null;

  /// True while the form must not change: during submission and after
  /// success.
  bool get isLocked =>
      status == TransferStatus.submitting || status == TransferStatus.success;

  /// The amount in kobo. Only call this when [isValid] is true.
  int get amountInMinorUnits => Money.tryParse(amount)!;

  /// Errors are shown for a field once the user has left it, or for every
  /// field once the user has tapped Continue.
  bool showsErrorFor(TransferField field) =>
      submitAttempted || touched.contains(field);

  TransferRequest toRequest() => TransferRequest(
    recipientName: recipientName.trim(),
    accountNumber: accountNumber,
    amount: amountInMinorUnits,
    note: note.trim().isEmpty ? null : note.trim(),
    idempotencyKey: idempotencyKey!,
  );

  /// Returns a copy with one field changed. Also discards the idempotency
  /// key and any failure, because the edited form is a new transfer.
  TransferState withField(TransferField field, String value) {
    return TransferState(
      recipientName: field == TransferField.recipientName
          ? value
          : recipientName,
      accountNumber: field == TransferField.accountNumber
          ? value
          : accountNumber,
      amount: field == TransferField.amount ? value : amount,
      note: field == TransferField.note ? value : note,
      touched: touched,
      submitAttempted: submitAttempted,
    );
  }

  TransferState copyWith({
    Set<TransferField>? touched,
    bool? submitAttempted,
    TransferStatus? status,
    String? idempotencyKey,
    Failure? failure,
    TransferReceipt? receipt,
  }) {
    final nextStatus = status ?? this.status;
    return TransferState(
      recipientName: recipientName,
      accountNumber: accountNumber,
      amount: amount,
      note: note,
      touched: touched ?? this.touched,
      submitAttempted: submitAttempted ?? this.submitAttempted,
      status: nextStatus,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      failure: nextStatus == TransferStatus.failure
          ? (failure ?? this.failure)
          : null,
      receipt: receipt ?? this.receipt,
    );
  }

  @override
  List<Object?> get props => [
    recipientName,
    accountNumber,
    amount,
    note,
    touched,
    submitAttempted,
    status,
    idempotencyKey,
    failure,
    receipt,
  ];
}
