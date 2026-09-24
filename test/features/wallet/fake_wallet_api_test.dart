import 'package:flutter_test/flutter_test.dart';
import 'package:tm30_pay/core/error/exceptions.dart';
import 'package:tm30_pay/core/utils/fake_latency.dart';
import 'package:tm30_pay/features/wallet/data/fake_wallet_api.dart';
import 'package:tm30_pay/features/wallet/domain/transfer.dart';

void main() {
  FakeWalletApi api({double failureRate = 0}) => FakeWalletApi(
    latency: const FakeLatency.none(),
    listFailureRate: failureRate,
  );

  TransferRequest request({int amount = 100000, String key = 'key-1'}) =>
      TransferRequest(
        recipientName: 'Ada Obi',
        accountNumber: '0123456789',
        amount: amount,
        idempotencyKey: key,
      );

  group('cursor pagination', () {
    test('walks 60 seeded items in 3 pages of 20 with no duplicates', () async {
      final fake = api();
      final ids = <String>[];
      String? cursor;
      var pages = 0;
      do {
        final page = await fake.getTransactions(cursor: cursor, limit: 20);
        expect(page.items, hasLength(20));
        ids.addAll(page.items.map((t) => t.id));
        cursor = page.nextCursor;
        pages++;
      } while (cursor != null);

      expect(pages, 3);
      expect(ids.toSet(), hasLength(60));
    });

    test('items are newest first', () async {
      final page = await api().getTransactions(limit: 20);
      final dates = page.items.map((t) => t.createdAt).toList();
      final sorted = [...dates]..sort((a, b) => b.compareTo(a));
      expect(dates, sorted);
    });

    test('a transfer made mid-scroll does not shift the next page', () async {
      // This is the bug that offset pagination has and cursor pagination
      // avoids.
      final fake = api();
      final first = await fake.getTransactions(limit: 20);
      await fake.transfer(request());
      final second = await fake.getTransactions(
        cursor: first.nextCursor,
        limit: 20,
      );
      final firstIds = first.items.map((t) => t.id).toSet();
      expect(second.items.where((t) => firstIds.contains(t.id)), isEmpty);
    });
  });

  test('list requests fail with a NetworkException when the dice say so', () {
    expect(
      api(failureRate: 1).getTransactions(limit: 20),
      throwsA(isA<NetworkException>()),
    );
  });

  group('transfer', () {
    test('debits the balance and prepends the transaction', () async {
      final fake = api();
      final receipt = await fake.transfer(request(amount: 500000));
      expect(receipt.newBalance, 25000000 - 500000);
      final page = await fake.getTransactions(limit: 20);
      expect(page.items.first, receipt.transaction);
    });

    test('rejects amounts above the balance as insufficient funds', () async {
      final fake = api();
      await expectLater(
        fake.transfer(request(amount: 25000001)),
        throwsA(isA<InsufficientFundsException>()),
      );
      expect(await fake.getBalance(), 25000000);
    });

    test('replaying an idempotency key does not move money twice', () async {
      final fake = api();
      final a = await fake.transfer(request(key: 'same'));
      final b = await fake.transfer(request(key: 'same'));
      expect(b, a);
      expect(await fake.getBalance(), 25000000 - 100000);
    });
  });
}
