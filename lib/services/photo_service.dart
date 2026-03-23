import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class PhotoService {
  static final ImagePicker _picker = ImagePicker();

  static Future<String?> takePhoto() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (image == null) return null;
    return _saveToAppDir(image);
  }

  static Future<String?> pickFromGallery() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (image == null) return null;
    return _saveToAppDir(image);
  }

  static Future<String> _saveToAppDir(XFile image) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedPath = '${dir.path}/$fileName';
    final bytes = await image.readAsBytes();
    await File(savedPath).writeAsBytes(bytes);
    return savedPath;
  }
}
