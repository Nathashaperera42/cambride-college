import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/models.dart';

class SiteImageRepository {
  final DioClient client;
  SiteImageRepository(this.client);

  Future<List<SiteImage>> getAdminImages({String? section}) async {
    try {
      final res = await client.dio.get(
        ApiConstants.siteImagesAdmin,
        queryParameters: {if (section != null) 'section': section},
      );
      final data = res.data['data'] as List? ?? [];
      return data
          .map((j) => SiteImage.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw client.toApiException(e);
    }
  }

  Future<SiteImage> createImage({
    required String section,
    required String label,
    required String altText,
    required int order,
    required List<int> imageBytes,
    required String fileName,
  }) async {
    try {
      final formData = FormData.fromMap({
        'section': section,
        'label': label,
        'altText': altText,
        'order': order.toString(),
        'image': MultipartFile.fromBytes(imageBytes, filename: fileName),
      });
      final res = await client.dio.post(ApiConstants.siteImages, data: formData);
      return SiteImage.fromJson(res.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw client.toApiException(e);
    }
  }

  Future<SiteImage> updateImage(
    String id, {
    String? label,
    String? altText,
    int? order,
    bool? isActive,
    List<int>? imageBytes,
    String? fileName,
  }) async {
    try {
      final map = <String, dynamic>{
        if (label != null) 'label': label,
        if (altText != null) 'altText': altText,
        if (order != null) 'order': order.toString(),
        if (isActive != null) 'isActive': isActive.toString(),
        if (imageBytes != null)
          'image': MultipartFile.fromBytes(imageBytes, filename: fileName),
      };
      final res = await client.dio.put(
        '${ApiConstants.siteImages}/$id',
        data: FormData.fromMap(map),
      );
      return SiteImage.fromJson(res.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw client.toApiException(e);
    }
  }

  Future<void> deleteImage(String id) async {
    try {
      await client.dio.delete('${ApiConstants.siteImages}/$id');
    } catch (e) {
      throw client.toApiException(e);
    }
  }
}
