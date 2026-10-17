import '../../../../core/storage/token_storage.dart';
import '../models/auth_tokens_model.dart';

/// Keeps the session tokens on the device (secure storage).
abstract class AuthLocalDataSource {
  Future<void> saveTokens(AuthTokensModel tokens);

  Future<String?> getAccessToken();

  Future<String?> getRefreshToken();

  Future<bool> hasAccessToken();

  Future<void> clearTokens();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this.tokenStorage);

  final TokenStorage tokenStorage;

  @override
  Future<void> saveTokens(AuthTokensModel tokens) {
    return tokenStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
  }

  @override
  Future<String?> getAccessToken() => tokenStorage.readAccessToken();

  @override
  Future<String?> getRefreshToken() => tokenStorage.readRefreshToken();

  @override
  Future<bool> hasAccessToken() => tokenStorage.hasAccessToken();

  @override
  Future<void> clearTokens() => tokenStorage.clear();
}
