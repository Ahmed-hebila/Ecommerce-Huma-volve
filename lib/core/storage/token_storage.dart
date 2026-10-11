import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Saves the auth tokens in the device's secure storage
/// (Keychain on iOS, Keystore on Android).
class TokenStorage {
  TokenStorage._(this._storage);

  static final TokenStorage instance = TokenStorage._(
    const FlutterSecureStorage(),
  );

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _storage;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<bool> hasAccessToken() async {
    try {
      final token = await readAccessToken();
      return token != null && token.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
