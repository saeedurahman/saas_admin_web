import 'package:equatable/equatable.dart';

class MarkInvoicePaidData extends Equatable {
  const MarkInvoicePaidData({
    required this.paymentMethod,
    this.referenceNumber,
    this.paidDate,
  });

  final String paymentMethod;
  final String? referenceNumber;
  final DateTime? paidDate;

  @override
  List<Object?> get props => [paymentMethod, referenceNumber, paidDate];
}
