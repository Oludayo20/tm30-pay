import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/domain/auth_repository.dart';
import '../features/auth/presentation/bloc/auth/auth_bloc.dart';
import '../features/auth/presentation/bloc/sign_up/sign_up_bloc.dart';
import '../features/auth/presentation/pages/complete_profile_page.dart';
import '../features/auth/presentation/pages/phone_number_page.dart';
import '../features/auth/presentation/pages/sign_in_page.dart';
import '../features/auth/presentation/pages/sign_up_page.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/auth/presentation/pages/verify_otp_page.dart';
import '../features/auth/presentation/pages/welcome_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/transfer/presentation/pages/send_money_page.dart';
import '../features/wallet/domain/transaction.dart';
import '../features/wallet/domain/wallet_repository.dart';
import '../features/wallet/presentation/bloc/wallet/wallet_bloc.dart';
import '../features/wallet/presentation/pages/transaction_detail_page.dart';
import '../features/wallet/presentation/pages/wallet_page.dart';
import 'routes.dart';

/// Route tree:
///
///   /splash                      logo at launch, then asks for "/"
///   [SignUpBloc shell]           signed-out screens share one SignUpBloc
///     /welcome                   sign in or sign up
///     /sign-in
///     /sign-up                   email and password
///       /phone                   mobile number
///       /verify                  one-time code
///       /profile                 photo, names, date of birth
///   [WalletBloc shell]           signed-in routes share one WalletBloc
///     /                          wallet
///       /transactions/:id        detail (deep-linkable)
///       /send                    send money
///       /settings                profile, wallet data, appearance
///
/// The redirect is the only place that decides who may see which route.
/// Signing out makes AuthBloc emit, the router re-runs the redirect, the
/// shell is removed, and its WalletBloc is closed. The next user therefore
/// starts with a fresh WalletBloc. Signing in or finishing sign-up works
/// the same way in reverse, and also disposes the SignUpBloc with its
/// password and code.
///
/// The auth screens share one shell (so one navigator) because the brand
/// header morphs between welcome and the forms with a Hero, and Hero
/// flights don't cross navigators.
GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: _StreamListenable(authBloc.stream),
    redirect: (context, state) {
      final signedIn = authBloc.state.isAuthenticated;
      final location = state.matchedLocation;
      if (location == AppRoutes.splash) return null;
      final atAuth = AppRoutes.isAuthFlow(location);

      if (!signedIn) {
        if (atAuth) return null;
        // Remember where the user was going (for example a deep link to a
        // transaction) so they end up there after signing in. Someone
        // heading somewhere specific goes straight to sign-in; everyone
        // else gets the welcome screen.
        final from = state.uri.toString();
        return from == AppRoutes.home
            ? AppRoutes.welcome
            : Uri(
                path: AppRoutes.signIn,
                queryParameters: {'from': from},
              ).toString();
      }

      if (atAuth) {
        final from = state.uri.queryParameters['from'];
        // Only follow app-internal paths, never an external URL.
        return from != null && from.startsWith('/') ? from : AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      ShellRoute(
        // Fades in from the splash screen instead of sliding.
        pageBuilder: (context, state, child) => CustomTransitionPage(
          key: state.pageKey,
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
          child: BlocProvider(
            create: (context) =>
                SignUpBloc(authRepository: context.read<AuthRepository>()),
            child: child,
          ),
        ),
        routes: [
          GoRoute(
            path: AppRoutes.welcome,
            builder: (context, state) => const WelcomePage(),
          ),
          GoRoute(
            path: AppRoutes.signIn,
            builder: (context, state) => const SignInPage(),
          ),
          GoRoute(
            path: AppRoutes.signUp,
            builder: (context, state) => const SignUpPage(),
            routes: [
              GoRoute(
                path: _child(AppRoutes.signUpPhone, AppRoutes.signUp),
                builder: (context, state) => const PhoneNumberPage(),
              ),
              GoRoute(
                path: _child(AppRoutes.signUpVerify, AppRoutes.signUp),
                builder: (context, state) => const VerifyOtpPage(),
              ),
              GoRoute(
                path: _child(AppRoutes.signUpProfile, AppRoutes.signUp),
                builder: (context, state) => const CompleteProfilePage(),
              ),
            ],
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => BlocProvider(
          create: (context) =>
              WalletBloc(repository: context.read<WalletRepository>())
                ..add(const WalletStarted()),
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const WalletPage(),
            routes: [
              GoRoute(
                path: AppRoutes.transactionDetailPattern.substring(1),
                builder: (context, state) => TransactionDetailPage(
                  transactionId: state.pathParameters['id']!,
                  initial: state.extra is Transaction
                      ? state.extra! as Transaction
                      : null,
                ),
              ),
              GoRoute(
                path: AppRoutes.sendMoney.substring(1),
                builder: (context, state) => const SendMoneyPage(),
              ),
              GoRoute(
                path: AppRoutes.settings.substring(1),
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// "/sign-up/phone" under "/sign-up" is declared as "phone".
String _child(String path, String parent) => path.substring(parent.length + 1);

/// Turns a stream into a Listenable, so go_router re-runs [GoRouter.redirect]
/// every time the auth state changes.
class _StreamListenable extends ChangeNotifier {
  _StreamListenable(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
