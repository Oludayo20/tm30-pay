import 'package:flutter/material.dart';

/// The eye at the end of a password field.
class PasswordVisibilityButton extends StatelessWidget {
  const PasswordVisibilityButton({
    super.key,
    required this.obscured,
    required this.onPressed,
  });

  final bool obscured;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: obscured ? 'Show password' : 'Hide password',
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      iconSize: 22,
      color: const Color(0xFF292929),
      icon: Icon(obscured ? Icons.visibility : Icons.visibility_off),
    );
  }
}
