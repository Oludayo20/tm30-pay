import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/transaction.dart';
import 'transaction_formatting.dart';

/// One transaction row. The date is already in the day header, so the row
/// shows only the time. The status is only spelled out when it needs
/// attention (pending or failed): showing "Successful" on almost every row
/// would just be noise.
class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.transaction, this.onTap});

  final Transaction transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final t = transaction;
    final accent = t.isCredit ? context.statusColors.success : scheme.primary;
    final failed = t.status == TransactionStatus.failed;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(t.icon, size: 22, color: accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text.rich(
                    TextSpan(
                      text: t.time,
                      children: [
                        if (t.status != TransactionStatus.success)
                          TextSpan(
                            text: '  ·  ${t.status.label}',
                            style: TextStyle(
                              color: t.status.color(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              t.formattedAmount,
              // One step smaller than the title, so long names aren't cut
              // short by the amount.
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: t.isCredit ? context.statusColors.success : null,
                // A failed payment never moved money, so its amount is
                // crossed out.
                decoration: failed ? TextDecoration.lineThrough : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
