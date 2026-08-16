import 'package:equatable/equatable.dart';

import 'user.dart';

class AuthSession extends Equatable {
  const AuthSession({
    required this.user,
    required this.roles,
    required this.permissions,
  });

  final User user;
  final List<String> roles;
  final List<String> permissions;

  @override
  List<Object?> get props => [user, roles, permissions];
}
