import 'package:equatable/equatable.dart';

class SubscriptionInvoiceFilters extends Equatable {
  const SubscriptionInvoiceFilters({
    this.tenantId,
    this.status,
  });

  final String? tenantId;
  final String? status;

  SubscriptionInvoiceFilters copyWith({
    String? tenantId,
    String? status,
    bool clearTenantId = false,
    bool clearStatus = false,
  }) {
    return SubscriptionInvoiceFilters(
      tenantId: clearTenantId ? null : tenantId ?? this.tenantId,
      status: clearStatus ? null : status ?? this.status,
    );
  }

  bool get hasActiveFilters => tenantId != null || status != null;

  @override
  List<Object?> get props => [tenantId, status];
}
