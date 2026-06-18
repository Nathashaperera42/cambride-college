import 'dart:typed_data';

import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/website_asset_model.dart';

class WebsiteAssetRepository {
  final DioClient client;
  WebsiteAssetRepository(this.client);

  Future<List<WebsiteAssetModel>> getActive({String? assetType}) async {
    try {
      final res = await client.dio.get(
        ApiConstants.websiteAssets,
        queryParameters: {if (assetType != null) 'assetType': assetType},
      );
      final data = res.data['data'] as List? ?? [];
      return data.map((j) => WebsiteAssetModel.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      throw client.toApiException(e);
    }
  }

  Future<List<WebsiteAssetModel>> getAdminAll() async {
    try {
      final res = await client.dio.get(ApiConstants.websiteAssetsAdmin);
      final data = res.data['data'] as List? ?? [];
      return data.map((j) => WebsiteAssetModel.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      throw client.toApiException(e);
    }
  }

  Future<WebsiteAssetModel> create({
    required String assetType,
    String? title,
    String? redirectUrl,
    required int sortOrder,
    Uint8List? imageBytes,
    String? imageFileName,
    Uint8List? videoBytes,
    String? videoFileName,
  }) async {
    try {
      final formData = FormData.fromMap({
        'assetType': assetType,
        if (title != null) 'title': title,
        if (redirectUrl != null) 'redirectUrl': redirectUrl,
        'sortOrder': sortOrder.toString(),
        if (imageBytes != null) 'image': MultipartFile.fromBytes(imageBytes, filename: imageFileName),
        if (videoBytes != null) 'video': MultipartFile.fromBytes(videoBytes, filename: videoFileName),
      });
      final res = await client.dio.post(ApiConstants.websiteAssets, data: formData);
      return WebsiteAssetModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw client.toApiException(e);
    }
  }

  Future<WebsiteAssetModel> update(
    String id, {
    String? title,
    String? redirectUrl,
    int? sortOrder,
    String? status,
    Uint8List? imageBytes,
    String? imageFileName,
    Uint8List? videoBytes,
    String? videoFileName,
  }) async {
    try {
      final map = <String, dynamic>{
        if (title != null) 'title': title,
        if (redirectUrl != null) 'redirectUrl': redirectUrl,
        if (sortOrder != null) 'sortOrder': sortOrder.toString(),
        if (status != null) 'status': status,
        if (imageBytes != null) 'image': MultipartFile.fromBytes(imageBytes, filename: imageFileName),
        if (videoBytes != null) 'video': MultipartFile.fromBytes(videoBytes, filename: videoFileName),
      };
      final res = await client.dio.put('${ApiConstants.websiteAssets}/$id', data: FormData.fromMap(map));
      return WebsiteAssetModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw client.toApiException(e);
    }
  }

  Future<void> delete(String id) async {
    try {
      await client.dio.delete('${ApiConstants.websiteAssets}/$id');
    } catch (e) {
      throw client.toApiException(e);
    }
  }
}
