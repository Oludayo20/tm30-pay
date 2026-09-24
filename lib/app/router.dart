import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/bloc/auth/auth_bloc.dart';
import '../features/auth/presentation/pages/sign_in_page.dart';
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
///   /sign-in
///   [WalletBloc shell]           signed-in routes share one WalletBloc
///     /                          wallet
///       /transactions/:id        detail (deep-linkable)
///       /send                    send money
///       /settings                profile, wallet data, appearance
///
/// The redirect is the only place that decides who may see which route.
/// Signing out makes AuthBloc emit, the router re-runs the redirect, the
/// shell is removed, and its WalletBloc is closed. The next user therefore
/// starts with a fresh WalletBloc.
GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: _StreamListenable(authBloc.stream),
    redirect: (context, state) {
      final signedIn = authBloc.state.isAuthenticated;
      final atSignIn = state.matchedLocation == AppRoutes.signIn;

      if (!signedIn) {
        if (atSignIn) return null;
        // Remember where the user was going (for example a deep link to a
        // transaction) so they end up there after signing in.
        final from = state.uri.toString();
        return from == AppRoutes.home
            ? AppRoutes.signIn
            : Uri(
                path: AppRoutes.signIn,
                queryParameters: {'from': from},
              ).toString();
      }

      if (atSignIn) {
        final from = state.uri.queryParameters['from'];
        // Only follow app-internal paths, never an external URL.
        return from != null && from.startsWith('/') ? from : AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => const SignInPage(),
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
