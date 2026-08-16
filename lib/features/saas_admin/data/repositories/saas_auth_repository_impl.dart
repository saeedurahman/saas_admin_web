import '../../../../core/storage/preferences_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../auth/data/models/auth_models.dart';
import '../../../auth/domain/entities/auth_session.dart';
import '../../domain/entities/saas_session.dart';
import '../../domain/repositories/saas_auth_repository.dart';
import '../datasources/saas_auth_remote_data_source.dart';

class SaasAuthRepositoryImpl implements SaasAuthRepository {
  SaasAuthRepositoryImpl(
    this._remote,
    this._secureStorage,
    this._preferences,
  );

  final SaasAuthRemoteDataSource _remote;
  final SecureStorageService _secureStorage;
  final PreferencesService _preferences;

  @override
  Future<SaasSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _remote.login(email: email, password: password);

    await _secureStorage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );

    final session = _sessionFromLogin(response);
    await _cacheSession(session, response.user);
    return session;
  }

  @override
  Future<SaasSession?> restoreSessionFromCache() async {
    final accessToken = await _secureStorage.getAccessToken();
    if (accessToken == null) return null;

    final cached = await _preferences.getCachedSession();
    if (cached == null) return null;

    return AuthSession(
      user: UserModel.fromJson(cached.userJson).toEntity(),
      roles: cached.roles,
      permissions: cached.permissions,
    );
  }

  @override
  Future<SaasSession?> fetchRemoteSession() async {
    final accessToken = await _secureStorage.getAccessToken();
    if (accessToken == null) return null;

    final me = await _remote.fetchMe();
    final session = AuthSession(
      user: me.user.toEntity(),
      roles: me.roles,
      permissions: me.permissions,
    );

    await _cacheSession(session, me.user);
    return session;
  }

  @override
  Future<void> logout() async {
    final refresh = await _secureStorage.getRefreshToken();
    if (refresh != null) {
      try {
        await _remote.logout(refreshToken: refresh);
      } catch (_) {}
    }
    await _secureStorage.clearTokens();
    await _preferences.clearSession();
  }

  AuthSession _sessionFromLogin(LoginResponseModel response) {
    return AuthSession(
      user: response.user.toEntity(),
      roles: response.roles,
      permissions: response.permissions,
    );
  }

  Future<void> _cacheSession(AuthSession session, UserModel userModel) async {
    await _preferences.saveCachedSession(
      CachedSessionData(
        userJson: userModel.toJson(),
        roles: session.roles,
        permissions: session.permissions,
      ),
    );
  }
}
