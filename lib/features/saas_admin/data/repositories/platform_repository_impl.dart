import '../../domain/entities/generate_subscription_invoice_data.dart';
import '../../domain/entities/mark_invoice_paid_data.dart';
import '../../domain/entities/platform_dashboard.dart';
import '../../domain/entities/platform_tenant.dart';
import '../../domain/entities/subscription_invoice.dart';
import '../../domain/entities/subscription_invoice_filters.dart';
import '../../domain/entities/subscription_invoice_page.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/entities/tenant_create_result.dart';
import '../../domain/entities/tenant_form_data.dart';
import '../../domain/entities/tenant_subscription.dart';
import '../../domain/repositories/platform_repository.dart';
import '../datasources/platform_remote_data_source.dart';
import '../models/platform_models.dart';

class PlatformRepositoryImpl implements PlatformRepository {
  PlatformRepositoryImpl(this._remote);

  final PlatformRemoteDataSource _remote;

  @override
  Future<List<PlatformTenant>> listTenants() async {
    final models = await _remote.fetchTenants();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<TenantCreateResult> createTenant(TenantFormData data) async {
    final body = TenantFormJson.toCreateJson(
      name: data.name.trim(),
      slug: data.slug.trim(),
      address: data.address.trim(),
      contactEmail: data.contactEmail.trim(),
      contactPhone: data.contactPhone.trim(),
      adminEmail: data.adminEmail.trim(),
      adminFullName: data.adminFullName.trim(),
      adminPassword: data.adminPassword.trim(),
    );
    final response = await _remote.createTenant(body);
    return response.toEntity();
  }

  @override
  Future<TenantSubscription?> getTenantSubscription(String tenantId) async {
    final model = await _remote.fetchTenantSubscription(tenantId);
    return model?.toEntity();
  }

  @override
  Future<TenantSubscription> assignTenantSubscription(
    String tenantId,
    TenantSubscriptionAssignData data,
  ) async {
    final body = TenantFormJson.subscriptionAssignJson(data);
    final model = await _remote.assignTenantSubscription(tenantId, body);
    return model.toEntity();
  }

  @override
  Future<List<SubscriptionPlan>> listSubscriptionPlans({
    bool activeOnly = false,
  }) async {
    final models =
        await _remote.fetchSubscriptionPlans(activeOnly: activeOnly);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<SubscriptionPlan> createSubscriptionPlan({
    required String name,
    required String priceMonthly,
    String? priceAnnual,
    int? maxUsers,
    int? maxStudents,
    Map<String, bool>? featureFlags,
  }) async {
    final body = SubscriptionPlanModel(
      id: '',
      name: name,
      priceMonthly: priceMonthly,
      priceAnnual: priceAnnual,
      maxUsers: maxUsers,
      maxStudents: maxStudents,
      featureFlags: featureFlags ?? const {},
      isActive: true,
    ).toCreateJson(
      name: name,
      priceMonthly: priceMonthly,
      priceAnnual: priceAnnual,
      maxUsers: maxUsers,
      maxStudents: maxStudents,
      featureFlags: featureFlags,
    );
    final model = await _remote.createSubscriptionPlan(body);
    return model.toEntity();
  }

  @override
  Future<PlatformDashboard> getDashboard() async {
    final model = await _remote.fetchDashboard();
    return model.toEntity();
  }

  @override
  Future<SubscriptionInvoicePage> getSubscriptionInvoices({
    required SubscriptionInvoiceFilters filters,
    required int page,
    int pageSize = 25,
  }) async {
    final response = await _remote.fetchSubscriptionInvoices(
      queryParameters: SubscriptionInvoiceJson.invoiceFilters(
        filters,
        skip: page * pageSize,
        limit: pageSize,
      ),
    );
    return response.toEntity(page: page, pageSize: pageSize);
  }

  @override
  Future<List<SubscriptionInvoice>> generateInvoice(
    GenerateSubscriptionInvoiceData data,
  ) async {
    final models = await _remote.generateSubscriptionInvoices(
      SubscriptionInvoiceJson.generatePayload(data),
    );
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<SubscriptionInvoice> markInvoicePaid(
    String id,
    MarkInvoicePaidData data,
  ) async {
    final model = await _remote.markSubscriptionInvoicePaid(
      id,
      SubscriptionInvoiceJson.markPaidPayload(data),
    );
    return model.toEntity();
  }

  @override
  Future<SubscriptionInvoice> getSubscriptionInvoice(String id) async {
    final model = await _remote.fetchSubscriptionInvoice(id);
    return model.toEntity();
  }
}
