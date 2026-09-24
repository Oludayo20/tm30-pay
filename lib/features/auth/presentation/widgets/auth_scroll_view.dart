import 'package:flutter/material.dart';

/// Fills the screen with [top] at the top and [bottom] (the call to action)
/// pinned to the bottom, as in the design. When the keyboard leaves too
/// little room the whole page scrolls instead, so no field is ever hidden.
///
/// A Column with spaceBetween inside a min-height box gives this without
/// IntrinsicHeight, which the header's LayoutBuilder doesn't support.
class AuthScrollView extends StatelessWidget {
  const AuthScrollView({
    super.key,
    required this.top,
    required this.bottom,
    this.bottomGap = 28,
  });

  final Widget top;
  final Widget bottom;

  /// Space between [bottom] and the home indicator.
  final double bottomGap;

  static const double gutter = 30;

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              top,
              Padding(
                padding: EdgeInsets.fromLTRB(
                  gutter,
                  24,
                  gutter,
                  safeBottom + bottomGap,
                ),
                child: bottom,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
