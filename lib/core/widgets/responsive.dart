import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Content never gets wider than this, so screens stay readable on tablets
/// and in landscape.
const double kMaxContentWidth = 640;

/// The horizontal padding that centres content of at most [kMaxContentWidth]
/// on a screen [width] wide, with at least [min] on each side.
double horizontalGutter(double width, {double min = 16}) =>
    math.max(min, (width - kMaxContentWidth) / 2);

/// Centres [child] and limits its width to [kMaxContentWidth].
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
