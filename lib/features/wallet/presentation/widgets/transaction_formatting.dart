import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../../domain/transaction.dart';

// Display helpers shared by the list tile and the detail screen, so both
// show a transaction the same way.

final DateFormat _time = DateFormat('h:mm a');
final DateFormat _shortDate = DateFormat('d MMM yyyy, h:mm a');
final DateFormat _longDate = DateFormat('EEEE, d MMMM yyyy · h:mm a');

extension TransactionDisplay on Transaction {
  String get formattedAmount =>
      '${isCredit ? '+' : '−'}${Money.format(amount)}';
  String get time => _time.format(createdAt);
  String get shortDate => _shortDate.format(createdAt);
  String get longDate => _longDate.format(createdAt);

  /// An icon that hints at the category. It's based on the title because
  /// the fake backend has no category field; a real API would return one.
  IconData get icon {
    final t = title.toLowerCase();
    if (t.contains('salary')) return Icons.work_outline_rounded;
    if (t.contains('refund')) return Icons.replay_rounded;
    if (t.contains('airtime')) return Icons.phone_iphone_rounded;
    if (t.contains('electric')) return Icons.bolt_rounded;
    if (t.contains('dstv') || t.contains('spotify')) {
      return Icons.subscriptions_outlined;
    }
    if (t.contains('uber')) return Icons.directions_car_outlined;
    if (t.contains('chicken') || t.contains('food')) {
      return Icons.restaurant_rounded;
    }
    if (t.contains('jumia')) return Icons.shopping_bag_outlined;
    return isCredit ? Icons.south_west_rounded : Icons.north_east_rounded;
  }
}

extension TransactionStatusDisplay on TransactionStatus {
  String get label => switch (this) {
    TransactionStatus.success => 'Successful',
    TransactionStatus.pending => 'Pending',
    TransactionStatus.failed => 'Failed',
  };

  Color color(BuildContext context) {
    final colors = context.statusColors;
    return switch (this) {
      TransactionStatus.success => colors.success,
      TransactionStatus.pending => colors.pending,
      TransactionStatus.failed => colors.failed,
    };
  }
}
