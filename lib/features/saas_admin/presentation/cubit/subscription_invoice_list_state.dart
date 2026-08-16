import 'package:equatable/equatable.dart';

import '../../domain/entities/platform_tenant.dart';
import '../../domain/entities/subscription_invoice.dart';
import '../../domain/entities/subscription_invoice_filters.dart';

sealed class SubscriptionInvoiceListState extends Equatable {
  const SubscriptionInvoiceListState();

  @override
  List<Object?> get props => [];
}

class SubscriptionInvoiceListInitial extends SubscriptionInvoiceListState {
  const SubscriptionInvoiceListInitial();
}

class SubscriptionInvoiceListLoading extends SubscriptionInvoiceListState {
  const SubscriptionInvoiceListLoading();
}

class SubscriptionInvoiceListLoaded extends SubscriptionInvoiceListState {
  const SubscriptionInvoiceListLoaded({
    required this.invoices,
    required this.filters,
    required this.page,
    required this.hasMore,
    required this.totalCount,
    required this.tenants,
    required this.canCreate,
    required this.canEdit,
  });

  final List<SubscriptionInvoice> invoices;
  final SubscriptionInvoiceFilters filters;
  final int page;
  final bool hasMore;
  final int totalCount;
  final List<PlatformTenant> tenants;
  final bool canCreate;
  final bool canEdit;

  @override
  List<Object?> get props => [
        invoices,
        filters,
        page,
        hasMore,
        totalCount,
        tenants,
        canCreate,
        canEdit,
      ];
}

class SubscriptionInvoiceListLoadingMore extends SubscriptionInvoiceListState {
  const SubscriptionInvoiceListLoadingMore({
    required this.invoices,
    required this.filters,
    required this.page,
    required this.hasMore,
    required this.totalCount,
    required this.tenants,
    required this.canCreate,
    required this.canEdit,
  });

  final List<SubscriptionInvoice> invoices;
  final SubscriptionInvoiceFilters filters;
  final int page;
  final bool hasMore;
  final int totalCount;
  final List<PlatformTenant> tenants;
  final bool canCreate;
  final bool canEdit;

  @override
  List<Object?> get props => [
        invoices,
        filters,
        page,
        hasMore,
        totalCount,
        tenants,
        canCreate,
        canEdit,
      ];
}

class SubscriptionInvoiceListError extends SubscriptionInvoiceListState {
  const SubscriptionInvoiceListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
