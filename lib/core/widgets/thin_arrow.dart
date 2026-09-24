import 'package:flutter/widgets.dart';

/// The hairline arrow the design uses on buttons and for "back". Material's
/// arrow icons are far heavier, so this is drawn to match.
class ThinArrow extends StatelessWidget {
  const ThinArrow({
    super.key,
    required this.color,
    this.pointsLeft = false,
    this.size = const Size(22, 16),
    this.strokeWidth = 1.4,
  });

  final Color color;
  final bool pointsLeft;
  final Size size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      painter: _ThinArrowPainter(color, pointsLeft, strokeWidth),
    );
  }
}

class _ThinArrowPainter extends CustomPainter {
  _ThinArrowPainter(this.color, this.pointsLeft, this.strokeWidth);

  final Color color;
  final bool pointsLeft;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final inset = strokeWidth / 2;
    final midY = size.height / 2;
    final tip = pointsLeft ? inset : size.width - inset;
    final tail = pointsLeft ? size.width - inset : inset;
    final wing = pointsLeft ? tip + midY - inset : tip - midY + inset;
    canvas
      ..drawLine(Offset(tail, midY), Offset(tip, midY), paint)
      ..drawPath(
        Path()
          ..moveTo(wing, inset)
          ..lineTo(tip, midY)
          ..lineTo(wing, size.height - inset),
        paint,
      );
  }

  @override
  bool shouldRepaint(_ThinArrowPainter old) =>
      old.color != color ||
      old.pointsLeft != pointsLeft ||
      old.strokeWidth != strokeWidth;
}
