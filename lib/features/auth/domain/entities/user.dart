import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
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

  @override
  List<Object?> get props => [id, email, fullName, phone, isActive, tenantId];
}
