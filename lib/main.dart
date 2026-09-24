import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'features/auth/data/auth_repository_impl.dart';
import 'features/auth/data/fake_auth_api.dart';
import 'features/auth/data/session_storage.dart';
import 'features/settings/data/settings_repository_impl.dart';
import 'features/wallet/data/fake_wallet_api.dart';
import 'features/wallet/data/wallet_cache.dart';
import 'features/wallet/data/wallet_repository_impl.dart';

/// Composition root: every concrete class is created here. To use a real
/// backend, change these lines. Nothing in the presentation layer changes.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = SharedPreferencesAsync();
  final authRepository = AuthRepositoryImpl(
    api: FakeAuthApi(),
    storage: SessionStorage(),
  );
  final walletRepository = WalletRepositoryImpl(
    api: FakeWalletApi(),
    cache: WalletCache(prefs),
  );
  final settingsRepository = SettingsRepositoryImpl(prefs);

  // Clear the cached wallet data on sign-out, so the next person to sign in
  // on this device never sees the previous user's transactions. This is set
  // up here because it connects two repositories that otherwise don't know
  // about each other.
  authRepository.userChanges
      .where((user) => user == null)
      .listen((_) => walletRepository.clearCache());

  // Read the session and theme before the first frame, in parallel. The app
  // then starts on the right screen in the right theme, with no flash.
  final (initialUser, initialThemePreference) = await (
    authRepository.currentUser(),
    settingsRepository.readThemePreference(),
  ).wait;

  runApp(
    Tm30PayApp(
      authRepository: authRepository,
      walletRepository: walletRepository,
      settingsRepository: settingsRepository,
      initialUser: initialUser,
      initialThemePreference: initialThemePreference,
    ),
  );
}
