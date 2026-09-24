import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// The row of main actions under the balance card. Only actions that
/// actually work are shown; there are no "coming soon" dead ends.
class QuickActions extends StatelessWidget {
  const QuickActions({
    super.key,
    required this.onSend,
    required this.onReceive,
  });

  final VoidCallback onSend;
  final VoidCallback onReceive;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            key: const Key('wallet_sendMoney'),
            icon: Icons.north_east_rounded,
            label: 'Send',
            filled: true,
            onTap: onSend,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            key: const Key('wallet_receive'),
            icon: Icons.south_west_rounded,
            label: 'Receive',
            onTap: onReceive,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// The main action gets the solid brand blue in both themes, matching the
  /// balance card. The other action stays tonal.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = filled ? AppTheme.tm30Blue : scheme.secondaryContainer;
    final foreground = filled ? Colors.white : scheme.onSecondaryContainer;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foreground, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(color: foreground, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
