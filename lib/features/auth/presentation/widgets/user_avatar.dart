import 'package:flutter/material.dart';

import '../../domain/auth_user.dart';

/// A round avatar showing the user's initials on a soft brand-tinted
/// background. There are no profile photos yet, and initials are what most
/// banking apps show.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.user, this.radius = 22});

  final AuthUser? user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.primaryContainer,
      foregroundColor: scheme.onPrimaryContainer,
      child: Text(
        user?.initials ?? '',
        style: TextStyle(
          fontSize: radius * 0.72,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
