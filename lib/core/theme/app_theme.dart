import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const Color tm30Blue = Color(0xFF0B5FFF);

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: tm30Blue,
      brightness: brightness,
    );
    // By default fromSeed tones the seed down. Use the exact brand blue as
    // primary in light mode; dark mode keeps the lighter generated tone so
    // text on it stays readable.
    final colorScheme = brightness == Brightness.light
        ? scheme.copyWith(primary: tm30Blue, onPrimary: Colors.white)
        : scheme;

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      extensions: [
        brightness == Brightness.light ? StatusColors.light : StatusColors.dark,
      ],
      appBarTheme: const AppBarTheme(centerTitle: false),
      inputDecorationTheme: InputDecorationTheme(
        border: inputBorder,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Colours for transaction status (success, pending, failed) in light and
/// dark mode. Kept separate from the Material colour scheme so each colour
/// means the same status on every screen.
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({
    required this.success,
    required this.pending,
    required this.failed,
  });

  final Color success;
  final Color pending;
  final Color failed;

  static const light = StatusColors(
    success: Color(0xFF1B8A4B),
    pending: Color(0xFFB26A00),
    failed: Color(0xFFC62828),
  );

  static const dark = StatusColors(
    success: Color(0xFF6FD39A),
    pending: Color(0xFFFFC266),
    failed: Color(0xFFFF8A80),
  );

  @override
  StatusColors copyWith({Color? success, Color? pending, Color? failed}) =>
      StatusColors(
        success: success ?? this.success,
        pending: pending ?? this.pending,
        failed: failed ?? this.failed,
      );

  @override
  StatusColors lerp(StatusColors? other, double t) {
    if (other == null) return this;
    return StatusColors(
      success: Color.lerp(success, other.success, t)!,
      pending: Color.lerp(pending, other.pending, t)!,
      failed: Color.lerp(failed, other.failed, t)!,
    );
  }
}

extension StatusColorsX on BuildContext {
  StatusColors get statusColors => Theme.of(this).extension<StatusColors>()!;
}
