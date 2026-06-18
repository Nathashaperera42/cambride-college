import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/website_asset_model.dart';
import 'app_providers.dart';

class WebsiteAssetState {
  final List<WebsiteAssetModel> assets;
  final bool loading;
  final String? error;

  const WebsiteAssetState({this.assets = const [], this.loading = false, this.error});

  WebsiteAssetState copyWith({List<WebsiteAssetModel>? assets, bool? loading, String? error}) =>
      WebsiteAssetState(
        assets: assets ?? this.assets,
        loading: loading ?? this.loading,
        error: error,
      );
}

class WebsiteAssetNotifier extends StateNotifier<WebsiteAssetState> {
  final Ref _ref;
  WebsiteAssetNotifier(this._ref) : super(const WebsiteAssetState());

  Future<void> loadActive({String? assetType}) async {
    state = state.copyWith(loading: true);
    try {
      final list = await _ref.read(websiteAssetRepositoryProvider).getActive(assetType: assetType);
      state = state.copyWith(loading: false, assets: list);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> loadAdminAll() async {
    state = state.copyWith(loading: true);
    try {
      final list = await _ref.read(websiteAssetRepositoryProvider).getAdminAll();
      state = state.copyWith(loading: false, assets: list);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<bool> create({
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
      final asset = await _ref.read(websiteAssetRepositoryProvider).create(
            assetType: assetType,
            title: title,
            redirectUrl: redirectUrl,
            sortOrder: sortOrder,
            imageBytes: imageBytes,
            imageFileName: imageFileName,
            videoBytes: videoBytes,
            videoFileName: videoFileName,
          );
      state = state.copyWith(assets: [...state.assets, asset]);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> update(
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
      final asset = await _ref.read(websiteAssetRepositoryProvider).update(
            id,
            title: title,
            redirectUrl: redirectUrl,
            sortOrder: sortOrder,
            status: status,
            imageBytes: imageBytes,
            imageFileName: imageFileName,
            videoBytes: videoBytes,
            videoFileName: videoFileName,
          );
      state = state.copyWith(assets: state.assets.map((a) => a.id == id ? asset : a).toList());
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await _ref.read(websiteAssetRepositoryProvider).delete(id);
      state = state.copyWith(assets: state.assets.where((a) => a.id != id).toList());
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final websiteAssetProvider = StateNotifierProvider<WebsiteAssetNotifier, WebsiteAssetState>(
  (ref) => WebsiteAssetNotifier(ref),
);
