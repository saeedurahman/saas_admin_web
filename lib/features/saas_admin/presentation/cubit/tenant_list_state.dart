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
    this.canEdit = false,
    this.updatingTenantId,
    this.actionError,
  });

  final List<PlatformTenant> tenants;
  final bool canCreate;
  final bool canEdit;

  /// Tenant whose status change is in flight, if any.
  final String? updatingTenantId;

  /// Message from the last failed status change; cleared by the next emit.
  final String? actionError;

  TenantListLoaded copyWith({
    String? updatingTenantId,
    bool clearUpdating = false,
    String? actionError,
  }) {
    return TenantListLoaded(
      tenants: tenants,
      canCreate: canCreate,
      canEdit: canEdit,
      updatingTenantId:
          clearUpdating ? null : updatingTenantId ?? this.updatingTenantId,
      actionError: actionError,
    );
  }

  @override
  List<Object?> get props => [
        tenants,
        canCreate,
        canEdit,
        updatingTenantId,
        actionError,
      ];
}

class TenantListError extends TenantListState {
  const TenantListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
