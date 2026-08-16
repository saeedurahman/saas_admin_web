import 'package:equatable/equatable.dart';

import '../../domain/entities/platform_tenant.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/entities/tenant_subscription.dart';

sealed class TenantSubscriptionState extends Equatable {
  const TenantSubscriptionState();

  @override
  List<Object?> get props => [];
}

class TenantSubscriptionLoading extends TenantSubscriptionState {
  const TenantSubscriptionLoading();
}

class TenantSubscriptionEditing extends TenantSubscriptionState {
  const TenantSubscriptionEditing({
    required this.tenant,
    required this.plans,
    required this.formData,
    this.existingSubscription,
    this.isSubmitting = false,
    this.canEdit = true,
  });

  final PlatformTenant tenant;
  final List<SubscriptionPlan> plans;
  final TenantSubscriptionAssignData formData;
  final TenantSubscription? existingSubscription;
  final bool isSubmitting;
  final bool canEdit;

  TenantSubscriptionEditing copyWith({
    PlatformTenant? tenant,
    List<SubscriptionPlan>? plans,
    TenantSubscriptionAssignData? formData,
    TenantSubscription? existingSubscription,
    bool? isSubmitting,
    bool? canEdit,
  }) {
    return TenantSubscriptionEditing(
      tenant: tenant ?? this.tenant,
      plans: plans ?? this.plans,
      formData: formData ?? this.formData,
      existingSubscription: existingSubscription ?? this.existingSubscription,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      canEdit: canEdit ?? this.canEdit,
    );
  }

  @override
  List<Object?> get props => [
        tenant,
        plans,
        formData,
        existingSubscription,
        isSubmitting,
        canEdit,
      ];
}

class TenantSubscriptionSuccess extends TenantSubscriptionState {
  const TenantSubscriptionSuccess(this.subscription);

  final TenantSubscription subscription;

  @override
  List<Object?> get props => [subscription];
}

class TenantSubscriptionError extends TenantSubscriptionState {
  const TenantSubscriptionError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
