import 'package:madaris_core/errors/app_exception.dart';
import 'package:saas_admin_web/features/auth/domain/entities/user.dart';
import 'package:saas_admin_web/features/saas_admin/domain/entities/platform_tenant.dart';
import 'package:saas_admin_web/features/saas_admin/domain/entities/subscription_plan.dart';
import 'package:saas_admin_web/features/saas_admin/domain/entities/subscription_plan_update_data.dart';
import 'package:saas_admin_web/features/saas_admin/domain/entities/tenant_create_result.dart';
import 'package:saas_admin_web/features/saas_admin/domain/entities/tenant_form_data.dart';
import 'package:saas_admin_web/features/saas_admin/domain/entities/tenant_subscription.dart';
import 'package:saas_admin_web/features/saas_admin/domain/repositories/platform_repository.dart';

/// In-memory [PlatformRepository] for cubit/widget tests. Only the calls the
/// tests exercise are implemented; anything else fails loudly.
class FakePlatformRepository implements PlatformRepository {
  FakePlatformRepository({
    List<PlatformTenant>? tenants,
    List<SubscriptionPlan>? plans,
  })  : tenants = tenants ?? [],
        plans = plans ?? [];

  List<PlatformTenant> tenants;
  List<SubscriptionPlan> plans;

  /// When set, the next mutating call throws it (then clears it).
  AppException? failNextWith;

  final List<(String, String)> tenantStatusCalls = [];
  final List<TenantFormData> createTenantCalls = [];
  final List<(String, SubscriptionPlanUpdateData)> planUpdateCalls = [];
  final List<String> retireCalls = [];
  final List<TenantSubscriptionAssignData> assignCalls = [];
  TenantSubscription? subscription;

  void _maybeFail() {
    final error = failNextWith;
    if (error != null) {
      failNextWith = null;
      throw error;
    }
  }

  @override
  Future<List<PlatformTenant>> listTenants() async => List.of(tenants);

  @override
  Future<TenantCreateResult> createTenant(TenantFormData data) async {
    _maybeFail();
    createTenantCalls.add(data);
    final tenant = PlatformTenant(
      id: 'new-${tenants.length + 1}',
      name: data.name,
      slug: data.slug,
      status: 'trial',
      tenantType: data.tenantType,
    );
    tenants = [...tenants, tenant];
    return TenantCreateResult(
      tenant: tenant,
      adminUser: User(
        id: 'u-new',
        email: data.adminEmail,
        fullName: data.adminFullName,
        isActive: true,
      ),
      tempPassword: 'TempPass123!',
    );
  }

  @override
  Future<void> updateTenantStatus(String tenantId, String status) async {
    _maybeFail();
    tenantStatusCalls.add((tenantId, status));
    tenants = [
      for (final tenant in tenants)
        if (tenant.id == tenantId)
          PlatformTenant(
            id: tenant.id,
            name: tenant.name,
            slug: tenant.slug,
            status: status,
            planName: tenant.planName,
            subscriptionStatus: tenant.subscriptionStatus,
            tenantType: tenant.tenantType,
          )
        else
          tenant,
    ];
  }

  @override
  Future<List<SubscriptionPlan>> listSubscriptionPlans({
    bool activeOnly = false,
  }) async =>
      plans.where((plan) => !activeOnly || plan.isActive).toList();

  @override
  Future<SubscriptionPlan> updateSubscriptionPlan(
    String planId,
    SubscriptionPlanUpdateData data,
  ) async {
    _maybeFail();
    planUpdateCalls.add((planId, data));
    final updated = SubscriptionPlan(
      id: planId,
      name: data.name,
      priceMonthly: data.priceMonthly,
      priceAnnual: data.priceAnnual,
      maxUsers: data.maxUsers,
      maxStudents: data.maxStudents,
      featureFlags: data.featureFlags,
      isActive: true,
    );
    plans = [for (final p in plans) p.id == planId ? updated : p];
    return updated;
  }

  @override
  Future<SubscriptionPlan> retireSubscriptionPlan(String planId) async {
    _maybeFail();
    retireCalls.add(planId);
    late SubscriptionPlan retired;
    plans = [
      for (final p in plans)
        if (p.id == planId)
          retired = SubscriptionPlan(
            id: p.id,
            name: p.name,
            priceMonthly: p.priceMonthly,
            priceAnnual: p.priceAnnual,
            maxUsers: p.maxUsers,
            maxStudents: p.maxStudents,
            featureFlags: p.featureFlags,
            isActive: false,
          )
        else
          p,
    ];
    return retired;
  }

  @override
  Future<TenantSubscription?> getTenantSubscription(String tenantId) async =>
      subscription;

  @override
  Future<TenantSubscription> assignTenantSubscription(
    String tenantId,
    TenantSubscriptionAssignData data,
  ) async {
    _maybeFail();
    assignCalls.add(data);
    final start = data.currentPeriodStart ?? DateTime(2026, 1, 1);
    return subscription = TenantSubscription(
      id: 's1',
      tenantId: tenantId,
      planId: data.planId,
      billingCycle: data.billingCycle,
      status: data.status,
      currentPeriodStart: start,
      currentPeriodEnd:
          data.currentPeriodEnd ?? DateTime(start.year, start.month + (data.periodMonths ?? 1), start.day),
      nextBillingDate:
          data.currentPeriodEnd ?? DateTime(start.year, start.month + (data.periodMonths ?? 1), start.day),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
