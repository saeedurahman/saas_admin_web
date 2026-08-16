import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/generate_subscription_invoice_data.dart';
import '../../domain/entities/mark_invoice_paid_data.dart';
import '../../domain/entities/platform_dashboard.dart';
import '../../domain/entities/platform_tenant.dart';
import '../../domain/entities/subscription_invoice.dart';
import '../../domain/entities/subscription_invoice_filters.dart';
import '../../domain/entities/subscription_invoice_page.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/entities/tenant_create_result.dart';
import '../../domain/entities/tenant_subscription.dart';
import 'package:madaris_core/money/money.dart';

class PlatformTenantModel {
  PlatformTenantModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.status,
    this.address,
    this.contactEmail,
    this.contactPhone,
    this.planName,
    this.subscriptionStatus,
  });

  final String id;
  final String name;
  final String slug;
  final String status;
  final String? address;
  final String? contactEmail;
  final String? contactPhone;
  final String? planName;
  final String? subscriptionStatus;

  factory PlatformTenantModel.fromJson(Map<String, dynamic> json) {
    return PlatformTenantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      status: json['status'] as String,
      address: json['address'] as String?,
      contactEmail: json['contact_email'] as String?,
      contactPhone: json['contact_phone'] as String?,
      planName: json['plan_name'] as String?,
      subscriptionStatus: json['subscription_status'] as String?,
    );
  }

  PlatformTenant toEntity() => PlatformTenant(
        id: id,
        name: name,
        slug: slug,
        status: status,
        address: address,
        contactEmail: contactEmail,
        contactPhone: contactPhone,
        planName: planName,
        subscriptionStatus: subscriptionStatus,
      );
}

class TenantCreateResponseModel {
  TenantCreateResponseModel({
    required this.tenant,
    required this.adminUser,
    this.tempPassword,
  });

  final PlatformTenantModel tenant;
  final User adminUser;
  final String? tempPassword;

  factory TenantCreateResponseModel.fromJson(Map<String, dynamic> json) {
    return TenantCreateResponseModel(
      tenant: PlatformTenantModel.fromJson(
        json['tenant'] as Map<String, dynamic>,
      ),
      adminUser: User(
        id: (json['admin_user'] as Map<String, dynamic>)['id'] as String,
        email: (json['admin_user'] as Map<String, dynamic>)['email'] as String,
        fullName:
            (json['admin_user'] as Map<String, dynamic>)['full_name'] as String,
        phone: (json['admin_user'] as Map<String, dynamic>)['phone'] as String?,
        isActive:
            (json['admin_user'] as Map<String, dynamic>)['is_active'] as bool? ??
                true,
        tenantId: (json['admin_user'] as Map<String, dynamic>)['tenant_id']
            as String?,
      ),
      tempPassword: json['temp_password'] as String?,
    );
  }

  TenantCreateResult toEntity() => TenantCreateResult(
        tenant: tenant.toEntity(),
        adminUser: adminUser,
        tempPassword: tempPassword,
      );
}

class SubscriptionPlanModel {
  SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.priceMonthly,
    this.priceAnnual,
    this.maxUsers,
    this.maxStudents,
    required this.featureFlags,
    required this.isActive,
  });

  final String id;
  final String name;
  final String priceMonthly;
  final String? priceAnnual;
  final int? maxUsers;
  final int? maxStudents;
  final Map<String, bool> featureFlags;
  final bool isActive;

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id'] as String,
      name: json['name'] as String,
      priceMonthly: json['price_monthly'].toString(),
      priceAnnual: json['price_annual']?.toString(),
      maxUsers: json['max_users'] as int?,
      maxStudents: json['max_students'] as int?,
      featureFlags: Map<String, bool>.from(
        Map<String, dynamic>.from(
          json['feature_flags'] as Map? ?? {},
        ).map((key, value) => MapEntry(key, value as bool)),
      ),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  SubscriptionPlan toEntity() => SubscriptionPlan(
        id: id,
        name: name,
        priceMonthly: priceMonthly,
        priceAnnual: priceAnnual,
        maxUsers: maxUsers,
        maxStudents: maxStudents,
        featureFlags: featureFlags,
        isActive: isActive,
      );

  Map<String, dynamic> toCreateJson({
    required String name,
    required String priceMonthly,
    String? priceAnnual,
    int? maxUsers,
    int? maxStudents,
    Map<String, bool>? featureFlags,
  }) {
    return {
      'name': name,
      'price_monthly': priceMonthly,
      'price_annual': ?priceAnnual,
      'max_users': ?maxUsers,
      'max_students': ?maxStudents,
      if (featureFlags != null && featureFlags.isNotEmpty)
        'feature_flags': featureFlags,
    };
  }
}

