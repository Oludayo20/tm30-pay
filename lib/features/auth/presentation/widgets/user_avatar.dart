import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/auth_user.dart';

/// A round avatar with the photo the user added at sign-up, or their
/// initials on a soft brand-tinted background.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.user, this.radius = 22});

  final AuthUser? user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final photo = user?.photoPath;
    if (photo != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: scheme.primaryContainer,
        backgroundImage: ResizeImage(
          FileImage(File(photo)),
          width: (radius * 2 * MediaQuery.devicePixelRatioOf(context)).round(),
        ),
      );
    }
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
