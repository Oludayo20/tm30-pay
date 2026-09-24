import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/brand.dart';

/// The camera tile on the profile screen. Tapping it offers the camera or
/// the photo library; once chosen, the photo replaces the tile in the same
/// rounded-square frame.
class ProfilePhotoPicker extends StatelessWidget {
  const ProfilePhotoPicker({
    super.key,
    required this.photoPath,
    required this.onChanged,
    this.picker,
  });

  final String? photoPath;

  /// Called with the new path, or null when the photo is removed.
  final ValueChanged<String?> onChanged;

  /// Injected in tests.
  final ImagePicker? picker;

  static const double _photoSize = 112;

  Future<void> _choose(BuildContext context) async {
    final source = await showModalBottomSheet<_Choice>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, _Choice.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from library'),
              onTap: () => Navigator.pop(context, _Choice.gallery),
            ),
            if (photoPath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Remove photo'),
                onTap: () => Navigator.pop(context, _Choice.remove),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null) return;
    if (source == _Choice.remove) return onChanged(null);

    try {
      final file = await (picker ?? ImagePicker()).pickImage(
        source: source == _Choice.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (file != null) onChanged(file.path);
    } on PlatformException {
      // Usually a denied camera or library permission.
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'We couldn’t open your photos. Check Tm30 Pay’s permissions '
              'in Settings.',
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final path = photoPath;
    return Semantics(
      button: true,
      label: path == null ? 'Add a profile photo' : 'Change profile photo',
      child: GestureDetector(
        onTap: () => _choose(context),
        child: SizedBox.square(
          dimension: 145,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutBack,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            ),
            child: path == null
                ? Image.asset(
                    BrandAssets.photoPlaceholder,
                    key: const ValueKey('placeholder'),
                    width: 145,
                    height: 145,
                  )
                : Center(
                    key: ValueKey(path),
                    child: DecoratedBox(
                      decoration: const ShapeDecoration(
                        shape: RoundedSuperellipseBorder(
                          borderRadius: BorderRadius.all(Radius.circular(36)),
                        ),
                        shadows: [
                          BoxShadow(
                            color: Color(0x40101A8C),
                            blurRadius: 24,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: ClipRSuperellipse(
                        borderRadius: BorderRadius.circular(36),
                        child: Image.file(
                          File(path),
                          width: _photoSize,
                          height: _photoSize,
                          fit: BoxFit.cover,
                          cacheWidth: 336,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

enum _Choice { camera, gallery, remove }
