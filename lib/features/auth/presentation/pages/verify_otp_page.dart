import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/theme/brand.dart';
import '../../../../core/widgets/brand_button.dart';
import '../../domain/sign_up_validators.dart';
import '../bloc/sign_up/sign_up_bloc.dart';
import '../widgets/otp_code_input.dart';
import '../widgets/otp_layout.dart';

/// Step 3 of sign-up: the 4-digit code. It submits by itself once the last
/// digit is typed; "Verify" is there for anyone who expects a button.
class VerifyOtpPage extends StatelessWidget {
  const VerifyOtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SignUpBloc>();

    return BlocListener<SignUpBloc, SignUpState>(
      listenWhen: (previous, current) =>
          current.step == SignUpStep.verify &&
          previous.status != current.status,
      listener: (context, state) {
        final failure = state.failure;
        if (state.status == SignUpStatus.success) {
          context.push(AppRoutes.signUpProfile);
        } else if (failure != null && failure is! InvalidOtpFailure) {
          // A wrong code is shown under the digits; anything else, such as
          // no connection, goes in a snackbar.
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(failure.message)));
        }
      },
      child: BlocBuilder<SignUpBloc, SignUpState>(
        builder: (context, state) {
          final submitting = state.isSubmitting(SignUpStep.verify);
          final failure = state.failureFor(SignUpStep.verify);
          final showIncomplete =
              state.attempted.contains(SignUpStep.verify) &&
              !state.codeComplete &&
              failure == null;
          final errorText = failure is InvalidOtpFailure
              ? failure.message
              : (showIncomplete ? 'Enter all 4 digits of the code' : null);

          return OtpLayout(
            message: Text.rich(
              TextSpan(
                text: 'Enter the OTP sent to ',
                children: [
                  TextSpan(
                    text: state.phone.trim(),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            input: Column(
              children: [
                const SizedBox(height: 62),
                OtpCodeInput(
                  key: const Key('signUp_code'),
                  length: SignUpValidators.codeLength,
                  enabled: !submitting,
                  hasError: failure is InvalidOtpFailure,
                  onChanged: (v) => bloc.add(SignUpCodeChanged(v)),
                  onCompleted: (_) => bloc.add(const SignUpCodeSubmitted()),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 38,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      errorText ?? '',
                      key: ValueKey(errorText),
                      textAlign: TextAlign.center,
                      style: BrandText.caption.copyWith(
                        color: BrandColors.error,
                      ),
                    ),
                  ),
                ),
                _ResendPrompt(
                  availableAt: state.resendAvailableAt,
                  resending: state.resending,
                  onResend: () => bloc.add(const SignUpCodeResent()),
                ),
              ],
            ),
            action: BrandButton(
              key: const Key('signUp_verify'),
              label: 'Verify',
              centered: true,
              trailing: BrandButtonTrailing.none,
              accent: BrandButtonAccent.split,
              loading: submitting,
              onPressed: () => bloc.add(const SignUpCodeSubmitted()),
            ),
          );
        },
      ),
    );
  }
}

/// "Didn't you receive the OTP? Resend OTP". The link waits out a short
/// cooldown after each code, counting down, so people don't trigger a
/// burst of SMS while the first one is still arriving.
class _ResendPrompt extends StatefulWidget {
  const _ResendPrompt({
    required this.availableAt,
    required this.resending,
    required this.onResend,
  });

  final DateTime? availableAt;
  final bool resending;
  final VoidCallback onResend;

  @override
  State<_ResendPrompt> createState() => _ResendPromptState();
}

class _ResendPromptState extends State<_ResendPrompt> {
  Timer? _ticker;
  late final _tap = TapGestureRecognizer()..onTap = _resend;

  int get _secondsLeft {
    final at = widget.availableAt;
    if (at == null) return 0;
    final left = at.difference(DateTime.now()).inMilliseconds;
    return left <= 0 ? 0 : (left / 1000).ceil();
  }

  @override
  void initState() {
    super.initState();
    _startTicker();
  }

  @override
  void didUpdateWidget(_ResendPrompt old) {
    super.didUpdateWidget(old);
    if (old.availableAt != widget.availableAt) _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();
    if (_secondsLeft == 0) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
      if (_secondsLeft == 0) timer.cancel();
    });
  }

  void _resend() {
    if (_secondsLeft == 0 && !widget.resending) widget.onResend();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _tap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seconds = _secondsLeft;
    final ready = seconds == 0 && !widget.resending;
    final style = BrandText.caption.copyWith(
      fontSize: 14,
      color: BrandColors.muted,
    );
    final link = widget.resending
        ? 'Sending…'
        : ready
        ? 'Resend OTP'
        : 'Resend in 0:${seconds.toString().padLeft(2, '0')}';

    return Text.rich(
      TextSpan(
        text: 'Didn’t you receive the OTP? ',
        style: style,
        children: [
          TextSpan(
            text: link,
            recognizer: ready ? _tap : null,
            style: style.copyWith(
              color: ready ? BrandColors.blue : BrandColors.muted,
              fontWeight: FontWeight.w500,
            ),
            semanticsLabel: ready ? 'Resend OTP' : link,
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
