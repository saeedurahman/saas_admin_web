import '../entities/saas_session.dart';

abstract class SaasAuthRepository {
  Future<SaasSession> login({
    required String email,
    required String password,
  });

  Future<SaasSession?> restoreSessionFromCache();

  Future<SaasSession?> fetchRemoteSession();

  Future<void> logout();
}
