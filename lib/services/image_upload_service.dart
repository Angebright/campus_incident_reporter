import 'dart:typed_data';

/// Uploads an image and returns its public URL.
abstract class ImageUploadService {
  Future<String> upload({required Uint8List bytes, required String filename});
}
