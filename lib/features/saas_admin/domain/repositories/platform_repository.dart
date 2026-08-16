import '../entities/generate_subscription_invoice_data.dart';
import '../entities/mark_invoice_paid_data.dart';
import '../entities/platform_dashboard.dart';
import '../entities/platform_tenant.dart';
import '../entities/subscription_invoice.dart';
import '../entities/subscription_invoice_filters.dart';
import '../entities/subscription_invoice_page.dart';
import '../entities/subscription_plan.dart';
import '../entities/tenant_create_result.dart';
import '../entities/tenant_form_data.dart';
import '../entities/tenant_subscription.dart';

abstract class PlatformRepository {
  Future<List<PlatformTenant>> listTenants();

  Future<TenantCreateResult> createTenant(TenantFormData data);

  Future<TenantSubscription?> getTenantSubscription(String tenantId);

  Future<TenantSubscription> assignTenantSubscription(
    String tenantId,
    TenantSubscriptionAssignData data,
  );

  Future<List<SubscriptionPlan>> listSubscriptionPlans({bool activeOnly = false});

  Future<SubscriptionPlan> createSubscriptionPlan({
    required String name,
    required String priceMonthly,
    String? priceAnnual,
    int? maxUsers,
    int? maxStudents,
    Map<String, bool>? featureFlags,
  });

  Future<PlatformDashboard> getDashboard();

  Future<SubscriptionInvoicePage> getSubscriptionInvoices({
    required SubscriptionInvoiceFilters filters,
    required int page,
    int pageSize = 25,
  });

  Future<List<SubscriptionInvoice>> generateInvoice(
    GenerateSubscriptionInvoiceData data,
  );

  Future<SubscriptionInvoice> markInvoicePaid(
    String id,
    MarkInvoicePaidData data,
  );

  Future<SubscriptionInvoice> getSubscriptionInvoice(String id);
}
