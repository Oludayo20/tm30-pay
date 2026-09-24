import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Keeps the profile photo in the app's documents folder. image_picker
/// returns a file in a temporary folder that the OS may empty at any time,
/// so the photo is copied here at sign-up. A real backend would upload it
/// instead.
///
/// Only the file name is meaningful across launches: on iOS the documents
/// folder's absolute path changes when the app is updated, so [resolve]
/// re-points a saved path at the current folder.
class ProfilePhotoStore {
  ProfilePhotoStore({Future<Directory> Function()? directory})
    : _directory = directory ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _directory;

  Future<String> save(String sourcePath) async {
    final dir = await _directory();
    final extension = sourcePath.contains('.')
        ? sourcePath.substring(sourcePath.lastIndexOf('.'))
        : '.jpg';
    final target = File(
      '${dir.path}/profile_${DateTime.now().millisecondsSinceEpoch}$extension',
    );
    await File(sourcePath).copy(target.path);
    return target.path;
  }

  /// The saved photo's path in the current documents folder, or null if the
  /// file is gone.
  Future<String?> resolve(String? savedPath) async {
    if (savedPath == null) return null;
    final dir = await _directory();
    final name = savedPath.split(Platform.pathSeparator).last;
    final file = File('${dir.path}/$name');
    return await file.exists() ? file.path : null;
  }

  Future<void> delete(String? path) async {
    if (path == null) return;
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
