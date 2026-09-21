import 'package:flutter/material.dart';
import 'package:madaris_core/widgets/app_list_status_badge.dart';

/// Colored pill for tenant and tenant-subscription statuses, which share one
/// vocabulary: normal (active/trial) → past_due amber → suspended red.
class PlatformStatusChip extends StatelessWidget {
  const PlatformStatusChip({super.key, required this.status});

  final String? status;

  static String label(String status) => switch (status) {
        'past_due' => 'Past due',
        _ => status.isEmpty
            ? status
            : '${status[0].toUpperCase()}${status.substring(1)}',
      };

  static Color color(String status) => switch (status) {
        'active' => Colors.green.shade700,
        'trial' => Colors.blue.shade700,
        'past_due' => Colors.amber.shade800,
        'suspended' => Colors.red.shade700,
        _ => Colors.grey.shade700,
      };

  @override
  Widget build(BuildContext context) {
    final value = status;
    if (value == null || value.isEmpty) return const Text('—');
    return AppListStatusBadge(label: label(value), color: color(value));
  }
}
