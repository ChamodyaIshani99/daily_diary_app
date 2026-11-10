import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  // Pick multiple images at once
  static Future<List<String>> pickMultipleImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage(
      imageQuality: 70,
    );

    if (pickedFiles.isEmpty) return [];

    List<String> savedPaths = [];
    final directory = await getApplicationDocumentsDirectory();

    for (var file in pickedFiles) {
      final String fileName = path.basename(file.path);
      final String savedPath = path.join(directory.path, fileName);
      final File localImage = await File(file.path).copy(savedPath);
      savedPaths.add(localImage.path);
    }

    return savedPaths;
  }
}