import 'package:equatable/equatable.dart';

import 'tenant_type_constants.dart';

class PlatformTenant extends Equatable {
  const PlatformTenant({
    required this.id,
    required this.name,
    required this.slug,
    required this.status,
    this.address,
    this.contactEmail,
    this.contactPhone,
    this.planName,
    this.subscriptionStatus,
    this.tenantType = TenantTypeConstants.defaultType,
  });

  final String id;
  final String name;
  final String slug;
  final String status;
  final String? address;
  final String? contactEmail;
  final String? contactPhone;
  final String? planName;
  final String? subscriptionStatus;
  final String tenantType;

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        status,
        address,
        contactEmail,
        contactPhone,
        planName,
        subscriptionStatus,
        tenantType,
      ];
}
