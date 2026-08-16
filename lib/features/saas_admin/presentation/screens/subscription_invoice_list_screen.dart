import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import 'package:madaris_core/utils/date_formatter.dart';
import 'package:madaris_core/widgets/app_filter_toolbar.dart';
import 'package:madaris_core/widgets/app_loading_indicator.dart';
import 'package:madaris_core/widgets/form/app_form_dropdown_field.dart';
import '../../domain/entities/platform_tenant.dart';
import '../../domain/entities/subscription_invoice.dart';
import '../../domain/entities/subscription_invoice_constants.dart';
import '../../domain/entities/subscription_invoice_filters.dart';
import '../cubit/saas_auth_cubit.dart';
import '../cubit/saas_auth_state.dart';
import '../cubit/subscription_invoice_list_cubit.dart';
import '../cubit/subscription_invoice_list_state.dart';
import '../widgets/generate_subscription_invoice_dialog.dart';
import '../widgets/mark_subscription_invoice_paid_dialog.dart';
import '../widgets/subscription_invoice_status_chip.dart';

class SubscriptionInvoiceListScreen extends StatefulWidget {
  const SubscriptionInvoiceListScreen({super.key});

  @override
  State<SubscriptionInvoiceListScreen> createState() =>
      _SubscriptionInvoiceListScreenState();
}

class _SubscriptionInvoiceListScreenState
    extends State<SubscriptionInvoiceListScreen> {
  final _scrollController = ScrollController();

  List<String> _permissions(BuildContext context) {
    final state = context.read<SaasAuthCubit>().state;
    if (state is SaasAuthAuthenticated) {
      return state.session.permissions;
    }
    return const [];
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || !mounted) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<SubscriptionInvoiceListCubit>().loadMore();
    }
  }

  Future<void> _openGenerateDialog(
    BuildContext context,
    List<PlatformTenant> tenants,
  ) async {
    await showGenerateSubscriptionInvoiceFlow(
      context: context,
      tenants: tenants,
      onGenerate: (data) =>
          context.read<SubscriptionInvoiceListCubit>().generateInvoices(data),
    );
  }

  Future<void> _openMarkPaidDialog(
    BuildContext context,
    SubscriptionInvoice invoice,
  ) async {
    final updated = await showMarkSubscriptionInvoicePaidDialog(
      context: context,
      invoice: invoice,
    );
    if (updated != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${invoice.invoiceNumber} marked as paid')),
      );
      await context.read<SubscriptionInvoiceListCubit>().refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SubscriptionInvoiceListCubit(
        sl(),
        permissions: _permissions(context),
      )..loadInitial(),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'Subscription invoices',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                BlocBuilder<SubscriptionInvoiceListCubit,
                    SubscriptionInvoiceListState>(
                  builder: (context, state) {
                    final canCreate = switch (state) {
                      SubscriptionInvoiceListLoaded loaded => loaded.canCreate,
                      SubscriptionInvoiceListLoadingMore loadingMore =>
                        loadingMore.canCreate,
                      _ => false,
                    };
                    final tenants = switch (state) {
                      SubscriptionInvoiceListLoaded loaded => loaded.tenants,
                      SubscriptionInvoiceListLoadingMore loadingMore =>
                        loadingMore.tenants,
                      _ => const <PlatformTenant>[],
                    };
                    if (!canCreate) return const SizedBox.shrink();
                    return FilledButton.icon(
                      onPressed: tenants.isEmpty
                          ? null
                          : () => _openGenerateDialog(context, tenants),
                      icon: const Icon(Icons.receipt_long_outlined),
                      label: const Text('Generate invoice'),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<SubscriptionInvoiceListCubit,
                  SubscriptionInvoiceListState>(
                builder: (context, state) {
                  if (state is SubscriptionInvoiceListInitial ||
                      state is SubscriptionInvoiceListLoading) {
                    return const Center(child: AppLoadingIndicator());
                  }
                  if (state is SubscriptionInvoiceListError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(state.message),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () => context
                                .read<SubscriptionInvoiceListCubit>()
                                .loadInitial(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final data = switch (state) {
                    SubscriptionInvoiceListLoaded loaded => _ListData(
                        invoices: loaded.invoices,
                        filters: loaded.filters,
                        hasMore: loaded.hasMore,
                        isLoadingMore: false,
                        tenants: loaded.tenants,
                        canCreate: loaded.canCreate,
                        canEdit: loaded.canEdit,
                      ),
                    SubscriptionInvoiceListLoadingMore loadingMore =>
                      _ListData(
                        invoices: loadingMore.invoices,
                        filters: loadingMore.filters,
                        hasMore: loadingMore.hasMore,
                        isLoadingMore: true,
                        tenants: loadingMore.tenants,
                        canCreate: loadingMore.canCreate,
                        canEdit: loadingMore.canEdit,
                      ),
                    _ => null,
                  };
                  if (data == null) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _FilterRow(data: data),
                      const SizedBox(height: 12),
                      Expanded(
                        child: data.invoices.isEmpty
                            ? _EmptyState(
                                canCreate: data.canCreate,
                                onGenerate: data.tenants.isEmpty
                                    ? null
                                    : () => _openGenerateDialog(
                                          context,
                                          data.tenants,
                                        ),
                              )
                            : _InvoiceTable(
                                data: data,
                                scrollController: _scrollController,
                                onMarkPaid: (invoice) =>
                                    _openMarkPaidDialog(context, invoice),
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListData {
  const _ListData({
    required this.invoices,
    required this.filters,
    required this.hasMore,
    required this.isLoadingMore,
    required this.tenants,
    required this.canCreate,
    required this.canEdit,
  });

  final List<SubscriptionInvoice> invoices;
  final SubscriptionInvoiceFilters filters;
  final bool hasMore;
  final bool isLoadingMore;
  final List<PlatformTenant> tenants;
  final bool canCreate;
  final bool canEdit;
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.data});

  final _ListData data;

  @override
  Widget build(BuildContext context) {
    return AppFilterToolbar(
      filters: [
        SizedBox(
          width: 220,
          child: AppFormDropdownField<String?>(
            label: 'Tenant',
            icon: Icons.business_outlined,
            value: data.filters.tenantId,
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('All tenants'),
              ),
              ...data.tenants.map(
                (tenant) => DropdownMenuItem<String?>(
                  value: tenant.id,
                  child: Text(tenant.name),
                ),
              ),
            ],
            onChanged: (value) =>
                context.read<SubscriptionInvoiceListCubit>().setTenant(value),
          ),
        ),
        SizedBox(
          width: 180,
          child: AppFormDropdownField<String?>(
            label: 'Status',
            icon: Icons.flag_outlined,
            value: data.filters.status,
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('All statuses'),
              ),
              ...SubscriptionInvoiceConstants.invoiceStatuses.map(
                (item) => DropdownMenuItem<String?>(
                  value: item.$1,
                  child: Text(item.$2),
                ),
              ),
            ],
            onChanged: (value) =>
                context.read<SubscriptionInvoiceListCubit>().setStatus(value),
          ),
        ),
      ],
      trailing: data.filters.hasActiveFilters
          ? [
              TextButton(
                onPressed: () => context
                    .read<SubscriptionInvoiceListCubit>()
                    .clearFilters(),
                child: const Text('Clear filters'),
              ),
            ]
          : const [],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.canCreate,
    required this.onGenerate,
  });

  final bool canCreate;
  final VoidCallback? onGenerate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'No subscription invoices found. Generate invoices for a billing '
            'period to get started.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (canCreate && onGenerate != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onGenerate,
              icon: const Icon(Icons.receipt_long_outlined),
              label: const Text('Generate invoice'),
            ),
          ],
        ],
      ),
    );
  }
}

