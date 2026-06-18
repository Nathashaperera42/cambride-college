import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/voice_of_trust_model.dart';
import 'app_providers.dart';

class VoiceOfTrustState {
  final List<VoiceOfTrustModel> entries;
  final bool loading;
  final String? error;

  const VoiceOfTrustState({this.entries = const [], this.loading = false, this.error});

  VoiceOfTrustState copyWith({List<VoiceOfTrustModel>? entries, bool? loading, String? error}) =>
      VoiceOfTrustState(
        entries: entries ?? this.entries,
        loading: loading ?? this.loading,
        error: error,
      );
}

class VoiceOfTrustNotifier extends StateNotifier<VoiceOfTrustState> {
  final Ref _ref;
  VoiceOfTrustNotifier(this._ref) : super(const VoiceOfTrustState());

  Future<void> loadActive() async {
    state = state.copyWith(loading: true);
    try {
      final entries = await _ref.read(voiceOfTrustRepositoryProvider).getActive();
      state = state.copyWith(loading: false, entries: entries);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> loadAdminAll() async {
    state = state.copyWith(loading: true);
    try {
      final entries = await _ref.read(voiceOfTrustRepositoryProvider).getAdminAll();
      state = state.copyWith(loading: false, entries: entries);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<bool> create({
    required String title,
    required String description,
    required int order,
    Uint8List? imageBytes,
    String? fileName,
  }) async {
    try {
      final entry = await _ref.read(voiceOfTrustRepositoryProvider).create(
            title: title,
            description: description,
            order: order,
            imageBytes: imageBytes,
            fileName: fileName,
          );
      state = state.copyWith(entries: [...state.entries, entry]);
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
    required int order,
    required bool isActive,
    Uint8List? imageBytes,
    String? fileName,
  }) async {
    try {
      final entry = await _ref.read(voiceOfTrustRepositoryProvider).update(
            id,
            title: title,
            description: description,
            order: order,
            isActive: isActive,
            imageBytes: imageBytes,
            fileName: fileName,
          );
      state = state.copyWith(entries: state.entries.map((e) => e.id == id ? entry : e).toList());
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await _ref.read(voiceOfTrustRepositoryProvider).delete(id);
      state = state.copyWith(entries: state.entries.where((e) => e.id != id).toList());
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final voiceOfTrustProvider = StateNotifierProvider<VoiceOfTrustNotifier, VoiceOfTrustState>(
  (ref) => VoiceOfTrustNotifier(ref),
);
