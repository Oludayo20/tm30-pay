import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/copy_to_clipboard.dart';

/// The main card on the home screen: balance, a hide/show toggle, the
/// wallet account number and when the data was last updated.
class BalanceCard extends StatefulWidget {
  const BalanceCard({
    super.key,
    required this.balance,
    this.accountNumber,
    this.asOf,
  });

  /// In kobo. Null while the first load is still running.
  final int? balance;
  final String? accountNumber;
  final DateTime? asOf;

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  // Hiding the balance (for example on a crowded bus) is a display choice,
  // so it stays in the widget.
  bool _hidden = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = isDark
        ? const [Color(0xFF1B4ED8), Color(0xFF0A1F66)]
        : const [AppTheme.tm30Blue, Color(0xFF0038B8)];

    final balanceText = switch ((widget.balance, _hidden)) {
      (null, _) => '₦ ——',
      (_, true) => '₦ • • • • • •',
      (final b?, false) => Money.format(b),
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        child: Stack(
          children: [
            // Soft circles give the flat gradient some depth.
            const Positioned(right: -60, top: -70, child: _Circle(200)),
            const Positioned(right: 40, bottom: -90, child: _Circle(160)),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 12, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Available balance',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        key: const Key('balance_toggleVisibility'),
                        tooltip: _hidden ? 'Show balance' : 'Hide balance',
                        color: Colors.white,
                        onPressed: () => setState(() => _hidden = !_hidden),
                        icon: Icon(
                          _hidden
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      balanceText,
                      key: ValueKey(balanceText),
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      if (widget.accountNumber != null)
                        _AccountChip(widget.accountNumber!),
                      const Spacer(),
                      if (widget.asOf != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Text(
                            'Updated ${DateFormat('h:mm a').format(widget.asOf!)}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountChip extends StatelessWidget {
  const _AccountChip(this.accountNumber);

  final String accountNumber;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.16),
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () => copyToClipboard(
          context,
          text: accountNumber,
          label: 'Account number',
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                accountNumber,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  letterSpacing: 1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.copy_rounded, size: 14, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle(this.size);

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.07),
      ),
    );
  }
}
