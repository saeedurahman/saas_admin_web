import 'package:equatable/equatable.dart';

class GenerateSubscriptionInvoiceData extends Equatable {
  const GenerateSubscriptionInvoiceData({
    required this.billingPeriodLabel,
    required this.dueDate,
    this.tenantId,
  });

  final String billingPeriodLabel;
  final DateTime dueDate;
  final String? tenantId;

  @override
  List<Object?> get props => [billingPeriodLabel, dueDate, tenantId];
}
