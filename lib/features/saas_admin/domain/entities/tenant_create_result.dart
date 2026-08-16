import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user.dart';
import 'platform_tenant.dart';

class TenantCreateResult extends Equatable {
  const TenantCreateResult({
    required this.tenant,
    required this.adminUser,
    this.tempPassword,
  });

  final PlatformTenant tenant;
  final User adminUser;
  final String? tempPassword;

  @override
  List<Object?> get props => [tenant, adminUser, tempPassword];
}
