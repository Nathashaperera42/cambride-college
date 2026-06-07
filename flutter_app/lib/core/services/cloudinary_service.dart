import 'dart:convert';
import 'package:http/http.dart' as http;

class CloudinaryService {
  // Fill these in from your Cloudinary dashboard.
  static const String cloudName = 'dsypqpuci';
  static const String uploadPreset = 'governess';

  /// Uploads image bytes to Cloudinary and returns the secure HTTPS URL,
  /// or null if the upload failed.
  static Future<String?> uploadImage(
    List<int> bytes,
    String filename,
  ) async {
    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: filename));

    final response = await request.send();
    if (response.statusCode == 200) {
      final body = jsonDecode(await response.stream.bytesToString());
      return body['secure_url'] as String;
    }
    return null;
  }
}
