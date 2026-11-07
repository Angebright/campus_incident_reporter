import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../config/cloudinary_config.dart';
import 'image_upload_service.dart';

/// Thrown when a Cloudinary upload fails.
class ImageUploadException implements Exception {
  const ImageUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Uploads images to Cloudinary using an unsigned upload preset.
class CloudinaryImageUploadService implements ImageUploadService {
  CloudinaryImageUploadService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<String> upload({
    required Uint8List bytes,
    required String filename,
  }) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = CloudinaryConfig.uploadPreset
      ..fields['folder'] = CloudinaryConfig.folder;
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: filename),
    );

    final response = await _client.send(request);
    final body = await response.stream.bytesToString();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ImageUploadException(
        'Upload failed with status ${response.statusCode}.',
      );
    }

    final data = jsonDecode(body);
    final url = data is Map<String, dynamic>
        ? data['secure_url'] as String?
        : null;
    if (url == null || url.trim().isEmpty) {
      throw const ImageUploadException(
        'The upload did not return an image URL.',
      );
    }
    return url;
  }
}
