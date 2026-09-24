import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/brand.dart';

/// Four underlined digit cells.
///
/// Underneath is a single invisible [TextField], not four separate ones.
/// That keeps the platform's one-time-code autofill (iOS reads the code
/// from the SMS), paste and backspace working as users expect, and a screen
/// reader sees a single "verification code" field.
class OtpCodeInput extends StatefulWidget {
  const OtpCodeInput({
    super.key,
    required this.length,
    required this.onChanged,
    this.onCompleted,
    this.hasError = false,
    this.enabled = true,
  });

  final int length;
  final ValueChanged<String> onChanged;

  /// Called once all digits are entered.
  final ValueChanged<String>? onCompleted;
  final bool hasError;
  final bool enabled;

  @override
  State<OtpCodeInput> createState() => _OtpCodeInputState();
}

class _OtpCodeInputState extends State<OtpCodeInput> {
  static const _cellWidth = 48.0;
  static const _gap = 24.0;

  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
    // Everything on this screen is about the code, so open the keyboard.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.enabled) _focusNode.requestFocus();
    });
  }

  @override
  void didUpdateWidget(OtpCodeInput old) {
    super.didUpdateWidget(old);
    // A rejected code is cleared so the user can type the next one straight
    // away, without deleting the old digits first.
    if (widget.hasError && !old.hasError) {
      _controller.clear();
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleChanged(String value) {
    setState(() {});
    widget.onChanged(value);
    if (value.length == widget.length) widget.onCompleted?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final code = _controller.text;
    final focused = _focusNode.hasFocus;
    final width = widget.length * _cellWidth + (widget.length - 1) * _gap;

    return SizedBox(
      width: width,
      height: 56,
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < widget.length; i++)
                _Cell(
                  digit: i < code.length ? code[i] : null,
                  active:
                      focused && i == code.length.clamp(0, widget.length - 1),
                  hasError: widget.hasError,
                ),
            ],
          ),
          // Transparent, on top of the cells, so tapping anywhere focuses it.
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: widget.enabled,
                onChanged: _handleChanged,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(widget.length),
                ],
                showCursor: false,
                enableInteractiveSelection: false,
                decoration: const InputDecoration(
                  labelText: 'Verification code',
                  border: InputBorder.none,
                  counterText: '',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.digit,
    required this.active,
    required this.hasError,
  });

  final String? digit;
  final bool active;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final lineColor = hasError
        ? BrandColors.error
        : (digit != null || active
              ? BrandColors.blue
              : const Color(0xFFC5CBF8));
    return SizedBox(
      width: _OtpCodeInputState._cellWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 140),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween(begin: 0.7, end: 1.0).animate(animation),
                child: child,
              ),
            ),
            child: Text(
              digit ?? '',
              key: ValueKey(digit),
              style: const TextStyle(
                fontFamily: kBrandFontFamily,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1.2,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: active ? 2 : 1,
            color: lineColor,
          ),
        ],
      ),
    );
  }
}
