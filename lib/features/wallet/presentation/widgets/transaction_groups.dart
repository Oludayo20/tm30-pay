import 'package:intl/intl.dart';

import '../../domain/transaction.dart';

/// One row of the grouped transaction list: either a day header or a
/// transaction. The list is flattened like this so SliverList can still
/// build rows lazily.
sealed class TransactionListItem {
  const TransactionListItem();
}

final class DayHeaderItem extends TransactionListItem {
  const DayHeaderItem(this.label);
  final String label;
}

final class TransactionItem extends TransactionListItem {
  const TransactionItem(
    this.transaction, {
    required this.isFirstInDay,
    required this.isLastInDay,
  });

  final Transaction transaction;

  /// Used to round the top and bottom corners of each day's card.
  final bool isFirstInDay;
  final bool isLastInDay;
}

/// Groups [transactions] (newest first) by calendar day, with a header
/// before each day: "Today", "Yesterday", "Mon, 22 Sep", or "22 Sep 2025"
/// for another year.
List<TransactionListItem> groupByDay(
  List<Transaction> transactions, {
  required DateTime now,
}) {
  final items = <TransactionListItem>[];
  for (var i = 0; i < transactions.length; i++) {
    final t = transactions[i];
    final day = _dateOnly(t.createdAt);
    final isFirst = i == 0 || _dateOnly(transactions[i - 1].createdAt) != day;
    final isLast =
        i == transactions.length - 1 ||
        _dateOnly(transactions[i + 1].createdAt) != day;
    if (isFirst) items.add(DayHeaderItem(dayLabel(day, now: now)));
    items.add(TransactionItem(t, isFirstInDay: isFirst, isLastInDay: isLast));
  }
  return items;
}

String dayLabel(DateTime day, {required DateTime now}) {
  final today = _dateOnly(now);
  final date = _dateOnly(day);
  if (date == today) return 'Today';
  if (date == today.subtract(const Duration(days: 1))) return 'Yesterday';
  if (date.year == today.year) return DateFormat('EEE, d MMM').format(date);
  return DateFormat('d MMM yyyy').format(date);
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
