import 'dart:typed_data';

import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/voice_of_trust_model.dart';

class VoiceOfTrustRepository {
  final DioClient client;
  VoiceOfTrustRepository(this.client);

  Future<List<VoiceOfTrustModel>> getActive() async {
    try {
      final res = await client.dio.get(ApiConstants.voiceOfTrust);
      final data = res.data['data'] as List? ?? [];
      return data.map((j) => VoiceOfTrustModel.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      throw client.toApiException(e);
    }
  }

  Future<List<VoiceOfTrustModel>> getAdminAll() async {
    try {
      final res = await client.dio.get(ApiConstants.voiceOfTrustAdmin);
      final data = res.data['data'] as List? ?? [];
      return data.map((j) => VoiceOfTrustModel.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      throw client.toApiException(e);
    }
  }

  Future<VoiceOfTrustModel> create({
    required String title,
    required String description,
    required int order,
    Uint8List? imageBytes,
    String? fileName,
  }) async {
    try {
      final formData = FormData.fromMap({
        'title': title,
        'description': description,
        'order': order.toString(),
        if (imageBytes != null) 'image': MultipartFile.fromBytes(imageBytes, filename: fileName),
      });
      final res = await client.dio.post(ApiConstants.voiceOfTrust, data: formData);
      return VoiceOfTrustModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw client.toApiException(e);
    }
  }

  Future<VoiceOfTrustModel> update(
    String id, {
    String? title,
    String? description,
    int? order,
    bool? isActive,
    Uint8List? imageBytes,
    String? fileName,
  }) async {
    try {
      final map = <String, dynamic>{
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (order != null) 'order': order.toString(),
        if (isActive != null) 'isActive': isActive.toString(),
        if (imageBytes != null) 'image': MultipartFile.fromBytes(imageBytes, filename: fileName),
      };
      final res = await client.dio.put('${ApiConstants.voiceOfTrust}/$id', data: FormData.fromMap(map));
      return VoiceOfTrustModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw client.toApiException(e);
    }
  }

  Future<void> delete(String id) async {
    try {
      await client.dio.delete('${ApiConstants.voiceOfTrust}/$id');
    } catch (e) {
      throw client.toApiException(e);
    }
  }
}
