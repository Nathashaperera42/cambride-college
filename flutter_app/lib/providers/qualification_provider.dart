import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/qualification_model.dart';
import 'app_providers.dart';

class QualificationState {
  final List<QualificationModel> qualifications;
  final bool loading;
  final String? error;

  const QualificationState({this.qualifications = const [], this.loading = false, this.error});

  QualificationState copyWith({List<QualificationModel>? qualifications, bool? loading, String? error}) =>
      QualificationState(
        qualifications: qualifications ?? this.qualifications,
        loading: loading ?? this.loading,
        error: error,
      );
}

class QualificationNotifier extends StateNotifier<QualificationState> {
  final Ref _ref;
  QualificationNotifier(this._ref) : super(const QualificationState());

  Future<void> loadActive() async {
    state = state.copyWith(loading: true);
    try {
      final list = await _ref.read(qualificationRepositoryProvider).getActive();
      state = state.copyWith(loading: false, qualifications: list);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> loadAdminAll() async {
    state = state.copyWith(loading: true);
    try {
      final list = await _ref.read(qualificationRepositoryProvider).getAdminAll();
      state = state.copyWith(loading: false, qualifications: list);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<bool> create({
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
      final item = await _ref.read(qualificationRepositoryProvider).create(
            title: title,
            description: description,
            features: features,
            gold: gold,
            redirectUrl: redirectUrl,
            order: order,
            imageBytes: imageBytes,
            fileName: fileName,
          );
      state = state.copyWith(qualifications: [...state.qualifications, item]);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> update(
    String id, {
    required String title,
    required String description,
    required List<String> features,
    required bool gold,
    String? redirectUrl,
    required int order,
    required bool isActive,
    Uint8List? imageBytes,
    String? fileName,
  }) async {
    try {
      final item = await _ref.read(qualificationRepositoryProvider).update(
            id,
            title: title,
            description: description,
            features: features,
            gold: gold,
            redirectUrl: redirectUrl,
            order: order,
            isActive: isActive,
            imageBytes: imageBytes,
            fileName: fileName,
          );
      state = state.copyWith(
        qualifications: state.qualifications.map((q) => q.id == id ? item : q).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await _ref.read(qualificationRepositoryProvider).delete(id);
      state = state.copyWith(qualifications: state.qualifications.where((q) => q.id != id).toList());
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final qualificationProvider = StateNotifierProvider<QualificationNotifier, QualificationState>(
  (ref) => QualificationNotifier(ref),
);
