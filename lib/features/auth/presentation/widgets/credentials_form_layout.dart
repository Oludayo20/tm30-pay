import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/brand.dart';
import 'auth_header.dart';
import 'auth_scroll_view.dart';

/// The shared layout of the sign-in and sign-up forms: the collapsed brand
/// header, a title, the fields and a link, with the submit button pinned to
/// the bottom.
class CredentialsFormLayout extends StatelessWidget {
  const CredentialsFormLayout({
    super.key,
    required this.title,
    required this.fields,
    required this.link,
    required this.submit,
  });

  final String title;
  final List<Widget> fields;
  final Widget link;
  final Widget submit;

  /// Where the title starts, in design units: just below the header art.
  static const double _titleTop = 320;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final scale = AuthHeader.scaleFor(screen);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: AutofillGroup(
          child: AuthScrollView(
            top: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: _titleTop * scale,
                  // The header's box is taller than this slot; its lower part
                  // is empty, and it paints before (under) the form.
                  child: OverflowBox(
                    alignment: Alignment.topCenter,
                    maxHeight: AuthHeader.heightFor(screen),
                    child: const IgnorePointer(
                      child: AuthHeader(collapsed: true),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AuthScrollView.gutter,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(title, style: BrandText.title),
                      ),
                      const SizedBox(height: 45),
                      ...fields,
                      Align(alignment: Alignment.centerLeft, child: link),
                    ],
                  ),
                ),
              ],
            ),
            bottom: submit,
          ),
        ),
      ),
    );
  }
}

/// A text link with a comfortable tap target that still lines up with the
/// text above it.
class InlineLink extends StatelessWidget {
  const InlineLink({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: BrandColors.blue,
        padding: const EdgeInsets.symmetric(vertical: 12),
        minimumSize: const Size(0, 44),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        alignment: Alignment.centerLeft,
        textStyle: BrandText.link,
        overlayColor: BrandColors.blue,
      ),
      child: Text(label),
    );
  }
}
