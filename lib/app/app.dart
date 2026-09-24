import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/auth/domain/auth_user.dart';
import '../features/auth/presentation/bloc/auth/auth_bloc.dart';
import '../features/settings/domain/settings_repository.dart';
import '../features/settings/domain/theme_preference.dart';
import '../features/settings/presentation/bloc/theme/theme_bloc.dart';
import '../features/settings/presentation/theme_preference_ui.dart';
import '../features/wallet/domain/wallet_repository.dart';
import 'router.dart';

class Tm30PayApp extends StatefulWidget {
  const Tm30PayApp({
    super.key,
    required this.authRepository,
    required this.walletRepository,
    required this.settingsRepository,
    required this.initialUser,
    required this.initialThemePreference,
  });

  final AuthRepository authRepository;
  final WalletRepository walletRepository;
  final SettingsRepository settingsRepository;
  final AuthUser? initialUser;
  final ThemePreference initialThemePreference;

  @override
  State<Tm30PayApp> createState() => _Tm30PayAppState();
}

class _Tm30PayAppState extends State<Tm30PayApp> {
  // Created once here and not in build(). Creating the router on every
  // rebuild would reset the navigation stack.
  late final AuthBloc _authBloc;
  late final ThemeBloc _themeBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(
      authRepository: widget.authRepository,
      initialUser: widget.initialUser,
    )..add(const AuthSubscriptionRequested());
    _themeBloc = ThemeBloc(
      repository: widget.settingsRepository,
      initialPreference: widget.initialThemePreference,
    );
    _router = createRouter(_authBloc);
  }

  @override
  void dispose() {
    _router.dispose();
    _authBloc.close();
    _themeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: widget.authRepository),
        RepositoryProvider.value(value: widget.walletRepository),
        RepositoryProvider.value(value: widget.settingsRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _authBloc),
          BlocProvider.value(value: _themeBloc),
        ],
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, theme) => MaterialApp.router(
            title: 'Tm30 Pay',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: theme.preference.themeMode,
            routerConfig: _router,
          ),
        ),
      ),
    );
  }
}
