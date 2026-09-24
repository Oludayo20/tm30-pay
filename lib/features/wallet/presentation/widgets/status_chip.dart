import 'package:flutter/material.dart';

import '../../domain/transaction.dart';
import 'transaction_formatting.dart';

class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});

  final TransactionStatus status;

  @override
  Widget build(BuildContext context) {
    final color = status.color(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          status.label,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: color, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
