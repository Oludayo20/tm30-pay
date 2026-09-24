import 'package:flutter_test/flutter_test.dart';
import 'package:tm30_pay/features/wallet/presentation/widgets/transaction_groups.dart';

import '../../helpers/fixtures.dart';

void main() {
  test('groups newest-first transactions by day with one header each', () {
    // fixedNow is 12:00. tx(0) to tx(12) fall today, tx(13) to tx(19) fall
    // yesterday.
    final items = groupByDay(txs(0, 20), now: fixedNow);

    final headers = items.whereType<DayHeaderItem>().map((h) => h.label);
    expect(headers, ['Today', 'Yesterday']);
    expect(items.whereType<TransactionItem>(), hasLength(20));

    final rows = items.whereType<TransactionItem>().toList();
    expect(rows.first.isFirstInDay, isTrue);
    expect(rows[12].isLastInDay, isTrue, reason: 'last row of today');
    expect(rows[13].isFirstInDay, isTrue, reason: 'first row of yesterday');
    expect(rows.last.isLastInDay, isTrue);
    expect(rows[5].isFirstInDay || rows[5].isLastInDay, isFalse);
  });

  test('labels older days by weekday, or by year when it differs', () {
    expect(dayLabel(DateTime(2026, 9, 22), now: fixedNow), 'Tue, 22 Sep');
    expect(dayLabel(DateTime(2025, 12, 31), now: fixedNow), '31 Dec 2025');
  });

  test('an empty list has no items', () {
    expect(groupByDay(const [], now: fixedNow), isEmpty);
  });
}
