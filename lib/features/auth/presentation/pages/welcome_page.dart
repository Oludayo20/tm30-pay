import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../core/widgets/brand_button.dart';
import '../bloc/sign_up/sign_up_bloc.dart';
import '../widgets/auth_header.dart';

/// The first screen a signed-out user sees: the brand header with a choice
/// between signing in and creating an account.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: AuthHeader.heightFor(size),
              child: const AuthHeader(collapsed: false),
            ),
            Positioned(
              left: 30,
              right: 30,
              bottom: safeBottom + 34,
              child: Column(
                children: [
                  BrandButton(
                    key: const Key('welcome_signIn'),
                    label: 'Sign In',
                    accent: BrandButtonAccent.corner,
                    onPressed: () => context.push(AppRoutes.signIn),
                  ),
                  const SizedBox(height: 18),
                  BrandButton(
                    key: const Key('welcome_signUp'),
                    label: 'Sign up',
                    variant: BrandButtonVariant.outlined,
                    onPressed: () {
                      context.read<SignUpBloc>().add(const SignUpStarted());
                      context.push(AppRoutes.signUp);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
