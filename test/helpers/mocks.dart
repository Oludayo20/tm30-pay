import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tm30_pay/features/auth/domain/auth_repository.dart';
import 'package:tm30_pay/features/auth/domain/auth_user.dart';
import 'package:tm30_pay/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:tm30_pay/features/settings/domain/settings_repository.dart';
import 'package:tm30_pay/features/settings/domain/theme_preference.dart';
import 'package:tm30_pay/features/settings/presentation/bloc/theme/theme_bloc.dart';
import 'package:tm30_pay/features/wallet/data/wallet_cache.dart';
import 'package:tm30_pay/features/wallet/domain/wallet_repository.dart';
import 'package:tm30_pay/features/wallet/domain/wallet_snapshot.dart';
import 'package:tm30_pay/features/wallet/domain/transfer.dart';
import 'package:tm30_pay/features/wallet/presentation/bloc/wallet/wallet_bloc.dart';

class MockWalletRepository extends Mock implements WalletRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockWalletCache extends Mock implements WalletCache {}

class MockWalletBloc extends MockBloc<WalletEvent, WalletState>
    implements WalletBloc {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockThemeBloc extends MockBloc<ThemeEvent, ThemeState>
    implements ThemeBloc {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

final testUser = AuthUser(
  email: 'ada.obi@tm30.net',
  fullName: 'Ada Obi',
  walletAccountNumber: '3012345678',
  memberSince: DateTime(2024, 3, 12),
);

void registerFallbacks() {
  registerFallbackValue(
    const TransferRequest(
      recipientName: 'x',
      accountNumber: '0000000000',
      amount: 1,
      idempotencyKey: 'k',
    ),
  );
  registerFallbackValue(
    WalletSnapshot(
      balance: 0,
      transactions: const [],
      nextCursor: null,
      asOf: DateTime(2026),
    ),
  );
  registerFallbackValue(const WalletStarted());
  registerFallbackValue(ThemePreference.system);
  registerFallbackValue(const ThemePreferenceChanged(ThemePreference.system));
}
