import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import 'package:madaris_core/utils/date_formatter.dart';
import 'package:madaris_core/widgets/app_loading_indicator.dart';
import 'package:madaris_core/widgets/form/app_form_card.dart';
import 'package:madaris_core/widgets/form/app_form_section.dart';
import '../../domain/entities/subscription_invoice_constants.dart';
import '../cubit/saas_auth_cubit.dart';
import '../cubit/saas_auth_state.dart';
import '../cubit/subscription_invoice_detail_cubit.dart';
import '../cubit/subscription_invoice_detail_state.dart';
import '../widgets/mark_subscription_invoice_paid_dialog.dart';
import '../widgets/subscription_invoice_status_chip.dart';

class SubscriptionInvoiceDetailScreen extends StatelessWidget {
  const SubscriptionInvoiceDetailScreen({
    super.key,
    required this.invoiceId,
  });

  final String invoiceId;

  List<String> _permissions(BuildContext context) {
    final state = context.read<SaasAuthCubit>().state;
    if (state is SaasAuthAuthenticated) {
      return state.session.permissions;
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SubscriptionInvoiceDetailCubit(
        sl(),
        permissions: _permissions(context),
      )..load(invoiceId),
      child: _SubscriptionInvoiceDetailBody(invoiceId: invoiceId),
    );
  }
}

class _SubscriptionInvoiceDetailBody extends StatelessWidget {
  const _SubscriptionInvoiceDetailBody({required this.invoiceId});

  final String invoiceId;

  Future<void> _markPaid(
    BuildContext context,
    SubscriptionInvoiceDetailLoaded state,
  ) async {
    final updated = await showMarkSubscriptionInvoicePaidDialog(
      context: context,
      invoice: state.invoice,
    );
    if (updated == null || !context.mounted) return;

    context.read<SubscriptionInvoiceDetailCubit>().applyUpdatedInvoice(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${updated.invoiceNumber} marked as paid')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final changed =
            context.read<SubscriptionInvoiceDetailCubit>().hasChanges;
        context.pop(changed);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Invoice details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              final changed =
                  context.read<SubscriptionInvoiceDetailCubit>().hasChanges;
              context.pop(changed);
            },
          ),
          actions: [
            BlocBuilder<SubscriptionInvoiceDetailCubit,
                SubscriptionInvoiceDetailState>(
              builder: (context, state) {
                if (state is! SubscriptionInvoiceDetailLoaded) {
                  return const SizedBox.shrink();
                }
                if (!state.canEdit || !state.invoice.canMarkPaid) {
                  return const SizedBox.shrink();
                }
                return PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'mark_paid') {
                      _markPaid(context, state);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem<String>(
                      value: 'mark_paid',
                      child: Text('Mark paid'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<SubscriptionInvoiceDetailCubit,
            SubscriptionInvoiceDetailState>(
          builder: (context, state) {
            if (state is SubscriptionInvoiceDetailLoading ||
                state is SubscriptionInvoiceDetailInitial) {
              return const Center(child: AppLoadingIndicator());
            }
            if (state is SubscriptionInvoiceDetailError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => context
                          .read<SubscriptionInvoiceDetailCubit>()
                          .load(invoiceId),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (state is! SubscriptionInvoiceDetailLoaded) {
              return const SizedBox.shrink();
            }

            final invoice = state.invoice;
            return SingleChildScrollView(
              padding: const EdgeInsetsDirectional.all(16),
              child: AppFormCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppFormSection(
                      title: 'Invoice',
                      children: [
                        _DetailRow(
                          label: 'Invoice number',
                          value: invoice.invoiceNumber,
                        ),
                        _DetailRow(
                          label: 'Billing period',
                          value: invoice.billingPeriodLabel,
                        ),
                        _DetailRow(
                          label: 'Amount',
                          value: invoice.amount.formatDisplay(),
                        ),
                        _DetailRow(
                          label: 'Due date',
                          value: DateFormatter.formatDisplay(invoice.dueDate),
                        ),
                        Row(
                          children: [
                            const Text('Status: '),
                            SubscriptionInvoiceStatusChip(status: invoice.status),
                          ],
                        ),
                      ],
                    ),
                    AppFormSection(
                      title: 'Tenant',
                      children: [
                        _DetailRow(
                          label: 'Tenant',
                          value: invoice.tenantName ?? invoice.tenantId,
                        ),
                        _DetailRow(
                          label: 'Subscription ID',
                          value: invoice.subscriptionId,
                        ),
                      ],
                    ),
                    if (invoice.status == 'paid')
                      AppFormSection(
                        title: 'Payment',
                        children: [
                          if (invoice.paidDate != null)
                            _DetailRow(
                              label: 'Paid date',
                              value: DateFormatter.formatDisplay(
                                invoice.paidDate!,
                              ),
                            ),
                          if (invoice.paymentMethod != null)
                            _DetailRow(
                              label: 'Payment method',
                              value: SubscriptionInvoiceConstants
                                  .paymentMethodLabel(invoice.paymentMethod!),
                            ),
                          if (invoice.referenceNumber != null)
                            _DetailRow(
                              label: 'Reference number',
                              value: invoice.referenceNumber!,
                            ),
                        ],
                      ),
                    if (state.canEdit && invoice.canMarkPaid) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: FilledButton(
                          onPressed: () => _markPaid(context, state),
                          child: const Text('Mark paid'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
