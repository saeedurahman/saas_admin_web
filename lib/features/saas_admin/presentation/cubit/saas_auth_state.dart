import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/auth_session.dart';

sealed class SaasAuthState extends Equatable {
  const SaasAuthState();

  @override
  List<Object?> get props => [];
}

class SaasAuthInitial extends SaasAuthState {
  const SaasAuthInitial();
}

class SaasAuthLoading extends SaasAuthState {
  const SaasAuthLoading({this.previousSession});

  final AuthSession? previousSession;

  @override
  List<Object?> get props => [previousSession];
}

class SaasAuthAuthenticated extends SaasAuthState {
  const SaasAuthAuthenticated({required this.session});

  final AuthSession session;

  @override
  List<Object?> get props => [session];
}

class SaasAuthUnauthenticated extends SaasAuthState {
  const SaasAuthUnauthenticated();
}

class SaasAuthError extends SaasAuthState {
  const SaasAuthError(this.message, {this.previousSession});

  final String message;
  final AuthSession? previousSession;

  @override
  List<Object?> get props => [message, previousSession];
}
