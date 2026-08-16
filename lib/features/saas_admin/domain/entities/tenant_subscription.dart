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
  });

  final String planId;
  final String billingCycle;
  final String status;
  final DateTime? trialEndsAt;
  final DateTime? currentPeriodStart;

  @override
  List<Object?> get props => [
        planId,
        billingCycle,
        status,
        trialEndsAt,
        currentPeriodStart,
      ];
}
