abstract final class AppRoutes {
  AppRoutes._();

  static const login = '/login';
  static const dashboard = '/dashboard';
  static const tenants = '/tenants';
  static const tenantsNew = '/tenants/new';
  static const plans = '/plans';
  static const invoices = '/invoices';

  static String tenantSubscriptionPath(String tenantId) =>
      '/tenants/$tenantId/subscription';

  static String subscriptionInvoicePath(String invoiceId) =>
      '/invoices/$invoiceId';
}
