import 'package:equatable/equatable.dart';

/// Two modes, mirroring the backend:
/// * label-only — [billingPeriodLabel] set, no period dates;
/// * dated — [periodStart] plus [periodMonths] and/or [periodEnd]; the label
///   is optional and defaults to the date range server-side.
class GenerateSubscriptionInvoiceData extends Equatable {
  const GenerateSubscriptionInvoiceData({
    this.billingPeriodLabel,
    required this.dueDate,
    this.tenantId,
    this.periodStart,
    this.periodEnd,
    this.periodMonths,
  });

  final String? billingPeriodLabel;
  final DateTime dueDate;
  final String? tenantId;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final int? periodMonths;

  bool get isDated => periodStart != null;

  @override
  List<Object?> get props => [
        billingPeriodLabel,
        dueDate,
        tenantId,
        periodStart,
        periodEnd,
        periodMonths,
      ];
}
