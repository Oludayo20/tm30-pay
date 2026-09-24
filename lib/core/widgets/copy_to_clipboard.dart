import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Copies [text] and confirms it with a short snackbar.
Future<void> copyToClipboard(
  BuildContext context, {
  required String text,
  required String label,
}) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('$label copied'),
        duration: const Duration(seconds: 2),
      ),
    );
}
