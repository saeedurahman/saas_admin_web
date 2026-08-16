import 'package:equatable/equatable.dart';

import 'subscription_invoice.dart';

class SubscriptionInvoicePage extends Equatable {
  const SubscriptionInvoicePage({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.hasMore,
  });

  final List<SubscriptionInvoice> items;
  final int page;
  final int pageSize;
  final int totalCount;
  final bool hasMore;

  @override
  List<Object?> get props => [items, page, pageSize, totalCount, hasMore];
}
