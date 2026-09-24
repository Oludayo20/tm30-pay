import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/brand.dart';

/// Where the field sits, which decides its colours.
enum UnderlineFieldTone {
  /// Grey label, ink text and a blue focus line on a white screen.
  light,

  /// White label, text and line on the blue profile screen.
  onBlue,
}

/// The borderless, underlined field from the design: a small label above
/// the text and one hairline below it.
///
/// The visible label is laid out above the field, because InputDecorator
/// pins a floating label to the text and can't give the design's gap. The
/// same label is also passed as an invisible labelText, so a screen reader
/// still announces label, hint and error together as one field. Like
/// AppTextField, it calls [onBlur] when it loses focus, which the form
/// blocs use to decide when to start showing errors.
class UnderlineTextField extends StatefulWidget {
  const UnderlineTextField({
    super.key,
    required this.label,
    required this.onChanged,
    this.tone = UnderlineFieldTone.light,
    this.initialValue,
    this.hintText,
    this.errorText,
    this.onBlur,
    this.onSubmitted,
    this.suffix,
    this.showValid = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.autofillHints,
    this.obscureText = false,
    this.enabled = true,
    this.autofocus = false,
    this.centered = false,
    this.style,
  });

  final String label;
  final ValueChanged<String> onChanged;
  final UnderlineFieldTone tone;
  final String? initialValue;
  final String? hintText;
  final String? errorText;
  final VoidCallback? onBlur;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffix;

  /// Shows the purple check the profile screen uses for a valid field.
  final bool showValid;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final bool enabled;
  final bool autofocus;

  /// Centres the label and the text, as on the phone number screen.
  final bool centered;

  /// Overrides the text style, for example the bold phone number.
  final TextStyle? style;

  @override
  State<UnderlineTextField> createState() => _UnderlineTextFieldState();
}

class _UnderlineTextFieldState extends State<UnderlineTextField> {
  late final _controller = TextEditingController(text: widget.initialValue);
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) widget.onBlur?.call();
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onBlue = widget.tone == UnderlineFieldTone.onBlue;
    final hasError = widget.errorText != null;

    final labelColor = switch ((onBlue, hasError)) {
      (false, true) => BrandColors.error,
      (false, false) => BrandColors.muted,
      (true, true) => BrandColors.errorOnBlue,
      (true, false) => Colors.white.withValues(alpha: 0.72),
    };
    final restLine = onBlue
        ? Colors.white.withValues(alpha: 0.85)
        : const Color(0xFFC5CBF8);
    final focusLine = onBlue ? Colors.white : BrandColors.blue;
    final errorColor = onBlue ? BrandColors.errorOnBlue : BrandColors.error;

    final inputStyle =
        widget.style ??
        (onBlue
            ? BrandText.input.copyWith(
                color: Colors.white,
                fontSize: 15.5,
                fontWeight: FontWeight.w400,
              )
            : BrandText.input);

    UnderlineInputBorder line(Color color, [double width = 1]) =>
        UnderlineInputBorder(
          borderSide: BorderSide(color: color, width: width),
        );

    final suffix =
        widget.suffix ??
        (onBlue
            ? AnimatedOpacity(
                opacity: widget.showValid ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(
                  Icons.check_rounded,
                  color: BrandColors.purple,
                  size: 22,
                ),
              )
            : null);

    final field = TextField(
      controller: _controller,
      focusNode: _focusNode,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      obscureText: widget.obscureText,
      obscuringCharacter: '•',
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      autofillHints: widget.autofillHints,
      textAlign: widget.centered ? TextAlign.center : TextAlign.start,
      style: inputStyle,
      cursorColor: onBlue ? Colors.white : BrandColors.blue,
      cursorWidth: 1.5,
      decoration: InputDecoration(
        // For screen readers only; the visible label is drawn above.
        labelText: widget.label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        floatingLabelStyle: const TextStyle(
          fontSize: 0.1,
          height: 0.1,
          color: Colors.transparent,
        ),
        hintText: widget.hintText,
        hintStyle: inputStyle.copyWith(
          color: onBlue
              ? Colors.white.withValues(alpha: 0.72)
              : BrandColors.muted,
          fontWeight: FontWeight.w400,
        ),
        // A blank helper keeps the space for an error reserved, so fields
        // below don't jump when an error appears.
        helperText: ' ',
        helperStyle: BrandText.caption,
        errorText: widget.errorText,
        errorStyle: BrandText.caption.copyWith(color: errorColor),
        errorMaxLines: 2,
        isDense: true,
        filled: false,
        contentPadding: const EdgeInsets.only(top: 2, bottom: 10),
        suffixIcon: suffix,
        suffixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 32,
        ),
        border: line(restLine),
        enabledBorder: line(restLine),
        disabledBorder: line(restLine.withValues(alpha: 0.5)),
        focusedBorder: line(focusLine, 1.5),
        errorBorder: line(errorColor),
        focusedErrorBorder: line(errorColor, 1.5),
      ),
    );

    return Column(
      crossAxisAlignment: widget.centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.stretch,
      children: [
        ExcludeSemantics(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 160),
            style: BrandText.label.copyWith(
              color: labelColor,
              fontSize: widget.centered ? 16.5 : null,
            ),
            child: Text(
              widget.label,
              textAlign: widget.centered ? TextAlign.center : TextAlign.start,
            ),
          ),
        ),
        const SizedBox(height: 2),
        field,
      ],
    );
  }
}
