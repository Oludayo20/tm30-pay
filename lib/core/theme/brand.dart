import 'package:flutter/widgets.dart';

/// The "Money" brand used by the onboarding and auth screens. Every value
/// here was sampled from the design file, so screens should use these
/// tokens instead of writing colours inline.
abstract final class BrandColors {
  /// Links, outlined buttons, focused underlines and text on white buttons.
  static const blue = Color(0xFF2D42F3);

  /// The two ends of the primary button and the profile screen background.
  static const gradientStart = Color(0xFF454DF1);
  static const gradientEnd = Color(0xFF1E33F5);

  static const teal = Color(0xFF73D2D8);
  static const sky = Color(0xFF6DCBEE);
  static const purple = Color(0xFFBD4CF2);
  static const violet = Color(0xFF9F62F6);

  /// Headings, body copy and entered text.
  static const ink = Color(0xFF3A3A3A);

  /// Labels at rest, hints and inactive underlines.
  static const muted = Color(0xFFB9B9B9);
  static const hairline = Color(0xFFDADDE8);

  static const error = Color(0xFFE94136);

  /// Error text on the blue profile screen, where [error] has too little
  /// contrast.
  static const errorOnBlue = Color(0xFFFFC2BD);

  /// The disabled label of the white button on the profile screen.
  static const disabledOnWhite = Color(0xFFC8C8C8);

  /// The soft blue glow under primary buttons.
  static const buttonShadow = Color(0x402D42F3);
}

abstract final class BrandGradients {
  static const primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [BrandColors.gradientStart, BrandColors.gradientEnd],
  );

  static const background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF464DF0), Color(0xFF2338F4)],
  );

  static const tealBlob = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF6AADDD), Color(0xFF76DAD5)],
  );

  static const purpleBlob = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFC77BFB), Color(0xFFA95CF6)],
  );
}

abstract final class BrandAssets {
  static const logo = 'assets/images/main-logo.png';
  static const logoWhite = 'assets/images/logo-white.png';
  static const ellipseTeal = 'assets/images/ellipse-1.png';
  static const ellipseIndigo = 'assets/images/ellipse-2.png';
  static const ellipsePurple = 'assets/images/ellipse-3.png';
  static const otpIllustration = 'assets/images/phone-image.png';
  static const photoPlaceholder = 'assets/images/registration-profile-img.png';
}

/// The font the whole app uses. Bundled in assets/fonts so it works offline.
const String kBrandFontFamily = 'Montserrat';

/// The type scale of the auth screens. Sizes were solved from the design's
/// measured text widths, so they reproduce its line lengths exactly.
abstract final class BrandText {
  static const _base = TextStyle(
    fontFamily: kBrandFontFamily,
    color: BrandColors.ink,
    letterSpacing: 0,
  );

  /// "Welcome Back" on the brand header.
  static final display = _base.copyWith(
    fontSize: 27,
    fontWeight: FontWeight.w400,
    height: 1.24,
    color: const Color(0xFFFFFFFF),
  );

  /// "Sign in" / "Sign up" above the form.
  static final title = _base.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  /// "OTP Verification".
  static final heading = _base.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static final body = _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.53,
  );

  static final button = _base.copyWith(
    fontSize: 19,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );

  static final label = _base.copyWith(
    fontSize: 14.5,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );

  static final input = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static final caption = _base.copyWith(
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );

  static final link = _base.copyWith(
    fontSize: 15.5,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: BrandColors.blue,
  );
}
