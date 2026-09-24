import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tm30_pay/core/error/failure.dart';
import 'package:tm30_pay/core/error/result.dart';
import 'package:tm30_pay/core/utils/fake_latency.dart';
import 'package:tm30_pay/features/wallet/data/fake_wallet_api.dart';
import 'package:tm30_pay/features/wallet/data/wallet_repository_impl.dart';
import 'package:tm30_pay/features/wallet/domain/transfer.dart';
import 'package:tm30_pay/features/wallet/domain/wallet_snapshot.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mocks.dart';

void main() {
  setUpAll(registerFallbacks);

  late MockWalletCache cache;

  setUp(() {
    cache = MockWalletCache();
    when(() => cache.write(any())).thenAnswer((_) async {});
    when(() => cache.read()).thenAnswer((_) async => null);
  });

  WalletRepositoryImpl repo({double failureRate = 0}) => WalletRepositoryImpl(
    api: FakeWalletApi(
      latency: const FakeLatency.none(),
      listFailureRate: failureRate,
    ),
    cache: cache,
    clock: () => fixedNow,
  );

  test('fetchOverview returns the first page and writes it to cache', () async {
    final result = await repo().fetchOverview();

    final snapshot = (result as Ok<WalletSnapshot>).value;
    expect(snapshot.balance, 25000000);
    expect(snapshot.transactions, hasLength(20));
    verify(() => cache.write(snapshot)).called(1);
  });

  test(
    'network errors become a typed NetworkFailure and skip the cache',
    () async {
      final result = await repo(failureRate: 1).fetchOverview();

      expect(result, isA<Err<WalletSnapshot>>());
      expect((result as Err).failure, isA<NetworkFailure>());
      verifyNever(() => cache.write(any()));
    },
  );

  test('insufficient funds becomes a typed failure', () async {
    final result = await repo().sendMoney(
      const TransferRequest(
        recipientName: 'Ada',
        accountNumber: '0123456789',
        amount: 99999999999,
        idempotencyKey: 'k',
      ),
    );
    expect((result as Err).failure, isA<InsufficientFundsFailure>());
  });

  test(
    'a successful transfer is broadcast and patched into the cache',
    () async {
      when(() => cache.read()).thenAnswer((_) async => snapshot());
      final repository = repo();
      final broadcast = expectLater(
        repository.completedTransfers,
        emits(isA<TransferReceipt>()),
      );

      await repository.sendMoney(
        const TransferRequest(
          recipientName: 'Ada Obi',
          accountNumber: '0123456789',
          amount: 100000,
          idempotencyKey: 'k',
        ),
      );

      await broadcast;
      final written =
          verify(() => cache.write(captureAny())).captured.single
              as WalletSnapshot;
      expect(written.balance, 25000000 - 100000);
      expect(written.transactions.first.title, 'Transfer to Ada Obi');
      // Still one page: trimmed to 20, with the cursor moved to the new last
      // item.
      expect(written.transactions, hasLength(20));
      expect(written.nextCursor, written.transactions.last.id);
    },
  );
}
