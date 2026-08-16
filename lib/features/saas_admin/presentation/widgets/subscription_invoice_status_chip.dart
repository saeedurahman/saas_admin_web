import 'package:flutter/material.dart';

import '../../domain/entities/subscription_invoice_constants.dart';

class SubscriptionInvoiceStatusChip extends StatelessWidget {
  const SubscriptionInvoiceStatusChip({super.key, required this.status});

  final String status;

  Color _backgroundColor(BuildContext context) {
    return switch (status) {
      'paid' => Colors.green.shade100,
      'overdue' => Colors.red.shade100,
      _ => Colors.orange.shade100,
    };
  }

  Color _foregroundColor(BuildContext context) {
    return switch (status) {
      'paid' => Colors.green.shade900,
      'overdue' => Colors.red.shade900,
      _ => Colors.orange.shade900,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(SubscriptionInvoiceConstants.statusLabel(status)),
      backgroundColor: _backgroundColor(context),
      labelStyle: TextStyle(color: _foregroundColor(context)),
      visualDensity: VisualDensity.compact,
    );
  }
}
