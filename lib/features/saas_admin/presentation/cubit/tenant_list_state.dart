import 'package:equatable/equatable.dart';

import '../../domain/entities/platform_tenant.dart';

sealed class TenantListState extends Equatable {
  const TenantListState();

  @override
  List<Object?> get props => [];
}

class TenantListLoading extends TenantListState {
  const TenantListLoading();
}

class TenantListLoaded extends TenantListState {
  const TenantListLoaded({
    required this.tenants,
    required this.canCreate,
  });

  final List<PlatformTenant> tenants;
  final bool canCreate;

  @override
  List<Object?> get props => [tenants, canCreate];
}

class TenantListError extends TenantListState {
  const TenantListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
