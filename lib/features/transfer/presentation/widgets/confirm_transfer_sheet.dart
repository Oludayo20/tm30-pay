import 'package:flutter/material.dart';

import '../../../../core/utils/money.dart';
import '../bloc/transfer_bloc.dart';

/// The confirmation step. Returns true if the user confirms the transfer.
Future<bool> showConfirmTransferSheet(
  BuildContext context,
  TransferState state,
) async {
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => _ConfirmTransferSheet(state),
  );
  return confirmed ?? false;
}

class _ConfirmTransferSheet extends StatelessWidget {
  const _ConfirmTransferSheet(this.state);

  final TransferState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final note = state.note.trim();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Confirm transfer', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Check the details. Transfers cannot be reversed.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              Money.format(state.amountInMinorUnits),
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            _SummaryRow('To', state.recipientName.trim()),
            _SummaryRow('Account number', state.accountNumber),
            if (note.isNotEmpty) _SummaryRow('Note', note),
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('transfer_confirm'),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm and send'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Edit details'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
