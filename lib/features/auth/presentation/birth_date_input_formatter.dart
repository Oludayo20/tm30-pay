import 'package:flutter/services.dart';

/// Types the dashes of "dd-mm-yyyy" for the user, so the date field only
/// ever needs the number keyboard. Deleting past a dash removes the digit
/// before it too.
class BirthDateInputFormatter extends TextInputFormatter {
  const BirthDateInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final deletingDash =
        newValue.text.length < oldValue.text.length &&
        oldValue.text.endsWith('-') &&
        !newValue.text.endsWith('-');
    if (deletingDash && digits.isNotEmpty) {
      digits = digits.substring(0, digits.length - 1);
    }
    if (digits.length > 8) digits = digits.substring(0, 8);

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      // Add the dash as soon as a part is complete, but only while typing
      // forward, so backspace can still remove it.
      final partDone = i == 1 || i == 3;
      final typingForward = newValue.text.length > oldValue.text.length;
      if (partDone && (i < digits.length - 1 || typingForward)) {
        buffer.write('-');
      }
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
