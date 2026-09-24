import 'package:flutter/material.dart';

/// A small spinner to show inside a button while its action is running.
/// The button is disabled at that point, so the spinner uses the default
/// primary colour, which shows up on the disabled background.
class ButtonProgress extends StatelessWidget {
  const ButtonProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 22,
      child: CircularProgressIndicator(strokeWidth: 2.5),
    );
  }
}
