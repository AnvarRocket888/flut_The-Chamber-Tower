import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class PhotoService {
  static final ImagePicker _picker = ImagePicker();

  /// Cached documents directory path
  static String? _docsDirPath;

  static Future<String> _getDocsDir() async {
    _docsDirPath ??= (await getApplicationDocumentsDirectory()).path;
    return _docsDirPath!;
  }

  /// Resolve a stored path (filename or old absolute path) to a valid absolute path.
  /// Returns null if the file doesn't exist.
  static Future<String?> resolvePhotoPath(String? storedPath) async {
    if (storedPath == null) return null;
    // If stored path is just a filename, prepend docs dir
    if (!storedPath.contains('/')) {
      final dir = await _getDocsDir();
      final full = '$dir/$storedPath';
      return File(full).existsSync() ? full : null;
    }
    // Full absolute path — check if it exists
    if (File(storedPath).existsSync()) return storedPath;
    // Try extracting filename and looking in current docs dir
    final fileName = storedPath.split('/').last;
    final dir = await _getDocsDir();
    final full = '$dir/$fileName';
    return File(full).existsSync() ? full : null;
  }

  /// Synchronous resolve when docs dir is already cached
  static String? resolvePhotoPathSync(String? storedPath) {
    if (storedPath == null || _docsDirPath == null) return storedPath;
    if (!storedPath.contains('/')) {
      final full = '$_docsDirPath/$storedPath';
      return File(full).existsSync() ? full : null;
    }
    if (File(storedPath).existsSync()) return storedPath;
    final fileName = storedPath.split('/').last;
    final full = '$_docsDirPath/$fileName';
    return File(full).existsSync() ? full : null;
  }

  /// Warm up the cached docs directory path
  static Future<void> init() async {
    await _getDocsDir();
  }

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
    final dir = await _getDocsDir();
    final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedPath = '$dir/$fileName';
    final bytes = await image.readAsBytes();
    await File(savedPath).writeAsBytes(bytes);
    // Return just the filename — immune to container UUID changes
    return fileName;
  }
}