class TenantSubscriptionModel {
  TenantSubscriptionModel({
    required this.id,
    required this.tenantId,
    required this.planId,
    required this.billingCycle,
    required this.status,
    this.trialEndsAt,
    required this.currentPeriodStart,
    required this.currentPeriodEnd,
    required this.nextBillingDate,
    this.plan,
  });

  final String id;
  final String tenantId;
  final String planId;
  final String billingCycle;
  final String status;
  final DateTime? trialEndsAt;
  final DateTime currentPeriodStart;
  final DateTime currentPeriodEnd;
  final DateTime nextBillingDate;
  final SubscriptionPlanModel? plan;

  factory TenantSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return TenantSubscriptionModel(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      planId: json['plan_id'] as String,
      billingCycle: json['billing_cycle'] as String,
      status: json['status'] as String,
      trialEndsAt: json['trial_ends_at'] != null
          ? DateTime.parse(json['trial_ends_at'] as String)
          : null,
      currentPeriodStart:
          DateTime.parse(json['current_period_start'] as String),
      currentPeriodEnd: DateTime.parse(json['current_period_end'] as String),
      nextBillingDate: DateTime.parse(json['next_billing_date'] as String),
      plan: json['plan'] != null
          ? SubscriptionPlanModel.fromJson(
              json['plan'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  TenantSubscription toEntity() => TenantSubscription(
        id: id,
        tenantId: tenantId,
        planId: planId,
        billingCycle: billingCycle,
        status: status,
        trialEndsAt: trialEndsAt,
        currentPeriodStart: currentPeriodStart,
        currentPeriodEnd: currentPeriodEnd,
        nextBillingDate: nextBillingDate,
        plan: plan?.toEntity(),
      );
}

class TenantFormJson {
  static Map<String, dynamic> toCreateJson({
    required String name,
    required String slug,
    String? address,
    String? contactEmail,
    String? contactPhone,
    required String adminEmail,
    required String adminFullName,
    String? adminPassword,
  }) {
    return {
      'name': name,
      'slug': slug,
      'address': ?address?.trim().isEmpty == true ? null : address?.trim(),
      'contact_email':
          ?contactEmail?.trim().isEmpty == true ? null : contactEmail?.trim(),
      'contact_phone':
          ?contactPhone?.trim().isEmpty == true ? null : contactPhone?.trim(),
      'admin_email': adminEmail,
      'admin_full_name': adminFullName,
      'admin_password': ?adminPassword?.trim().isEmpty == true
          ? null
          : adminPassword?.trim(),
    };
  }

  static Map<String, dynamic> subscriptionAssignJson(
    TenantSubscriptionAssignData data,
  ) {
    return {
      'plan_id': data.planId,
      'billing_cycle': data.billingCycle,
      'status': data.status,
      'trial_ends_at': data.trialEndsAt?.toIso8601String().split('T').first,
      'current_period_start':
          data.currentPeriodStart?.toIso8601String().split('T').first,
    };
  }
}

class SubscriptionInvoiceModel {
  SubscriptionInvoiceModel({
    required this.id,
    required this.tenantId,
    this.tenantName,
    required this.subscriptionId,
    required this.invoiceNumber,
    required this.amount,
    required this.billingPeriodLabel,
    required this.dueDate,
    required this.status,
    this.paidDate,
    this.paymentMethod,
    this.referenceNumber,
    required this.createdAt,
  });

  final String id;
  final String tenantId;
  final String? tenantName;
  final String subscriptionId;
  final String invoiceNumber;
  final Money amount;
  final String billingPeriodLabel;
  final DateTime dueDate;
  final String status;
  final DateTime? paidDate;
  final String? paymentMethod;
  final String? referenceNumber;
  final DateTime createdAt;

  factory SubscriptionInvoiceModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionInvoiceModel(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      tenantName: json['tenant_name'] as String?,
      subscriptionId: json['subscription_id'] as String,
      invoiceNumber: json['invoice_number'] as String,
      amount: Money.parse(json['amount']),
      billingPeriodLabel: json['billing_period_label'] as String,
      dueDate: DateTime.parse(json['due_date'] as String),
      status: json['status'] as String,
      paidDate: json['paid_date'] != null
          ? DateTime.parse(json['paid_date'] as String)
          : null,
      paymentMethod: json['payment_method'] as String?,
      referenceNumber: json['reference_number'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  SubscriptionInvoice toEntity() => SubscriptionInvoice(
        id: id,
        tenantId: tenantId,
        tenantName: tenantName,
        subscriptionId: subscriptionId,
        invoiceNumber: invoiceNumber,
        amount: amount,
        billingPeriodLabel: billingPeriodLabel,
        dueDate: dueDate,
        status: status,
        paidDate: paidDate,
        paymentMethod: paymentMethod,
        referenceNumber: referenceNumber,
        createdAt: createdAt,
      );
}

class SubscriptionInvoiceListResponseModel {
  SubscriptionInvoiceListResponseModel({
    required this.items,
    required this.totalCount,
  });

  final List<SubscriptionInvoiceModel> items;
  final int totalCount;

  factory SubscriptionInvoiceListResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return SubscriptionInvoiceListResponseModel(
      items: (json['items'] as List<dynamic>)
          .map(
            (item) => SubscriptionInvoiceModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      totalCount: json['total_count'] as int,
    );
  }

  SubscriptionInvoicePage toEntity({
    required int page,
    required int pageSize,
  }) {
    final loadedCount = (page + 1) * pageSize;
    return SubscriptionInvoicePage(
      items: items.map((item) => item.toEntity()).toList(),
      page: page,
      pageSize: pageSize,
      totalCount: totalCount,
      hasMore: loadedCount < totalCount,
    );
  }
}

class PlatformDashboardModel {
  PlatformDashboardModel({
    required this.totalTenants,
    required this.tenantStatusCounts,
    required this.subscriptionStatusCounts,
    required this.mrrEstimate,
  });

  final int totalTenants;
  final Map<String, int> tenantStatusCounts;
  final Map<String, int> subscriptionStatusCounts;
  final double mrrEstimate;

  factory PlatformDashboardModel.fromJson(Map<String, dynamic> json) {
    return PlatformDashboardModel(
      totalTenants: json['total_tenants'] as int,
      tenantStatusCounts: Map<String, int>.from(
        Map<String, dynamic>.from(json['tenant_status_counts'] as Map),
      ),
      subscriptionStatusCounts: Map<String, int>.from(
        Map<String, dynamic>.from(json['subscription_status_counts'] as Map),
      ),
      mrrEstimate: (json['mrr_estimate'] as num).toDouble(),
    );
  }

  PlatformDashboard toEntity() => PlatformDashboard(
        totalTenants: totalTenants,
        tenantStatusCounts: tenantStatusCounts,
        subscriptionStatusCounts: subscriptionStatusCounts,
        mrrEstimate: mrrEstimate,
      );
}

class SubscriptionInvoiceJson {
  static Map<String, dynamic> generatePayload(
    GenerateSubscriptionInvoiceData data,
  ) {
    return {
      'billing_period_label': data.billingPeriodLabel.trim(),
      'due_date': data.dueDate.toIso8601String().split('T').first,
      if (data.tenantId != null) 'tenant_id': data.tenantId,
    };
  }

  static Map<String, dynamic> markPaidPayload(MarkInvoicePaidData data) {
    return {
      'payment_method': data.paymentMethod,
      if (data.referenceNumber != null &&
          data.referenceNumber!.trim().isNotEmpty)
        'reference_number': data.referenceNumber!.trim(),
      if (data.paidDate != null)
        'paid_date': data.paidDate!.toIso8601String().split('T').first,
    };
  }

  static Map<String, dynamic> invoiceFilters(
    SubscriptionInvoiceFilters filters, {
    required int skip,
    required int limit,
  }) {
    return {
      'skip': skip,
      'limit': limit,
      if (filters.tenantId != null) 'tenant_id': filters.tenantId,
      if (filters.status != null) 'status': filters.status,
    };
  }
}
