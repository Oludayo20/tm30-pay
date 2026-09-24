import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../core/theme/brand.dart';
import '../../../../core/widgets/brand_button.dart';
import '../../../../core/widgets/underline_text_field.dart';
import '../bloc/sign_up/sign_up_bloc.dart';
import '../validation_messages.dart';
import '../widgets/otp_layout.dart';

/// Step 2 of sign-up: the mobile number the one-time code is sent to.
class PhoneNumberPage extends StatelessWidget {
  const PhoneNumberPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SignUpBloc>();
    void submit() {
      FocusScope.of(context).unfocus();
      bloc.add(const SignUpCodeRequested());
    }

    return BlocListener<SignUpBloc, SignUpState>(
      listenWhen: (previous, current) =>
          current.step == SignUpStep.phone && previous.status != current.status,
      listener: (context, state) {
        if (state.status == SignUpStatus.success) {
          context.push(AppRoutes.signUpVerify);
        } else if (state.status == SignUpStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.failure!.message)));
        }
      },
      child: BlocBuilder<SignUpBloc, SignUpState>(
        builder: (context, state) {
          final submitting = state.isSubmitting(SignUpStep.phone);
          return OtpLayout(
            message: const Text(
              'We will send you a one-time password\nto this mobile number',
            ),
            input: Padding(
              padding: const EdgeInsets.only(top: 34),
              child: SizedBox(
                width: 233,
                child: UnderlineTextField(
                  key: const Key('signUp_phone'),
                  label: 'Enter Mobile Number',
                  hintText: '+49 111 222 333',
                  centered: true,
                  initialValue: state.phone,
                  enabled: !submitting,
                  style: const TextStyle(
                    fontFamily: kBrandFontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: BrandColors.ink,
                  ),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d+ ]')),
                    LengthLimitingTextInputFormatter(20),
                  ],
                  errorText: state.visiblePhoneError?.message,
                  onChanged: (v) => bloc.add(SignUpPhoneChanged(v)),
                  onBlur: () =>
                      bloc.add(const SignUpFieldBlurred(SignUpField.phone)),
                  onSubmitted: (_) => submit(),
                ),
              ),
            ),
            action: BrandButton(
              key: const Key('signUp_getOtp'),
              label: 'Get OTP',
              centered: true,
              trailing: BrandButtonTrailing.none,
              accent: BrandButtonAccent.split,
              loading: submitting,
              onPressed: submit,
            ),
          );
        },
      ),
    );
  }
}
