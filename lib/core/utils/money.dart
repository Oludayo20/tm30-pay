import 'package:intl/intl.dart';

/// Money is stored as an integer number of kobo (minor units). This avoids
/// floating-point rounding errors such as 0.1 + 0.2 != 0.3.
abstract final class Money {
  static const int minorUnitsPerMajor = 100;

  static final NumberFormat _format = NumberFormat.currency(
    locale: 'en_NG',
    symbol: '₦',
    decimalDigits: 2,
  );

  /// Turns 25000000 into "₦250,000.00".
  static String format(int minorUnits) =>
      _format.format(minorUnits / minorUnitsPerMajor);

  /// Parses what the user typed, such as "1,500.5", into minor units (150050).
  /// Returns null for anything that is not a well-formed amount with at most
  /// two decimal places.
  static int? tryParse(String input) {
    final cleaned = input.replaceAll(',', '').trim();
    final match = RegExp(r'^(\d+)(?:\.(\d{1,2}))?$').firstMatch(cleaned);
    if (match == null) return null;
    final major = int.parse(match.group(1)!);
    final minor = int.parse((match.group(2) ?? '').padRight(2, '0'));
    return major * minorUnitsPerMajor + minor;
  }
}
