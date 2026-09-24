import 'package:flutter/material.dart';

/// The sky and purple wave in the top-right corner of the completed
/// profile screen. It slides in once every field is valid, as a quiet
/// "you're done" signal before the user taps Complete.
class ProfileWave extends StatelessWidget {
  const ProfileWave({super.key, required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0.35, -0.35),
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 450),
          child: const CustomPaint(painter: _WavePainter()),
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  const _WavePainter();

  static const _sky = Color(0xFF6DCBEE);
  static const _purple = Color(0xFFA73AEF);

  @override
  void paint(Canvas canvas, Size size) {
    // Traced from the design in 375-wide units. The purple band is the sky
    // edge moved 37 left and 40 down, then closed to the corner.
    final purple = Path()..moveTo(116, 0);
    _edge(purple, const Offset(-37, 40));
    purple
      ..lineTo(375, 238)
      ..lineTo(375, 0)
      ..close();

    final sky = Path()..moveTo(150, 0);
    _edge(sky, Offset.zero);
    sky
      ..lineTo(375, 215)
      ..lineTo(375, 0)
      ..close();

    canvas
      ..save()
      ..scale(size.width / 375)
      ..drawPath(purple, Paint()..color = _purple)
      ..drawPath(sky, Paint()..color = _sky)
      ..restore();
  }

  static void _edge(Path path, Offset s) {
    Offset p(double x, double y) => Offset(x + s.dx, y + s.dy);
    void curve(Offset a, Offset b, Offset c) =>
        path.cubicTo(a.dx, a.dy, b.dx, b.dy, c.dx, c.dy);

    final start = p(150, 0);
    path.lineTo(start.dx, start.dy);
    curve(p(150, 30), p(165, 60), p(190, 76));
    curve(p(215, 92), p(245, 98), p(258, 121));
    curve(p(266, 136), p(266, 165), p(280, 185));
    curve(p(293, 204), p(310, 215), p(335, 215));
  }

  @override
  bool shouldRepaint(_WavePainter old) => false;
}
