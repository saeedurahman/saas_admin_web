import 'package:flutter/material.dart';
import 'package:madaris_core/widgets/app_list_status_badge.dart';

import '../../domain/entities/tenant_type_constants.dart';

/// Pill showing a tenant's type (Madrasa / Masjid / Academy).
class TenantTypeBadge extends StatelessWidget {
  const TenantTypeBadge({super.key, required this.type});

  final String type;

  static Color color(String type) => switch (type) {
        'masjid' => Colors.teal.shade700,
        'academy' => Colors.deepPurple.shade600,
        _ => Colors.indigo.shade600,
      };

  @override
  Widget build(BuildContext context) {
    return AppListStatusBadge(
      label: TenantTypeConstants.label(type),
      color: color(type),
    );
  }
}
