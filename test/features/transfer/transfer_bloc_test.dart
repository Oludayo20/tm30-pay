import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tm30_pay/core/error/failure.dart';
import 'package:tm30_pay/core/error/result.dart';
import 'package:tm30_pay/features/transfer/presentation/bloc/transfer_bloc.dart';
import 'package:tm30_pay/features/wallet/domain/transfer.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mocks.dart';

void main() {
  setUpAll(registerFallbacks);

  late MockWalletRepository repository;
  late int keyCounter;

  setUp(() {
    repository = MockWalletRepository();
    keyCounter = 0;
  });

  TransferBloc build() => TransferBloc(
    repository: repository,
    generateId: () => 'key-${++keyCounter}',
  );

  void fillValidForm(TransferBloc bloc) => bloc
    ..add(const TransferFieldChanged(TransferField.recipientName, ' Ada Obi '))
    ..add(const TransferFieldChanged(TransferField.accountNumber, '0123456789'))
    ..add(const TransferFieldChanged(TransferField.amount, '5,000'))
    ..add(const TransferFieldChanged(TransferField.note, ''));

  const confirmingState = TransferState(
    recipientName: 'Ada Obi',
    accountNumber: '0123456789',
    amount: '5000',
    submitAttempted: true,
    status: TransferStatus.confirming,
    idempotencyKey: 'key-1',
  );

  blocTest<TransferBloc, TransferState>(
    'an invalid form reveals errors and never reaches confirmation',
    build: build,
    act: (bloc) => bloc
      ..add(const TransferFieldChanged(TransferField.accountNumber, '123'))
      ..add(const TransferReviewRequested()),
    skip: 1,
    expect: () => [
      isA<TransferState>()
          .having((s) => s.status, 'status', TransferStatus.editing)
          .having((s) => s.submitAttempted, 'submitAttempted', true)
          .having(
            (s) => s.showsErrorFor(TransferField.accountNumber),
            'shows account error',
            true,
          ),
    ],
    verify: (_) => verifyNever(() => repository.sendMoney(any())),
  );

  blocTest<TransferBloc, TransferState>(
    'valid form -> confirming -> submitting -> success with a clean request',
    setUp: () =>
        when(() => repository.sendMoney(any()))
            .thenAnswer((_) async => Ok(receipt())),
    build: build,
    act: (bloc) async {
      fillValidForm(bloc);
      bloc.add(const TransferReviewRequested());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const TransferConfirmed());
    },
    // Three field edits. The empty note equals the initial state, and bloc
    // does not emit a state equal to the current one.
    skip: 3,
    expect: () => [
      isA<TransferState>()
          .having((s) => s.status, 'status', TransferStatus.confirming)
          .having((s) => s.idempotencyKey, 'key', 'key-1'),
      isA<TransferState>().having(
        (s) => s.status,
        's',
        TransferStatus.submitting,
      ),
      isA<TransferState>()
          .having((s) => s.status, 'status', TransferStatus.success)
          .having((s) => s.receipt, 'receipt', receipt()),
    ],
    verify: (_) => verify(
      () => repository.sendMoney(
        const TransferRequest(
          recipientName: 'Ada Obi',
          accountNumber: '0123456789',
          amount: 500000,
          idempotencyKey: 'key-1',
        ),
      ),
    ).called(1),
  );

  final pending = Completer<Result<TransferReceipt>>();
  blocTest<TransferBloc, TransferState>(
    'prevents double submission: repeated confirms send exactly one request',
    setUp: () =>
        when(() => repository.sendMoney(any()))
            .thenAnswer((_) => pending.future),
    build: build,
    seed: () => confirmingState,
    act: (bloc) async {
      bloc
        ..add(const TransferConfirmed())
        ..add(const TransferConfirmed())
        ..add(const TransferConfirmed());
      await Future<void>.delayed(Duration.zero);
      // A late tap after the first submit settles is also ignored, because
      // the status is no longer "confirming".
      pending.complete(Ok(receipt()));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const TransferConfirmed());
    },
    verify: (bloc) {
      verify(() => repository.sendMoney(any())).called(1);
      expect(bloc.state.status, TransferStatus.success);
    },
  );

  blocTest<TransferBloc, TransferState>(
    'insufficient funds surfaces a typed failure and allows a retry',
    setUp: () =>
        when(() => repository.sendMoney(any()))
            .thenAnswer((_) async => const Err(InsufficientFundsFailure())),
    build: build,
    seed: () => confirmingState,
    act: (bloc) => bloc.add(const TransferConfirmed()),
    expect: () => [
      isA<TransferState>().having(
        (s) => s.status,
        's',
        TransferStatus.submitting,
      ),
      isA<TransferState>()
          .having((s) => s.status, 'status', TransferStatus.failure)
          .having((s) => s.failure, 'failure', isA<InsufficientFundsFailure>())
          .having((s) => s.isLocked, 'form unlocked', false),
    ],
  );

  group('idempotency key', () {
    blocTest<TransferBloc, TransferState>(
      'is reused when retrying the same transfer after a failure',
      build: build,
      seed: () => confirmingState.copyWith(
        status: TransferStatus.failure,
        failure: const NetworkFailure(),
      ),
      act: (bloc) => bloc.add(const TransferReviewRequested()),
      expect: () => [
        isA<TransferState>()
            .having((s) => s.status, 'status', TransferStatus.confirming)
            .having((s) => s.idempotencyKey, 'key', 'key-1'),
      ],
    );

    blocTest<TransferBloc, TransferState>(
      'is regenerated once the user edits the transfer',
      build: build,
      seed: () => confirmingState.copyWith(status: TransferStatus.failure),
      act: (bloc) => bloc
        ..add(const TransferFieldChanged(TransferField.amount, '6000'))
        ..add(const TransferReviewRequested()),
      verify: (bloc) => expect(bloc.state.idempotencyKey, 'key-1'),
      // key-1 here is freshly generated: the seed's key was discarded by
      // the edit, and keyCounter started at zero.
      expect: () => [
        isA<TransferState>()
            .having((s) => s.idempotencyKey, 'key cleared', isNull)
            .having((s) => s.status, 'status', TransferStatus.editing),
        isA<TransferState>().having(
          (s) => s.status,
          's',
          TransferStatus.confirming,
        ),
      ],
    );
  });
}
