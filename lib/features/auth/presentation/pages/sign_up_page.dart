import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../core/widgets/brand_button.dart';
import '../../../../core/widgets/underline_text_field.dart';
import '../bloc/sign_up/sign_up_bloc.dart';
import '../validation_messages.dart';
import '../widgets/credentials_form_layout.dart';
import '../widgets/password_visibility_button.dart';

/// Step 1 of sign-up: email and password. Nothing is sent yet; the account
/// is created after the profile step.
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _obscurePassword = true;

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<SignUpBloc>().add(const SignUpCredentialsSubmitted());
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SignUpBloc>();

    return BlocListener<SignUpBloc, SignUpState>(
      listenWhen: (previous, current) =>
          current.step == SignUpStep.credentials &&
          current.status == SignUpStatus.success &&
          previous.status != SignUpStatus.success,
      listener: (context, state) => context.push(AppRoutes.signUpPhone),
      child: BlocBuilder<SignUpBloc, SignUpState>(
        builder: (context, state) => CredentialsFormLayout(
          title: 'Sign up',
          fields: [
            UnderlineTextField(
              key: const Key('signUp_email'),
              label: 'Email Address',
              initialValue: state.email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              errorText: state.visibleEmailError?.message,
              onChanged: (v) => bloc.add(SignUpEmailChanged(v)),
              onBlur: () =>
                  bloc.add(const SignUpFieldBlurred(SignUpField.email)),
            ),
            const SizedBox(height: 18),
            UnderlineTextField(
              key: const Key('signUp_password'),
              label: 'Password',
              initialValue: state.password,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              errorText: state.visiblePasswordError?.message,
              onChanged: (v) => bloc.add(SignUpPasswordChanged(v)),
              onBlur: () =>
                  bloc.add(const SignUpFieldBlurred(SignUpField.password)),
              onSubmitted: (_) => _submit(),
              suffix: PasswordVisibilityButton(
                obscured: _obscurePassword,
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ],
          link: InlineLink(
            label: 'Have an account? Sign in',
            onTap: () => context.replace(AppRoutes.signIn),
          ),
          submit: BrandButton(
            key: const Key('signUp_submit'),
            label: 'Sign up',
            accent: BrandButtonAccent.corner,
            onPressed: _submit,
          ),
        ),
      ),
    );
  }
}
