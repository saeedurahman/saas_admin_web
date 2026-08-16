import '../../domain/entities/user.dart';

class UserModel {
  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    required this.isActive,
    this.tenantId,
  });

  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final bool isActive;
  final String? tenantId;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        email: json['email'] as String,
        fullName: json['full_name'] as String,
        phone: json['phone'] as String?,
        isActive: json['is_active'] as bool? ?? true,
        tenantId: json['tenant_id'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        if (phone != null) 'phone': phone,
        'is_active': isActive,
        if (tenantId != null) 'tenant_id': tenantId,
      };

  User toEntity() => User(
        id: id,
        email: email,
        fullName: fullName,
        phone: phone,
        isActive: isActive,
        tenantId: tenantId,
      );
}

class LoginResponseModel {
  LoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.roles,
    required this.permissions,
  });

  final String accessToken;
  final String refreshToken;
  final UserModel user;
  final List<String> roles;
  final List<String> permissions;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      roles: (json['roles'] as List<dynamic>).cast<String>(),
      permissions: (json['permissions'] as List<dynamic>).cast<String>(),
    );
  }
}

class MeResponseModel {
  MeResponseModel({
    required this.user,
    required this.roles,
    required this.permissions,
  });

  final UserModel user;
  final List<String> roles;
  final List<String> permissions;

  factory MeResponseModel.fromJson(Map<String, dynamic> json) => MeResponseModel(
        user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
        roles: (json['roles'] as List<dynamic>).cast<String>(),
        permissions: (json['permissions'] as List<dynamic>).cast<String>(),
      );
}
