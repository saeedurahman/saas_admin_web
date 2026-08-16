import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:madaris_core/cubit/safe_cubit.dart';
import '../../domain/entities/generate_subscription_invoice_data.dart';
import '../../domain/entities/platform_tenant.dart';
import '../../domain/entities/subscription_invoice_filters.dart';
import '../../domain/repositories/platform_repository.dart';
import 'subscription_invoice_list_state.dart';

class SubscriptionInvoiceListCubit extends Cubit<SubscriptionInvoiceListState>
    with SafeCubitMixin {
  SubscriptionInvoiceListCubit(
    this._repository, {
    required List<String> permissions,
  })  : _permissions = permissions,
        super(const SubscriptionInvoiceListInitial());

  final PlatformRepository _repository;
  final List<String> _permissions;

  static const pageSize = 25;

  SubscriptionInvoiceFilters _filters = const SubscriptionInvoiceFilters();
  List<PlatformTenant> _tenants = const [];
  bool _loadingMore = false;

  bool get _canCreate => _permissions.contains('subscription_invoices:create');
  bool get _canEdit => _permissions.contains('subscription_invoices:edit');

  Future<void> loadInitial() async {
    emit(const SubscriptionInvoiceListLoading());
    await runGuarded(
      () async {
        _tenants = await _repository.listTenants();
        await _fetchPage(reset: true);
      },
      onError: (error) => emit(SubscriptionInvoiceListError(error.message)),
    );
  }

  Future<void> setTenant(String? tenantId) async {
    _filters = _filters.copyWith(
      tenantId: tenantId,
      clearTenantId: tenantId == null,
    );
    await _applyFiltersAndFetch();
  }

  Future<void> setStatus(String? status) async {
    _filters = _filters.copyWith(
      status: status,
      clearStatus: status == null,
    );
    await _applyFiltersAndFetch();
  }

  Future<void> clearFilters() async {
    _filters = const SubscriptionInvoiceFilters();
    await _applyFiltersAndFetch();
  }

  Future<void> loadMore() async {
    final current = state;
    if (_loadingMore) return;
    if (current is! SubscriptionInvoiceListLoaded || !current.hasMore) return;

    _loadingMore = true;
    emit(
      SubscriptionInvoiceListLoadingMore(
        invoices: current.invoices,
        filters: current.filters,
        page: current.page,
        hasMore: current.hasMore,
        totalCount: current.totalCount,
        tenants: current.tenants,
        canCreate: current.canCreate,
        canEdit: current.canEdit,
      ),
    );

    await runGuarded(
      () async {
        final nextPage = current.page + 1;
        final pageResult = await _repository.getSubscriptionInvoices(
          filters: _filters,
          page: nextPage,
          pageSize: pageSize,
        );
        emit(
          SubscriptionInvoiceListLoaded(
            invoices: [...current.invoices, ...pageResult.items],
            filters: _filters,
            page: nextPage,
            hasMore: pageResult.hasMore,
            totalCount: pageResult.totalCount,
            tenants: _tenants,
            canCreate: _canCreate,
            canEdit: _canEdit,
          ),
        );
      },
      onError: (error) => emit(SubscriptionInvoiceListError(error.message)),
    );

    _loadingMore = false;
  }

  Future<void> refresh() async {
    final current = state;
    if (current is! SubscriptionInvoiceListLoaded &&
        current is! SubscriptionInvoiceListLoadingMore) {
      await loadInitial();
      return;
    }

    await runGuarded(
      () async => _fetchPage(reset: true),
      onError: (error) => emit(SubscriptionInvoiceListError(error.message)),
    );
  }

  Future<int> generateInvoices(GenerateSubscriptionInvoiceData data) async {
    final created = await _repository.generateInvoice(data);
    await refresh();
    return created.length;
  }

  Future<void> _applyFiltersAndFetch() async {
    emit(const SubscriptionInvoiceListLoading());
    await runGuarded(
      () async => _fetchPage(reset: true),
      onError: (error) => emit(SubscriptionInvoiceListError(error.message)),
    );
  }

  Future<void> _fetchPage({required bool reset}) async {
    final pageResult = await _repository.getSubscriptionInvoices(
      filters: _filters,
      page: 0,
      pageSize: pageSize,
    );
    emit(
      SubscriptionInvoiceListLoaded(
        invoices: pageResult.items,
        filters: _filters,
        page: 0,
        hasMore: pageResult.hasMore,
        totalCount: pageResult.totalCount,
        tenants: _tenants,
        canCreate: _canCreate,
        canEdit: _canEdit,
      ),
    );
  }
}
