import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tm30_pay/core/widgets/app_text_field.dart';
import 'package:tm30_pay/core/widgets/button_progress.dart';
import 'package:tm30_pay/core/widgets/responsive.dart';
import 'package:tm30_pay/features/auth/domain/auth_repository.dart';
import 'package:tm30_pay/features/auth/presentation/bloc/sign_in/sign_in_bloc.dart';
import 'package:tm30_pay/features/auth/presentation/validation_messages.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: ResponsiveCenter(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
              child: BlocBuilder<SignInBloc, SignInState>(
                builder: (context, state) {
                  return AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 56,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Welcome to Tm30 Pay',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to view your wallet and send money.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 32),
                        AppTextField(
                          key: const Key('signIn_email'),
                          label: 'Email',
                          enabled: !state.isSubmitting,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          errorText: state.visibleEmailError?.message,
                          onChanged: (v) => bloc.add(SignInEmailChanged(v)),
                          onBlur: () => bloc.add(
                            const SignInFieldBlurred(SignInField.email),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          key: const Key('signIn_password'),
                          label: 'Password',
                          enabled: !state.isSubmitting,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          errorText: state.visiblePasswordError?.message,
                          onChanged: (v) => bloc.add(SignInPasswordChanged(v)),
                          onBlur: () => bloc.add(
                            const SignInFieldBlurred(SignInField.password),
                          ),
                          onSubmitted: (_) => _submit(),
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword
                                ? 'Show password'
                                : 'Hide password',
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        FilledButton(
                          key: const Key('signIn_submit'),
                          onPressed: state.isSubmitting ? null : _submit,
                          child: state.isSubmitting
                              ? const ButtonProgress()
                              : const Text('Sign in'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
