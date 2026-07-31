import 'dart:io';

/// `image_picker` paths can go stale (temp cache cleared, app reinstalled),
/// so check the file is actually there before trusting it as an avatar.
File? resolveAvatarFile(String path) {
  if (path.isEmpty) return null;
  final file = File(path);
  return file.existsSync() ? file : null;
}
