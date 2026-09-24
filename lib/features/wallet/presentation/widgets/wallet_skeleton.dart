import 'package:flutter/material.dart';

/// Placeholder rows shaped like the real list, shown during the first load.
/// This feels faster than a centred spinner, and the layout doesn't jump
/// when the data arrives.
class WalletSkeleton extends StatefulWidget {
  const WalletSkeleton({super.key, this.rows = 6});

  final int rows;

  @override
  State<WalletSkeleton> createState() => _WalletSkeletonState();
}

class _WalletSkeletonState extends State<WalletSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    lowerBound: 0.4,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    Widget box(double width, double height, [double radius = 6]) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );

    return Semantics(
      label: 'Loading transactions',
      child: FadeTransition(
        opacity: _pulse,
        child: Column(
          key: const Key('wallet_skeleton'),
          children: [
            for (var i = 0; i < widget.rows; i++)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    box(44, 44, 14),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          box(140, 14),
                          const SizedBox(height: 8),
                          box(70, 10),
                        ],
                      ),
                    ),
                    box(80, 14),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
