import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/money.dart';
import '../../../../core/widgets/copy_to_clipboard.dart';
import '../../../../core/widgets/responsive.dart';
import '../../../auth/domain/auth_user.dart';
import '../../../auth/presentation/bloc/auth/auth_bloc.dart';
import '../../../auth/presentation/widgets/sign_out_dialog.dart';
import '../../../auth/presentation/widgets/user_avatar.dart';
import '../../../transfer/domain/transfer_validators.dart';
import '../../domain/theme_preference.dart';
import '../bloc/theme/theme_bloc.dart';
import '../theme_preference_ui.dart';
import '../widgets/settings_section.dart';

/// Profile, account details, what wallet data is on the device, appearance
/// and sign-out. It only reads existing blocs; nothing here needs its own.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc b) => b.state.user);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: user == null
          ? const SizedBox.shrink()
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                ResponsiveCenter(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ProfileHeader(user),
                      const SizedBox(height: 24),
                      _AccountSection(user),

                      const SizedBox(height: 24),
                      const _AppearanceSection(),
                      const SizedBox(height: 32),
                      OutlinedButton.icon(
                        key: const Key('settings_signOut'),
                        onPressed: () => confirmSignOut(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.error
                                .withValues(alpha: 0.5),
                          ),
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Sign out'),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tm30 Pay · Version 1.0.0',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader(this.user);

  final AuthUser user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Hero(
          tag: 'user-avatar',
          child: UserAvatar(user: user, radius: 40),
        ),
        const SizedBox(height: 12),
        Text(
          user.fullName,
          key: const Key('settings_fullName'),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          user.email,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              'Member since ${DateFormat('MMMM yyyy').format(user.memberSince)}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection(this.user);

  final AuthUser user;

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'Account',
      children: [
        SettingsRow(
          icon: Icons.account_balance_outlined,
          label: 'Account number',
          value: user.walletAccountNumber,
          trailing: IconButton(
            key: const Key('settings_copyAccount'),
            tooltip: 'Copy account number',
            // Compact, so this row is the same height as the others.
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints.tightFor(width: 36, height: 24),
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.copy_rounded, size: 20),
            onPressed: () => copyToClipboard(
              context,
              text: user.walletAccountNumber,
              label: 'Account number',
            ),
          ),
        ),
        const SettingsRow(
          icon: Icons.storefront_outlined,
          label: 'Bank',
          value: 'Tm30 Pay',
        ),
        SettingsRow(
          icon: Icons.speed_rounded,
          label: 'Limit per transfer',
          value: Money.format(TransferValidators.maxAmount),
        ),
        const SettingsRow(
          icon: Icons.lock_outline_rounded,
          label: 'Session',
          value: 'Stored in secure storage',
        ),
      ],
    );
  }
}

class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context) {
    final preference = context.select((ThemeBloc b) => b.state.preference);

    return SettingsSection(
      title: 'Appearance',
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SegmentedButton<ThemePreference>(
            key: const Key('settings_themeMode'),
            showSelectedIcon: false,
            segments: [
              for (final p in ThemePreference.values)
                ButtonSegment(
                  value: p,
                  icon: Icon(p.icon),
                  label: Text(p.label),
                ),
            ],
            selected: {preference},
            onSelectionChanged: (selection) => context.read<ThemeBloc>().add(
              ThemePreferenceChanged(selection.single),
            ),
          ),
        ),
      ],
    );
  }
}
