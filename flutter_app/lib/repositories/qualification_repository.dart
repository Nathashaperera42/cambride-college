import 'dart:typed_data';

import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/qualification_model.dart';

class QualificationRepository {
  final DioClient client;
  QualificationRepository(this.client);

  Future<List<QualificationModel>> getActive() async {
    try {
      final res = await client.dio.get(ApiConstants.qualifications);
      final data = res.data['data'] as List? ?? [];
      return data.map((j) => QualificationModel.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      throw client.toApiException(e);
    }
  }

  Future<List<QualificationModel>> getAdminAll() async {
    try {
      final res = await client.dio.get(ApiConstants.qualificationsAdmin);
      final data = res.data['data'] as List? ?? [];
      return data.map((j) => QualificationModel.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      throw client.toApiException(e);
    }
  }

  Future<QualificationModel> create({
    required String title,
    required String description,
    required List<String> features,
    required bool gold,
    String? redirectUrl,
    required int order,
    Uint8List? imageBytes,
    String? fileName,
  }) async {
    try {
      final formData = FormData.fromMap({
        'title': title,
        'description': description,
        'features': features.join('\n'),
        'gold': gold.toString(),
        if (redirectUrl != null) 'redirectUrl': redirectUrl,
        'order': order.toString(),
        if (imageBytes != null) 'image': MultipartFile.fromBytes(imageBytes, filename: fileName),
      });
      final res = await client.dio.post(ApiConstants.qualifications, data: formData);
      return QualificationModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw client.toApiException(e);
    }
  }

  Future<QualificationModel> update(
    String id, {
    String? title,
    String? description,
    List<String>? features,
    bool? gold,
    String? redirectUrl,
    int? order,
    bool? isActive,
    Uint8List? imageBytes,
    String? fileName,
  }) async {
    try {
      final map = <String, dynamic>{
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (features != null) 'features': features.join('\n'),
        if (gold != null) 'gold': gold.toString(),
        if (redirectUrl != null) 'redirectUrl': redirectUrl,
        if (order != null) 'order': order.toString(),
        if (isActive != null) 'isActive': isActive.toString(),
        if (imageBytes != null) 'image': MultipartFile.fromBytes(imageBytes, filename: fileName),
      };
      final res = await client.dio.put('${ApiConstants.qualifications}/$id', data: FormData.fromMap(map));
      return QualificationModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw client.toApiException(e);
    }
  }

  Future<void> delete(String id) async {
    try {
      await client.dio.delete('${ApiConstants.qualifications}/$id');
    } catch (e) {
      throw client.toApiException(e);
    }
  }
}
