import 'package:flutter/material.dart';

import '../bloc/wallet/wallet_bloc.dart';

/// The last row of the list: a spinner while the next page loads, a retry
/// row if it failed, or an end-of-list message.
class ListFooter extends StatelessWidget {
  const ListFooter({super.key, required this.state, required this.onRetry});

  final WalletState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Widget child = switch (state.pageStatus) {
      PageStatus.loading => const SizedBox.square(
        dimension: 24,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      ),
      PageStatus.failure => TextButton.icon(
        key: const Key('wallet_loadMoreRetry'),
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text("Couldn't load more. Tap to retry"),
      ),
      PageStatus.idle when state.hasReachedEnd => Text(
        "You're all caught up",
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      PageStatus.idle => const SizedBox.shrink(),
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      child: Center(child: child),
    );
  }
}
