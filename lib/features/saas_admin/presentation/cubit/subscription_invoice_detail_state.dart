import 'package:equatable/equatable.dart';

import '../../domain/entities/subscription_invoice.dart';

sealed class SubscriptionInvoiceDetailState extends Equatable {
  const SubscriptionInvoiceDetailState();

  @override
  List<Object?> get props => [];
}

class SubscriptionInvoiceDetailInitial extends SubscriptionInvoiceDetailState {
  const SubscriptionInvoiceDetailInitial();
}

class SubscriptionInvoiceDetailLoading extends SubscriptionInvoiceDetailState {
  const SubscriptionInvoiceDetailLoading();
}

class SubscriptionInvoiceDetailLoaded extends SubscriptionInvoiceDetailState {
  const SubscriptionInvoiceDetailLoaded({
    required this.invoice,
    required this.canEdit,
  });

  final SubscriptionInvoice invoice;
  final bool canEdit;

  @override
  List<Object?> get props => [invoice, canEdit];
}

class SubscriptionInvoiceDetailError extends SubscriptionInvoiceDetailState {
  const SubscriptionInvoiceDetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
