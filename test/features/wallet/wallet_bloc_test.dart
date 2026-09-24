import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tm30_pay/core/error/failure.dart';
import 'package:tm30_pay/core/error/result.dart';
import 'package:tm30_pay/features/wallet/domain/transaction_page.dart';
import 'package:tm30_pay/features/wallet/domain/transfer.dart';
import 'package:tm30_pay/features/wallet/domain/wallet_snapshot.dart';
import 'package:tm30_pay/features/wallet/presentation/bloc/wallet/wallet_bloc.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockWalletRepository repository;
  late StreamController<TransferReceipt> transfers;

  setUp(() {
    repository = MockWalletRepository();
    transfers = StreamController<TransferReceipt>.broadcast();
    when(() => repository.completedTransfers)
        .thenAnswer((_) => transfers.stream);
    when(() => repository.readCachedSnapshot()).thenAnswer((_) async => null);
  });

  tearDown(() => transfers.close());

  WalletBloc build() => WalletBloc(repository: repository);

  /// A WalletState with a first page already loaded from the network.
  WalletState loaded({String? nextCursor = 'txn_0019'}) =>
      const WalletState().withSnapshot(
        snapshot(nextCursor: nextCursor),
        isFromCache: false,
        status: WalletStatus.ready,
      );

  group('WalletStarted', () {
    final cached = snapshot(balance: 100, transactions: txs(0, 3));
    final fresh = snapshot(balance: 200, transactions: txs(0, 20));

    blocTest<WalletBloc, WalletState>(
      'shows the cached snapshot instantly, then replaces it with fresh data',
      setUp: () {
        when(() => repository.readCachedSnapshot())
            .thenAnswer((_) async => cached);
        when(() => repository.fetchOverview())
            .thenAnswer((_) async => Ok(fresh));
      },
      build: build,
      act: (bloc) => bloc.add(const WalletStarted()),
      expect: () => [
        isA<WalletState>()
            .having((s) => s.status, 'status', WalletStatus.loading)
            .having((s) => s.hasData, 'hasData', false),
        isA<WalletState>()
            .having((s) => s.balance, 'balance', 100)
            .having((s) => s.isFromCache, 'isFromCache', true)
            .having((s) => s.status, 'status', WalletStatus.loading),
        isA<WalletState>()
            .having((s) => s.balance, 'balance', 200)
            .having((s) => s.transactions, 'transactions', hasLength(20))
            .having((s) => s.isFromCache, 'isFromCache', false)
            .having((s) => s.status, 'status', WalletStatus.ready),
      ],
    );

    blocTest<WalletBloc, WalletState>(
      'keeps cached data and flags offline when the network fails',
      setUp: () {
        when(() => repository.readCachedSnapshot())
            .thenAnswer((_) async => cached);
        when(() => repository.fetchOverview())
            .thenAnswer((_) async => const Err(NetworkFailure()));
      },
      build: build,
      act: (bloc) => bloc.add(const WalletStarted()),
      skip: 2,
      expect: () => [
        isA<WalletState>()
            .having((s) => s.balance, 'balance', 100)
            .having((s) => s.isOffline, 'isOffline', true),
      ],
    );

    blocTest<WalletBloc, WalletState>(
      'with no cache, a failure leaves no data so the UI shows a full error',
      setUp: () =>
          when(() => repository.fetchOverview())
              .thenAnswer((_) async => const Err(NetworkFailure())),
      build: build,
      act: (bloc) => bloc.add(const WalletStarted()),
      expect: () => [
        isA<WalletState>().having((s) => s.status, 's', WalletStatus.loading),
        isA<WalletState>()
            .having((s) => s.status, 'status', WalletStatus.failure)
            .having((s) => s.hasData, 'hasData', false)
            .having((s) => s.isOffline, 'isOffline', false)
            .having((s) => s.failure, 'failure', isA<NetworkFailure>()),
      ],
    );
  });

  group('WalletNextPageRequested', () {
    blocTest<WalletBloc, WalletState>(
      'appends the next page and advances the cursor',
      setUp: () => when(() => repository.getTransactions(cursor: 'txn_0019'))
          .thenAnswer((_) async => Ok(page(20, 40, nextCursor: 'txn_0039'))),
      build: build,
      seed: loaded,
      act: (bloc) => bloc.add(const WalletNextPageRequested()),
      expect: () => [
        isA<WalletState>().having((s) => s.pageStatus, 'p', PageStatus.loading),
        isA<WalletState>()
            .having((s) => s.transactions, 'transactions', hasLength(40))
            .having((s) => s.nextCursor, 'nextCursor', 'txn_0039')
            .having((s) => s.pageStatus, 'pageStatus', PageStatus.idle),
      ],
    );

    blocTest<WalletBloc, WalletState>(
      'drops rapid duplicate requests while a page is loading',
      setUp: () =>
          when(() => repository.getTransactions(cursor: 'txn_0019'))
              .thenAnswer((_) async => Ok(page(20, 40, nextCursor: null))),
      build: build,
      seed: loaded,
      act: (bloc) => bloc
        ..add(const WalletNextPageRequested())
        ..add(const WalletNextPageRequested())
        ..add(const WalletNextPageRequested()),
      verify: (_) =>
          verify(() => repository.getTransactions(cursor: 'txn_0019'))
              .called(1),
    );

    blocTest<WalletBloc, WalletState>(
      'does nothing once the end of the list is reached',
      build: build,
      seed: () => loaded(nextCursor: null),
      act: (bloc) => bloc.add(const WalletNextPageRequested()),
      expect: () => <WalletState>[],
      verify: (_) => verifyNever(
        () => repository.getTransactions(cursor: any(named: 'cursor')),
      ),
    );

    blocTest<WalletBloc, WalletState>(
      'keeps the list and exposes a retryable page failure',
      setUp: () =>
          when(() => repository.getTransactions(cursor: 'txn_0019'))
              .thenAnswer((_) async => const Err(NetworkFailure())),
      build: build,
      seed: loaded,
      act: (bloc) => bloc.add(const WalletNextPageRequested()),
      skip: 1,
      expect: () => [
        isA<WalletState>()
            .having((s) => s.transactions, 'transactions', hasLength(20))
            .having((s) => s.pageStatus, 'pageStatus', PageStatus.failure)
            .having((s) => s.pageFailure, 'pageFailure', isA<NetworkFailure>()),
      ],
    );

    final slowPage = Completer<Result<TransactionPage>>();
    blocTest<WalletBloc, WalletState>(
      'discards a page that resolves after a refresh replaced the list',
      setUp: () {
        when(() => repository.getTransactions(cursor: 'txn_0039'))
            .thenAnswer((_) => slowPage.future);
        when(() => repository.fetchOverview())
            .thenAnswer((_) async => Ok(snapshot(transactions: txs(0, 20))));
      },
      build: build,
      // Two pages loaded, so the in-flight cursor (txn_0039) differs from
      // the post-refresh cursor (txn_0019).
      seed: () =>
          loaded().copyWith(transactions: txs(0, 40), nextCursor: 'txn_0039'),
      act: (bloc) async {
        bloc.add(const WalletNextPageRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const WalletRefreshRequested());
        await Future<void>.delayed(Duration.zero);
        slowPage.complete(Ok(page(40, 60)));
      },
      verify: (bloc) {
        expect(bloc.state.transactions, hasLength(20));
        expect(bloc.state.nextCursor, 'txn_0019');
        expect(bloc.state.pageStatus, PageStatus.idle);
      },
    );
  });

  blocTest<WalletBloc, WalletState>(
    'a completed transfer updates balance and list without a refresh',
    build: build,
    seed: loaded,
    act: (_) => transfers.add(receipt(newBalance: 123)),
    expect: () => [
      isA<WalletState>()
          .having((s) => s.balance, 'balance', 123)
          .having((s) => s.transactions.first.id, 'first id', 'txn_9999')
          .having((s) => s.transactions, 'transactions', hasLength(21))
          .having((s) => s.nextCursor, 'cursor unchanged', 'txn_0019'),
    ],
    verify: (_) => verifyNever(() => repository.fetchOverview()),
  );

  final slowRefresh = Completer<Result<WalletSnapshot>>();
  blocTest<WalletBloc, WalletState>(
    'refresh ignores a second pull while one is in flight',
    setUp: () =>
        when(() => repository.fetchOverview())
            .thenAnswer((_) => slowRefresh.future),
    build: build,
    seed: loaded,
    act: (bloc) async {
      bloc
        ..add(const WalletRefreshRequested())
        ..add(const WalletRefreshRequested());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const WalletRefreshRequested());
      slowRefresh.complete(Ok(snapshot()));
    },
    verify: (_) => verify(() => repository.fetchOverview()).called(1),
  );
}
