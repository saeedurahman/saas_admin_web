import 'package:equatable/equatable.dart';

import 'subscription_plan.dart';

class TenantSubscription extends Equatable {
  const TenantSubscription({
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
  final SubscriptionPlan? plan;

  @override
  List<Object?> get props => [
        id,
        tenantId,
        planId,
        billingCycle,
        status,
        trialEndsAt,
        currentPeriodStart,
        currentPeriodEnd,
        nextBillingDate,
        plan,
      ];
}

class TenantSubscriptionAssignData extends Equatable {
  const TenantSubscriptionAssignData({
    required this.planId,
    required this.billingCycle,
    required this.status,
    this.trialEndsAt,
    this.currentPeriodStart,
    this.periodMonths,
    this.currentPeriodEnd,
  }) : assert(
          periodMonths == null || currentPeriodEnd == null,
          'Pass either periodMonths or currentPeriodEnd, not both',
        );

  final String planId;
  final String billingCycle;
  final String status;
  final DateTime? trialEndsAt;
  final DateTime? currentPeriodStart;

  /// Custom first-period length. Mutually exclusive with [currentPeriodEnd];
  /// when both are null the backend uses the billing-cycle default.
  final int? periodMonths;
  final DateTime? currentPeriodEnd;

  TenantSubscriptionAssignData copyWith({
    String? planId,
    String? billingCycle,
    String? status,
    DateTime? trialEndsAt,
    DateTime? currentPeriodStart,
  }) {
    return TenantSubscriptionAssignData(
      planId: planId ?? this.planId,
      billingCycle: billingCycle ?? this.billingCycle,
      status: status ?? this.status,
      trialEndsAt: trialEndsAt ?? this.trialEndsAt,
      currentPeriodStart: currentPeriodStart ?? this.currentPeriodStart,
      periodMonths: periodMonths,
      currentPeriodEnd: currentPeriodEnd,
    );
  }

  /// Replaces the period override; passing both nulls restores the default.
  TenantSubscriptionAssignData withPeriodOverride({
    int? months,
    DateTime? end,
  }) {
    return TenantSubscriptionAssignData(
      planId: planId,
      billingCycle: billingCycle,
      status: status,
      trialEndsAt: trialEndsAt,
      currentPeriodStart: currentPeriodStart,
      periodMonths: months,
      currentPeriodEnd: months == null ? end : null,
    );
  }

  @override
  List<Object?> get props => [
        planId,
        billingCycle,
        status,
        trialEndsAt,
        currentPeriodStart,
        periodMonths,
        currentPeriodEnd,
      ];
}
