import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  // Gallery එකෙන් හෝ Camera එකෙන් Photo එකක් Pick කිරීම
  static Future<String?> pickAndSaveImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70, // File size එක අඩු කිරීමට
    );

    if (pickedFile == null) return null;

    // Local Storage Path එක ලබාගැනීම
    final directory = await getApplicationDocumentsDirectory();
    final String fileName = path.basename(pickedFile.path);
    final String savedPath = path.join(directory.path, fileName);

    // Image එක Permanent Local Storage එකට Copy කිරීම
    final File localImage = await File(pickedFile.path).copy(savedPath);
    return localImage.path;
  }
}