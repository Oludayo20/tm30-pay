import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../core/theme/brand.dart';

/// The brand moment at launch: the logo settles in, then the router takes
/// over. It asks for home and lets the redirect decide, so a signed-in user
/// goes to the wallet and everyone else to the welcome screen.
///
/// While it shows, it also decodes the welcome screen's artwork, so that
/// screen appears complete instead of filling in.
class SplashPage extends StatefulWidget {
  const SplashPage({
    super.key,
    this.duration = const Duration(milliseconds: 1600),
  });

  final Duration duration;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();
  Timer? _timer;
  bool _precached = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.duration, () {
      if (mounted) context.go(AppRoutes.home);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precached) return;
    _precached = true;
    for (final asset in const [
      BrandAssets.ellipseTeal,
      BrandAssets.ellipseIndigo,
      BrandAssets.ellipsePurple,
      BrandAssets.logoWhite,
    ]) {
      precacheImage(AssetImage(asset), context);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: _intro, curve: Curves.easeOutCubic);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: FadeTransition(
            opacity: curve,
            child: ScaleTransition(
              scale: Tween(begin: 0.92, end: 1.0).animate(curve),
              child: Semantics(
                label: 'Tm30 Pay',
                image: true,
                child: Image.asset(BrandAssets.logo, width: 100),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
