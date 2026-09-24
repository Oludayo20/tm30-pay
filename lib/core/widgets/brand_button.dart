import 'package:flutter/material.dart';

import '../theme/brand.dart';
import 'thin_arrow.dart';

enum BrandButtonVariant {
  /// Blue gradient with a soft glow. The main call to action.
  primary,

  /// White with a blue hairline border. The secondary action.
  outlined,

  /// White on the blue profile screen.
  light,
}

/// The decorative blobs that bleed into the primary button from its edges.
enum BrandButtonAccent {
  none,

  /// Teal and purple arcs in the top-right corner (welcome and form screens).
  corner,

  /// A teal arc top-left and a violet arc bottom-right (OTP screens).
  split,
}

enum BrandButtonTrailing { none, arrow, check }

/// The pill button used across onboarding. The label sits on the left with
/// an arrow on the right, or in the middle when [centered] is true.
class BrandButton extends StatefulWidget {
  const BrandButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = BrandButtonVariant.primary,
    this.accent = BrandButtonAccent.none,
    this.trailing = BrandButtonTrailing.arrow,
    this.centered = false,
    this.loading = false,
    this.muted = false,
  });

  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final BrandButtonVariant variant;
  final BrandButtonAccent accent;
  final BrandButtonTrailing trailing;
  final bool centered;

  /// Shows a spinner in place of the trailing icon and ignores taps, while
  /// keeping the button's colours so the screen doesn't flash.
  final bool loading;

  /// Looks disabled but still takes taps, so a tap on an incomplete form
  /// can point out what's missing instead of doing nothing.
  final bool muted;

  static const double height = 72;
  static const double radius = 28;

  @override
  State<BrandButton> createState() => _BrandButtonState();
}

class _BrandButtonState extends State<BrandButton> {
  static const _ring = Color(0xFF3F8AE2);

  bool _pressed = false;
  bool _focused = false;

  bool get _enabled => widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final variant = widget.variant;
    final radius = BorderRadius.circular(BrandButton.radius);
    final foreground = switch (variant) {
      BrandButtonVariant.primary => Colors.white,
      BrandButtonVariant.outlined => BrandColors.blue,
      BrandButtonVariant.light =>
        _enabled && !widget.muted
            ? BrandColors.blue
            : BrandColors.disabledOnWhite,
    };
    // The light blue ring from the design marks the pressed or focused
    // state of the primary button.
    final showRing =
        variant == BrandButtonVariant.primary && (_pressed || _focused);

    final decoration = BoxDecoration(
      borderRadius: radius,
      gradient: variant == BrandButtonVariant.primary
          ? BrandGradients.primary
          : null,
      color: variant == BrandButtonVariant.primary ? null : Colors.white,
      border: variant == BrandButtonVariant.outlined
          ? Border.all(color: BrandColors.blue)
          : null,
      boxShadow: [
        if (variant == BrandButtonVariant.primary && _enabled)
          const BoxShadow(
            color: BrandColors.buttonShadow,
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        BoxShadow(
          color: showRing ? _ring : _ring.withValues(alpha: 0),
          spreadRadius: showRing ? 3 : 0,
        ),
      ],
    );

    return AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity:
            variant == BrandButtonVariant.light || (_enabled && !widget.muted)
            ? 1
            : 0.55,
        duration: const Duration(milliseconds: 200),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: BrandButton.height,
          decoration: decoration,
          child: ClipRRect(
            borderRadius: radius,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (variant == BrandButtonVariant.primary &&
                    widget.accent != BrandButtonAccent.none)
                  CustomPaint(painter: _AccentPainter(widget.accent)),
                Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: widget.loading ? null : widget.onPressed,
                    onHighlightChanged: (v) => setState(() => _pressed = v),
                    onFocusChange: (v) => setState(() => _focused = v),
                    borderRadius: radius,
                    splashColor: foreground.withValues(alpha: 0.12),
                    highlightColor: Colors.transparent,
                    child: _content(foreground),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(Color foreground) {
    final label = Text(
      widget.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: BrandText.button.copyWith(
        color: foreground,
        fontSize: widget.variant == BrandButtonVariant.light ? 21 : null,
      ),
    );
    final trailing = _trailing(foreground);

    if (widget.centered) {
      return Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: label),
            if (trailing != null) ...[const SizedBox(width: 10), trailing],
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(child: label),
          ?trailing,
        ],
      ),
    );
  }

  Widget? _trailing(Color foreground) {
    if (widget.loading) {
      return SizedBox.square(
        dimension: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
      );
    }
    return switch (widget.trailing) {
      BrandButtonTrailing.none => null,
      BrandButtonTrailing.arrow => ThinArrow(
        size: const Size(20, 14),
        color: widget.variant == BrandButtonVariant.primary
            ? Colors.white.withValues(alpha: 0.85)
            : BrandColors.blue.withValues(alpha: 0.45),
      ),
      BrandButtonTrailing.check => Icon(
        Icons.check_rounded,
        size: 22,
        color: foreground,
      ),
    };
  }
}

class _AccentPainter extends CustomPainter {
  const _AccentPainter(this.accent);

  final BrandButtonAccent accent;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    switch (accent) {
      case BrandButtonAccent.none:
        return;
      case BrandButtonAccent.corner:
        _circle(canvas, Offset(w + 15, -40), 88, const [
          Color(0xFF6AA5E0),
          Color(0xFF73D2D8),
        ]);
        _circle(canvas, Offset(w + 30, -20), 70, const [
          Color(0xFFC77BFB),
          Color(0xFFA95CF6),
        ]);
      case BrandButtonAccent.split:
        _circle(canvas, const Offset(10, -50), 80, const [
          Color(0xFF6FC0DC),
          Color(0xFF76DAD5),
        ]);
        final oval = Rect.fromCenter(
          center: Offset(w - 40, h + 40),
          width: 140,
          height: 160,
        );
        canvas.drawOval(
          oval,
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFA35BF7), Color(0xFF8C6CF5)],
            ).createShader(oval),
        );
    }
  }

  void _circle(Canvas canvas, Offset c, double r, List<Color> colors) {
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_AccentPainter old) => old.accent != accent;
}
