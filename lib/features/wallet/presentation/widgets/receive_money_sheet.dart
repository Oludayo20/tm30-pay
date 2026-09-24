import 'package:flutter/material.dart';
import 'package:tm30_pay/core/widgets/copy_to_clipboard.dart';
import 'package:tm30_pay/features/auth/domain/auth_user.dart';

/// Shows the details someone needs to send money to this wallet.
Future<void> showReceiveMoneySheet(BuildContext context, AuthUser user) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => _ReceiveMoneySheet(user),
  );
}

class _ReceiveMoneySheet extends StatelessWidget {
  const _ReceiveMoneySheet(this.user);

  final AuthUser user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final details = '${user.fullName}\nTm30 Pay\n${user.walletAccountNumber}';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Receive money', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Share these details with the person sending you money.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _Detail('Account name', user.fullName),
                  _Detail('Bank', 'Tm30 Pay'),
                  _Detail(
                    'Account number',
                    user.walletAccountNumber,
                    emphasise: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              key: const Key('receive_copy'),
              onPressed: () async {
                await copyToClipboard(
                  context,
                  text: details,
                  label: 'Account details',
                );
                if (context.mounted) Navigator.pop(context);
              },
              icon: const Icon(Icons.copy_rounded),
              label: const Text('Copy account details'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail(this.label, this.value, {this.emphasise = false});

  final String label;
  final String value;
  final bool emphasise;

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
          const Spacer(),
          Text(
            value,
            style:
                (emphasise
                        ? theme.textTheme.titleMedium
                        : theme.textTheme.bodyMedium)
                    ?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: emphasise ? 1.2 : null,
                    ),
          ),
        ],
      ),
    );
  }
}
