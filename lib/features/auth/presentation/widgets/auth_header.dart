import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../../../core/theme/brand.dart';

/// The layered teal, indigo and purple circles with the logo and
/// "Welcome Back" that top the welcome, sign-in and sign-up screens.
///
/// On the welcome screen the circles fill the top two thirds ([collapsed]
/// false). On the forms they shrink into a compact header ([collapsed]
/// true). Both screens use the same [Hero], so moving between them morphs
/// one composition into the other instead of cutting.
///
/// The expanded state draws the supplied PNGs. Each PNG is a crop of a
/// circle of radius ~412 (fitted to within half a pixel), which the
/// collapsed state doesn't show, so the collapsed state and the morph draw
/// those same circles as vectors. At the start of the morph the vectors
/// line up exactly with the PNGs, so the handover can't be seen.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.collapsed});

  final bool collapsed;

  /// The design frame. All geometry below is in its units.
  static const Size designFrame = Size(375, 812);

  /// Tall enough for the expanded circles. Both states use the same box,
  /// so the Hero only morphs what's inside it.
  static const double designHeight = 540;

  /// Design units to logical pixels. Follows the width on phones, but never
  /// grows faster than the height, so a landscape phone or a tablet keeps
  /// the header in proportion instead of filling the screen with it.
  static double scaleFor(Size screen) {
    final byWidth = screen.width / designFrame.width;
    final byHeight = screen.height / designFrame.height;
    return byWidth < byHeight ? byWidth : byHeight;
  }

  static double heightFor(Size screen) => designHeight * scaleFor(screen);

  static const _heroTag = 'auth-header';

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: _heroTag,
      transitionOnUserGestures: true,
      flightShuttleBuilder: (context, animation, direction, from, to) {
        final fromT = _tOf(from.widget);
        final toT = _tOf(to.widget);
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        );
        return AnimatedBuilder(
          animation: curved,
          builder: (context, _) {
            // On pop the animation runs from 1 back to 0, and "from" is the
            // page being popped.
            final t = direction == HeroFlightDirection.push
                ? lerpDouble(fromT, toT, curved.value)!
                : lerpDouble(toT, fromT, curved.value)!;
            return _HeaderContent(t: t);
          },
        );
      },
      child: _HeaderContent(t: collapsed ? 1 : 0),
    );
  }

  static double _tOf(Widget hero) => ((hero as Hero).child as _HeaderContent).t;
}

class _HeaderContent extends StatelessWidget {
  const _HeaderContent({required this.t});

  /// 0 is the welcome composition, 1 the collapsed one.
  final double t;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final scale = AuthHeader.scaleFor(MediaQuery.sizeOf(context));
    return ExcludeSemantics(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: t == 0
                ? _ExpandedArt(scale: scale)
                : CustomPaint(
                    painter: _CirclesPainter(t: t, scale: scale),
                  ),
          ),
          // The design frame has a 44pt status bar; keep the logo and
          // the greeting the same distance below the real one.
          Positioned(
            left: 52,
            top: topInset + 22,
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(BrandAssets.logoWhite, width: 60, height: 59),
                  const SizedBox(height: 15),
                  Text('Welcome\nBack', style: BrandText.display),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The welcome composition, drawn from the supplied assets. The design
/// places them 4-5pt lower, hidden behind its status bar; here they sit
/// flush with the top and right edges so no white sliver shows on a real
/// device.
class _ExpandedArt extends StatelessWidget {
  const _ExpandedArt({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    Widget place(String asset, Rect r) => Positioned(
      left: r.left * scale,
      top: r.top * scale,
      width: r.width * scale,
      height: r.height * scale,
      child: Image.asset(
        asset,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.medium,
        gaplessPlayback: true,
      ),
    );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        place(BrandAssets.ellipsePurple, _Blob.purple.$1.shaderRect),
        place(BrandAssets.ellipseIndigo, _Blob.indigo.$1.shaderRect),
        place(BrandAssets.ellipseTeal, _Blob.teal.$1.shaderRect),
      ],
    );
  }
}

/// One circle and its gradient, in design units.
class _Blob {
  const _Blob({
    required this.center,
    required this.radius,
    required this.shaderRect,
    required this.colors,
    required this.begin,
    required this.end,
  });

  /// A circle whose gradient spans its own bounding box.
  _Blob.circle({
    required this.center,
    required this.radius,
    required this.colors,
    required this.begin,
    required this.end,
  }) : shaderRect = Rect.fromCircle(center: center, radius: radius);

  final Offset center;
  final double radius;
  final Rect shaderRect;
  final List<Color> colors;
  final Alignment begin;
  final Alignment end;

  /// (expanded, collapsed). Expanded values are the PNGs' fitted circles
  /// and their own gradient stops; the PNG rect is also where each image
  /// is drawn.
  static final teal = (
    const _Blob(
      center: Offset(-112.5, 21.6),
      radius: 411.5,
      shaderRect: Rect.fromLTWH(0, 0, 300, 435),
      colors: [Color(0xFF53ABE3), Color(0xFF47DED5)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    _Blob.circle(
      center: const Offset(100.8, 93.9),
      radius: 176.6,
      colors: const [Color(0xFF4E88E6), Color(0xFF48DCD6)],
      begin: const Alignment(-0.6, -1),
      end: const Alignment(0.6, 1),
    ),
  );

  // The indigo asset is translucent (alpha 124 to 222), which is what makes
  // it read as lavender where it overlaps white.
  static final indigo = (
    const _Blob(
      center: Offset(-81.6, 113.6),
      radius: 411.8,
      shaderRect: Rect.fromLTWH(-2, 0, 333, 527),
      colors: [Color(0x7C7D42F9), Color(0xDE4352F9)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    _Blob.circle(
      center: const Offset(132, 123),
      radius: 176,
      colors: const [Color(0x7C7D42F9), Color(0xDE4352F9)],
      begin: const Alignment(-1, 0.4),
      end: const Alignment(1, -0.2),
    ),
  );

  static final purple = (
    const _Blob(
      center: Offset(39.3, 43.8),
      radius: 412.3,
      shaderRect: Rect.fromLTWH(0, 0, 375, 457),
      colors: [Color(0xFFCC77FF), Color(0xFFCA5EFC)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    _Blob.circle(
      center: const Offset(162, 70),
      radius: 177,
      colors: const [Color(0xFFCC77FF), Color(0xFFCA5EFC)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
  );

  static _Blob lerp((_Blob, _Blob) pair, double t) {
    final (a, b) = pair;
    return _Blob(
      center: Offset.lerp(a.center, b.center, t)!,
      radius: lerpDouble(a.radius, b.radius, t)!,
      shaderRect: Rect.lerp(a.shaderRect, b.shaderRect, t)!,
      colors: [
        for (var i = 0; i < a.colors.length; i++)
          Color.lerp(a.colors[i], b.colors[i], t)!,
      ],
      begin: Alignment.lerp(a.begin, b.begin, t)!,
      end: Alignment.lerp(a.end, b.end, t)!,
    );
  }
}

class _CirclesPainter extends CustomPainter {
  _CirclesPainter({required this.t, required this.scale});

  final double t;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(scale);
    // Back to front, as in the design.
    for (final pair in [_Blob.purple, _Blob.indigo, _Blob.teal]) {
      final blob = _Blob.lerp(pair, t);
      canvas.drawCircle(
        blob.center,
        blob.radius,
        Paint()
          ..shader = LinearGradient(
            begin: blob.begin,
            end: blob.end,
            colors: blob.colors,
          ).createShader(blob.shaderRect),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CirclesPainter old) => old.t != t || old.scale != scale;
}
