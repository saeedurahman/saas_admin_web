import 'package:flutter/material.dart';
import 'package:madaris_core/utils/date_formatter.dart';

import '../../domain/entities/tenant_subscription.dart';
import 'platform_status_chip.dart';

/// Read-only summary of a tenant's current subscription, surfacing the
/// billing dates admins care about.
class SubscriptionSummary extends StatelessWidget {
  const SubscriptionSummary({super.key, required this.subscription});

  final TenantSubscription subscription;

  @override
  Widget build(BuildContext context) {
    String date(DateTime? value) => DateFormatter.formatFriendly(value) ?? '—';
    final plan = subscription.plan?.name ?? subscription.planId;
    final rows = <(String, Widget)>[
      ('Plan', Text('$plan (${subscription.billingCycle})')),
      ('Status', PlatformStatusChip(status: subscription.status)),
      if (subscription.trialEndsAt != null)
        ('Trial ends', Text(date(subscription.trialEndsAt))),
      ('Period start', Text(date(subscription.currentPeriodStart))),
      ('Current period ends', Text(date(subscription.currentPeriodEnd))),
      ('Next billing date', Text(date(subscription.nextBillingDate))),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current subscription',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          for (final (label, value) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 160,
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  value,
                ],
              ),
            ),
        ],
      ),
    );
  }
}
