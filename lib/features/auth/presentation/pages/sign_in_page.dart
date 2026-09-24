import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tm30_pay/core/widgets/brand_button.dart';
import 'package:tm30_pay/core/widgets/underline_text_field.dart';
import 'package:tm30_pay/features/auth/domain/auth_repository.dart';
import 'package:tm30_pay/features/auth/presentation/bloc/sign_in/sign_in_bloc.dart';
import 'package:tm30_pay/features/auth/presentation/validation_messages.dart';
import 'package:tm30_pay/features/auth/presentation/widgets/credentials_form_layout.dart';
import 'package:tm30_pay/features/auth/presentation/widgets/password_visibility_button.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SignInBloc(authRepository: context.read<AuthRepository>()),
      child: const SignInView(),
    );
  }
}

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  // Whether the password is visible is purely a display choice, so it stays
  // in the widget rather than in the bloc.
  bool _obscurePassword = true;

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<SignInBloc>().add(const SignInSubmitted());
  }

  void _forgotPassword() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Password reset isn’t available in this demo yet.'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SignInBloc>();

    return BlocListener<SignInBloc, SignInState>(
      listenWhen: (previous, current) =>
          current.status == SignInStatus.failure &&
          previous.status != SignInStatus.failure,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.failure!.message)));
      },
      child: BlocBuilder<SignInBloc, SignInState>(
        builder: (context, state) => CredentialsFormLayout(
          title: 'Sign in',
          fields: [
            UnderlineTextField(
              key: const Key('signIn_email'),
              label: 'Email Address',
              enabled: !state.isSubmitting,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              errorText: state.visibleEmailError?.message,
              onChanged: (v) => bloc.add(SignInEmailChanged(v)),
              onBlur: () =>
                  bloc.add(const SignInFieldBlurred(SignInField.email)),
            ),
            const SizedBox(height: 18),
            UnderlineTextField(
              key: const Key('signIn_password'),
              label: 'Password',
              enabled: !state.isSubmitting,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              errorText: state.visiblePasswordError?.message,
              onChanged: (v) => bloc.add(SignInPasswordChanged(v)),
              onBlur: () =>
                  bloc.add(const SignInFieldBlurred(SignInField.password)),
              onSubmitted: (_) => _submit(),
              suffix: PasswordVisibilityButton(
                obscured: _obscurePassword,
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ],
          link: InlineLink(label: 'Forgot password?', onTap: _forgotPassword),
          submit: BrandButton(
            key: const Key('signIn_submit'),
            label: 'Sign in',
            accent: BrandButtonAccent.corner,
            loading: state.isSubmitting,
            onPressed: _submit,
          ),
        ),
      ),
    );
  }
}
