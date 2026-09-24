import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/failure.dart';
import '../bloc/wallet/wallet_bloc.dart';

/// Shows the state of the data on screen: cached data that is being
/// updated, offline, or a failed refresh. Shows nothing when the data is
/// fresh.
class WalletStatusBanner extends StatelessWidget {
  const WalletStatusBanner({
    super.key,
    required this.state,
    required this.onRetry,
  });

  final WalletState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final asOf = state.asOf == null
        ? ''
        : ' Last updated ${DateFormat('d MMM, h:mm a').format(state.asOf!)}.';

    if (state.hasData && state.status == WalletStatus.failure) {
      final offline = state.failure is NetworkFailure;
      return _Banner(
        key: const Key('wallet_offlineBanner'),
        icon: offline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
        text: offline
            ? "You're offline.$asOf"
            : "Couldn't refresh your wallet.$asOf",
        background: scheme.errorContainer,
        foreground: scheme.onErrorContainer,
        action: TextButton(onPressed: onRetry, child: const Text('Retry')),
      );
    }

    if (state.isFromCache && state.status == WalletStatus.loading) {
      return _Banner(
        icon: Icons.sync_rounded,
        text: 'Updating…',
        background: scheme.secondaryContainer,
        foreground: scheme.onSecondaryContainer,
        action: const Padding(
          padding: EdgeInsets.all(12),
          child: SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    super.key,
    required this.icon,
    required this.text,
    required this.background,
    required this.foreground,
    required this.action,
  });

  final IconData icon;
  final String text;
  final Color background;
  final Color foreground;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: foreground),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: foreground),
              ),
            ),
            action,
          ],
        ),
      ),
    );
  }
}
