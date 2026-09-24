import 'package:flutter/material.dart';

import '../../../../core/utils/greeting.dart';
import '../../../auth/domain/auth_user.dart';
import '../../../auth/presentation/widgets/user_avatar.dart';

/// The top of the home screen: avatar, greeting and first name, plus a
/// settings button. Tapping the avatar also opens settings, as users expect
/// from most apps.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.user,
    required this.now,
    required this.onOpenSettings,
  });

  final AuthUser? user;
  final DateTime now;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Semantics(
          button: true,
          label: 'Open profile and settings',
          child: InkWell(
            key: const Key('home_avatar'),
            customBorder: const CircleBorder(),
            onTap: onOpenSettings,
            child: Hero(
              tag: 'user-avatar',
              child: UserAvatar(user: user),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greetingFor(now),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                user?.firstName ?? '',
                key: const Key('home_userName'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          key: const Key('wallet_settings'),
          tooltip: 'Settings',
          onPressed: onOpenSettings,
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    );
  }
}
