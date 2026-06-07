import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Wraps flutter_secure_storage for JWT persistence.
// Falls back to in-memory storage when the browser blocks IndexedDB
// (e.g. Edge strict tracking prevention on localhost).
class StorageService {
  static const _tokenKey = 'auth_token';
  final FlutterSecureStorage _storage;
  String? _memoryToken;

  StorageService([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    _memoryToken = token;
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (_) {}
  }

  Future<String?> readToken() async {
    if (_memoryToken != null) return _memoryToken;
    try {
      return await _storage.read(key: _tokenKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    _memoryToken = null;
    try {
      await _storage.delete(key: _tokenKey);
    } catch (_) {}
  }
}