class _InvoiceTable extends StatelessWidget {
  const _InvoiceTable({
    required this.data,
    required this.scrollController,
    required this.onMarkPaid,
  });

  final _ListData data;
  final ScrollController scrollController;
  final ValueChanged<SubscriptionInvoice> onMarkPaid;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Invoice #')),
                  DataColumn(label: Text('Tenant')),
                  DataColumn(label: Text('Amount')),
                  DataColumn(label: Text('Due date')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('')),
                ],
                rows: [
                  for (final invoice in data.invoices)
                    DataRow(
                      cells: [
                        DataCell(
                          TextButton(
                            onPressed: () async {
                              final changed = await context.push<bool>(
                                AppRoutes.subscriptionInvoicePath(invoice.id),
                              );
                              if (changed == true && context.mounted) {
                                await context
                                    .read<SubscriptionInvoiceListCubit>()
                                    .refresh();
                              }
                            },
                            child: Text(invoice.invoiceNumber),
                          ),
                        ),
                        DataCell(Text(invoice.tenantName ?? invoice.tenantId)),
                        DataCell(Text(invoice.amount.formatDisplay())),
                        DataCell(
                          Text(DateFormatter.formatDisplay(invoice.dueDate)),
                        ),
                        DataCell(
                          SubscriptionInvoiceStatusChip(status: invoice.status),
                        ),
                        DataCell(
                          _InvoiceActions(
                            invoice: invoice,
                            canEdit: data.canEdit,
                            onMarkPaid: () => onMarkPaid(invoice),
                          ),
                        ),
                      ],
                    ),
                  if (data.isLoadingMore)
                    const DataRow(
                      cells: [
                        DataCell(Center(child: AppLoadingIndicator())),
                        DataCell(SizedBox.shrink()),
                        DataCell(SizedBox.shrink()),
                        DataCell(SizedBox.shrink()),
                        DataCell(SizedBox.shrink()),
                        DataCell(SizedBox.shrink()),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
        if (data.hasMore && !data.isLoadingMore)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Center(child: Text('Scroll for more')),
          ),
      ],
    );
  }
}

class _InvoiceActions extends StatelessWidget {
  const _InvoiceActions({
    required this.invoice,
    required this.canEdit,
    required this.onMarkPaid,
  });

  final SubscriptionInvoice invoice;
  final bool canEdit;
  final VoidCallback onMarkPaid;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'view':
            context.push(AppRoutes.subscriptionInvoicePath(invoice.id));
          case 'mark_paid':
            onMarkPaid();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem<String>(
          value: 'view',
          child: Text('View details'),
        ),
        if (canEdit && invoice.canMarkPaid)
          const PopupMenuItem<String>(
            value: 'mark_paid',
            child: Text('Mark paid'),
          ),
      ],
    );
  }
}
