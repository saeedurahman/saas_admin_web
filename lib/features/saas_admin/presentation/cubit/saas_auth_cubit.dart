import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:madaris_core/cubit/safe_cubit.dart';
import '../../../auth/domain/entities/auth_session.dart';
import '../../domain/repositories/saas_auth_repository.dart';
import 'saas_auth_state.dart';

class SaasAuthCubit extends Cubit<SaasAuthState> with SafeCubitMixin<SaasAuthState> {
  SaasAuthCubit(this._repository) : super(const SaasAuthInitial());

  final SaasAuthRepository _repository;

  Future<void> checkSession() async {
    emit(const SaasAuthLoading());

    final cached = await _repository.restoreSessionFromCache();
    if (cached != null) {
      emit(SaasAuthAuthenticated(session: cached));
      _refreshSessionInBackground(cached);
      return;
    }

    await runGuarded(
      () async {
        final remote = await _repository.fetchRemoteSession();
        if (remote == null) {
          emit(const SaasAuthUnauthenticated());
          return;
        }
        emit(SaasAuthAuthenticated(session: remote));
      },
      onError: (_) => emit(const SaasAuthUnauthenticated()),
    );
  }

  Future<void> _refreshSessionInBackground(AuthSession cached) async {
    await runGuarded(
      () async {
        final remote = await _repository.fetchRemoteSession();
        if (remote == null) {
          await _repository.logout();
          emit(const SaasAuthUnauthenticated());
          return;
        }

        if (!_sessionsEqual(cached, remote)) {
          emit(SaasAuthAuthenticated(session: remote));
        }
      },
      onError: (_) {},
    );
  }

  bool _sessionsEqual(AuthSession a, AuthSession b) {
    return a.user.id == b.user.id &&
        a.roles.length == b.roles.length &&
        a.permissions.length == b.permissions.length;
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(SaasAuthLoading(previousSession: _currentSession));
    await runGuarded(
      () async {
        final session = await _repository.login(
          email: email,
          password: password,
        );
        emit(SaasAuthAuthenticated(session: session));
      },
      onError: (error) => emit(
        SaasAuthError(error.message, previousSession: _currentSession),
      ),
    );
  }

  Future<void> logout() async {
    emit(const SaasAuthLoading());
    await _repository.logout();
    emit(const SaasAuthUnauthenticated());
  }

  AuthSession? get _currentSession {
    final current = state;
    if (current is SaasAuthAuthenticated) return current.session;
    if (current is SaasAuthLoading) return current.previousSession;
    if (current is SaasAuthError) return current.previousSession;
    return null;
  }
}
