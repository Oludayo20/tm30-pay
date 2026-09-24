import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/brand.dart';
import 'auth_scroll_view.dart';

/// The shared layout of the two OTP screens: the phone illustration, the
/// "OTP Verification" heading, a line of explanation, the screen's own
/// input and the action pinned to the bottom.
class OtpLayout extends StatelessWidget {
  const OtpLayout({
    super.key,
    required this.message,
    required this.input,
    required this.action,
  });

  final Widget message;
  final Widget input;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: AuthScrollView(
            bottomGap: 30,
            top: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AuthScrollView.gutter,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 56),
                  const ExcludeSemantics(
                    child: Image(
                      image: AssetImage(BrandAssets.otpIllustration),
                      width: 222,
                      height: 233,
                    ),
                  ),
                  const SizedBox(height: 68),
                  Semantics(
                    header: true,
                    child: Text(
                      'OTP Verification',
                      textAlign: TextAlign.center,
                      style: BrandText.heading,
                    ),
                  ),
                  const SizedBox(height: 25),
                  DefaultTextStyle(
                    style: BrandText.body,
                    textAlign: TextAlign.center,
                    child: message,
                  ),
                  input,
                ],
              ),
            ),
            bottom: action,
          ),
        ),
      ),
    );
  }
}
