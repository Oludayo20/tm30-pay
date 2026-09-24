import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/responsive.dart';
import '../../../wallet/domain/transfer.dart';

class TransferSuccessView extends StatelessWidget {
  const TransferSuccessView({
    super.key,
    required this.receipt,
    required this.recipientName,
    required this.onDone,
  });

  final TransferReceipt receipt;
  final String recipientName;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final success = context.statusColors.success;
    final t = receipt.transaction;

    return ResponsiveCenter(
      padding: const EdgeInsets.all(24),
      child: Column(
        key: const Key('transfer_success'),
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: success.withValues(alpha: 0.12),
            child: Icon(Icons.check_rounded, size: 44, color: success),
          ),
          const SizedBox(height: 24),
          Text(
            'Transfer successful',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${Money.format(t.amount)} sent to '
            '$recipientName '
            '(${t.counterpartyAccount}).',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'New balance: ${Money.format(receipt.newBalance)}',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 40),
          FilledButton(
            key: const Key('transfer_done'),
            onPressed: onDone,
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
