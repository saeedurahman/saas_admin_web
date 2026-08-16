import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:madaris_core/cubit/safe_cubit.dart';
import '../../domain/entities/platform_tenant.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/entities/tenant_subscription.dart';
import '../../domain/repositories/platform_repository.dart';
import 'tenant_subscription_state.dart';

class TenantSubscriptionCubit extends Cubit<TenantSubscriptionState>
    with SafeCubitMixin {
  TenantSubscriptionCubit(
    this._repository, {
    required this.permissions,
  }) : super(const TenantSubscriptionLoading());

  final PlatformRepository _repository;
  final List<String> permissions;

  Future<void> load(PlatformTenant tenant) async {
    emit(const TenantSubscriptionLoading());
    await runGuarded(
      () async {
        final results = await Future.wait([
          _repository.getTenantSubscription(tenant.id),
          _repository.listSubscriptionPlans(activeOnly: true),
        ]);
        final subscription = results[0] as TenantSubscription?;
        final plans = results[1] as List<SubscriptionPlan>;

        final defaultPlanId = subscription?.planId ??
            (plans.isNotEmpty ? plans.first.id : '');

        emit(
          TenantSubscriptionEditing(
            tenant: tenant,
            plans: plans,
            existingSubscription: subscription,
            canEdit: permissions.contains('tenant_subscriptions:edit'),
            formData: TenantSubscriptionAssignData(
              planId: defaultPlanId,
              billingCycle: subscription?.billingCycle ?? 'monthly',
              status: subscription?.status ?? 'trial',
              trialEndsAt: subscription?.trialEndsAt,
              currentPeriodStart: subscription?.currentPeriodStart,
            ),
          ),
        );
      },
      onError: (error) => emit(TenantSubscriptionError(error.message)),
    );
  }

  void updateForm(TenantSubscriptionAssignData data) {
    final current = state;
    if (current is TenantSubscriptionEditing) {
      emit(current.copyWith(formData: data));
    }
  }

  Future<void> submit() async {
    final current = state;
    if (current is! TenantSubscriptionEditing) return;
    if (current.formData.planId.isEmpty) {
      emit(TenantSubscriptionError('Select a subscription plan'));
      emit(current);
      return;
    }

    emit(current.copyWith(isSubmitting: true));
    await runGuarded(
      () async {
        final subscription = await _repository.assignTenantSubscription(
          current.tenant.id,
          current.formData,
        );
        emit(TenantSubscriptionSuccess(subscription));
        emit(current.copyWith(
          existingSubscription: subscription,
          isSubmitting: false,
          formData: TenantSubscriptionAssignData(
            planId: subscription.planId,
            billingCycle: subscription.billingCycle,
            status: subscription.status,
            trialEndsAt: subscription.trialEndsAt,
            currentPeriodStart: subscription.currentPeriodStart,
          ),
        ));
      },
      onError: (error) {
        emit(TenantSubscriptionError(error.message));
        emit(current.copyWith(isSubmitting: false));
      },
    );
  }
}
