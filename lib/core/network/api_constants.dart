/// Platform admin API paths.
abstract final class ApiConstants {
  ApiConstants._();

  static const base = '/api/v1';

  static const authLogin = '$base/auth/saas-login';
  static const authLogout = '$base/auth/logout';
  static const authMe = '$base/auth/me/saas';
  static const authRefresh = '$base/auth/refresh';

  static const platformTenants = '$base/platform/tenants';
  static String platformTenant(String tenantId) =>
      '$platformTenants/$tenantId';
  static String platformTenantSubscription(String tenantId) =>
      '$platformTenants/$tenantId/subscription';
  static const platformSubscriptionPlans = '$base/platform/subscription-plans';
  static String platformSubscriptionPlan(String id) =>
      '$platformSubscriptionPlans/$id';
  static const platformDashboard = '$base/platform/dashboard';
  static const platformSubscriptionInvoices = '$base/platform/subscription-invoices';
  static const platformSubscriptionInvoicesGenerate =
      '$platformSubscriptionInvoices/generate';
  static String platformSubscriptionInvoice(String id) =>
      '$platformSubscriptionInvoices/$id';
  static String platformSubscriptionInvoiceMarkPaid(String id) =>
      '$platformSubscriptionInvoices/$id/mark-paid';
}
