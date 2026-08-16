import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:madaris_core/cubit/safe_cubit.dart';
import '../../domain/entities/subscription_invoice.dart';
import '../../domain/repositories/platform_repository.dart';
import 'subscription_invoice_detail_state.dart';

class SubscriptionInvoiceDetailCubit extends Cubit<SubscriptionInvoiceDetailState>
    with SafeCubitMixin {
  SubscriptionInvoiceDetailCubit(
    this._repository, {
    required List<String> permissions,
  })  : _permissions = permissions,
        super(const SubscriptionInvoiceDetailInitial());

  final PlatformRepository _repository;
  final List<String> _permissions;

  bool _changed = false;
  bool get hasChanges => _changed;

  Future<void> load(String invoiceId) async {
    emit(const SubscriptionInvoiceDetailLoading());
    await runGuarded(
      () async {
        final invoice = await _repository.getSubscriptionInvoice(invoiceId);
        emit(
          SubscriptionInvoiceDetailLoaded(
            invoice: invoice,
            canEdit: _permissions.contains('subscription_invoices:edit'),
          ),
        );
      },
      onError: (error) => emit(SubscriptionInvoiceDetailError(error.message)),
    );
  }

  void applyUpdatedInvoice(SubscriptionInvoice invoice) {
    _changed = true;
    emit(
      SubscriptionInvoiceDetailLoaded(
        invoice: invoice,
        canEdit: _permissions.contains('subscription_invoices:edit'),
      ),
    );
  }
}
