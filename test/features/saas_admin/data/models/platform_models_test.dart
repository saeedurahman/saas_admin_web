import 'package:flutter_test/flutter_test.dart';
import 'package:saas_admin_web/features/saas_admin/data/models/platform_models.dart';
import 'package:saas_admin_web/features/saas_admin/domain/entities/generate_subscription_invoice_data.dart';
import 'package:saas_admin_web/features/saas_admin/domain/entities/mark_invoice_paid_data.dart';
import 'package:saas_admin_web/features/saas_admin/domain/entities/subscription_invoice_filters.dart';

void main() {
  group('TenantCreateResponseModel', () {
    test('fromJson parses tenant, admin, and temp password', () {
      final model = TenantCreateResponseModel.fromJson({
        'tenant': {
          'id': 't1',
          'name': 'New School',
          'slug': 'new-school',
          'logo_url': null,
          'address': 'Street 1',
          'contact_phone': null,
          'contact_email': 'info@school.com',
          'status': 'trial',
        },
        'admin_user': {
          'id': 'u1',
          'email': 'admin@school.com',
          'full_name': 'Admin User',
          'phone': null,
          'is_active': true,
          'tenant_id': 't1',
        },
        'temp_password': 'TempPass123!',
      });

      expect(model.tenant.slug, 'new-school');
      expect(model.adminUser.email, 'admin@school.com');
      expect(model.tempPassword, 'TempPass123!');
      expect(model.toEntity().tenant.name, 'New School');
    });
  });

  group('PlatformTenantModel', () {
    test('fromJson parses enriched list fields', () {
      final model = PlatformTenantModel.fromJson({
        'id': 't1',
        'name': 'School',
        'slug': 'school',
        'status': 'active',
        'plan_name': 'Standard',
        'subscription_status': 'active',
      });

      expect(model.planName, 'Standard');
      expect(model.subscriptionStatus, 'active');
      expect(model.toEntity().planName, 'Standard');
    });
  });

  group('SubscriptionPlanModel', () {
    test('fromJson parses decimal prices as strings', () {
      final model = SubscriptionPlanModel.fromJson({
        'id': 'p1',
        'name': 'Standard',
        'price_monthly': '1000.00',
        'price_annual': '10000.00',
        'max_users': 50,
        'max_students': 500,
        'feature_flags': {'hostel': true},
        'is_active': true,
      });

      expect(model.priceMonthly, '1000.00');
      expect(model.featureFlags['hostel'], isTrue);
      expect(model.toEntity().name, 'Standard');
    });
  });

  group('TenantSubscriptionModel', () {
    test('fromJson parses nested plan', () {
      final model = TenantSubscriptionModel.fromJson({
        'id': 's1',
        'tenant_id': 't1',
        'plan_id': 'p1',
        'billing_cycle': 'monthly',
        'status': 'trial',
        'trial_ends_at': '2026-09-01',
        'current_period_start': '2026-08-15',
        'current_period_end': '2026-09-15',
        'next_billing_date': '2026-09-15',
        'plan': {
          'id': 'p1',
          'name': 'Standard',
          'price_monthly': '1000.00',
          'price_annual': null,
          'max_users': null,
          'max_students': null,
          'feature_flags': {},
          'is_active': true,
        },
      });

      expect(model.plan?.name, 'Standard');
      expect(model.toEntity().billingCycle, 'monthly');
    });
  });

  group('SubscriptionInvoiceModel', () {
    test('fromJson parses string amount as Money', () {
      final model = SubscriptionInvoiceModel.fromJson({
        'id': 'inv1',
        'tenant_id': 't1',
        'tenant_name': 'Demo School',
        'subscription_id': 's1',
        'invoice_number': 'SUB-2026-0001',
        'amount': '2500.00',
        'billing_period_label': '2026-08',
        'due_date': '2026-08-31',
        'status': 'unpaid',
        'paid_date': null,
        'payment_method': null,
        'reference_number': null,
        'created_at': '2026-08-01T10:00:00Z',
      });

      expect(model.amount.formatDisplay(), '2500.00');
      expect(model.tenantName, 'Demo School');
      expect(model.toEntity().invoiceNumber, 'SUB-2026-0001');
    });
  });

  group('SubscriptionInvoiceListResponseModel', () {
    test('fromJson parses pagination fields', () {
      final model = SubscriptionInvoiceListResponseModel.fromJson({
        'items': [
          {
            'id': 'inv1',
            'tenant_id': 't1',
            'tenant_name': 'Demo School',
            'subscription_id': 's1',
            'invoice_number': 'SUB-2026-0001',
            'amount': '2500.00',
            'billing_period_label': '2026-08',
            'due_date': '2026-08-31',
            'status': 'unpaid',
            'paid_date': null,
            'payment_method': null,
            'reference_number': null,
            'created_at': '2026-08-01T10:00:00Z',
          },
        ],
        'total_count': 1,
      });

      final page = model.toEntity(page: 0, pageSize: 25);
      expect(page.items.length, 1);
      expect(page.totalCount, 1);
      expect(page.hasMore, isFalse);
    });
  });

  group('PlatformDashboardModel', () {
    test('fromJson parses dashboard totals', () {
      final model = PlatformDashboardModel.fromJson({
        'total_tenants': 3,
        'tenant_status_counts': {'active': 2, 'trial': 1},
        'subscription_status_counts': {'active': 2, 'trial': 1},
        'mrr_estimate': 1500.5,
      });

      final entity = model.toEntity();
      expect(entity.totalTenants, 3);
      expect(entity.tenantStatusCounts['active'], 2);
      expect(entity.mrrEstimate, 1500.5);
    });
  });

  group('SubscriptionInvoiceJson', () {
    test('generatePayload serializes billing period and due date', () {
      final payload = SubscriptionInvoiceJson.generatePayload(
        GenerateSubscriptionInvoiceData(
          billingPeriodLabel: '2026-08',
          dueDate: DateTime(2026, 8, 31),
          tenantId: 't1',
        ),
      );

      expect(payload['billing_period_label'], '2026-08');
      expect(payload['due_date'], '2026-08-31');
      expect(payload['tenant_id'], 't1');
    });

    test('markPaidPayload serializes payment fields', () {
      final payload = SubscriptionInvoiceJson.markPaidPayload(
        MarkInvoicePaidData(
          paymentMethod: 'bank_transfer',
          referenceNumber: 'TXN-123',
          paidDate: DateTime(2026, 8, 20),
        ),
      );

      expect(payload['payment_method'], 'bank_transfer');
      expect(payload['reference_number'], 'TXN-123');
      expect(payload['paid_date'], '2026-08-20');
    });

    test('invoiceFilters serializes skip, limit, and filters', () {
      final payload = SubscriptionInvoiceJson.invoiceFilters(
        const SubscriptionInvoiceFilters(
          tenantId: 't1',
          status: 'unpaid',
        ),
        skip: 25,
        limit: 25,
      );

      expect(payload['skip'], 25);
      expect(payload['limit'], 25);
      expect(payload['tenant_id'], 't1');
      expect(payload['status'], 'unpaid');
    });
  });
}
