import 'package:equatable/equatable.dart';
import 'package:madaris_core/money/money.dart';

class SubscriptionInvoice extends Equatable {
  const SubscriptionInvoice({
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

  bool get canMarkPaid => status == 'unpaid' || status == 'overdue';

  @override
  List<Object?> get props => [
        id,
        tenantId,
        tenantName,
        subscriptionId,
        invoiceNumber,
        amount,
        billingPeriodLabel,
        dueDate,
        status,
        paidDate,
        paymentMethod,
        referenceNumber,
        createdAt,
      ];
}
