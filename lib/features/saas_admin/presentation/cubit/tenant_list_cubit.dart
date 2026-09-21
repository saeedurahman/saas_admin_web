import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:madaris_core/cubit/safe_cubit.dart';
import '../../domain/repositories/platform_repository.dart';
import 'tenant_list_state.dart';

class TenantListCubit extends Cubit<TenantListState> with SafeCubitMixin {
  TenantListCubit(this._repository, {required this.permissions})
      : super(const TenantListLoading());

  final PlatformRepository _repository;
  final List<String> permissions;

  Future<void> load() async {
    emit(const TenantListLoading());
    await runGuarded(
      () async {
        emit(await _fetchLoaded());
      },
      onError: (error) => emit(TenantListError(error.message)),
    );
  }

  /// Suspends or re-activates a tenant. The PATCH response lacks the
  /// plan/subscription columns, so the list is refetched on success.
  Future<void> setTenantStatus(String tenantId, String status) async {
    final current = state;
    if (current is! TenantListLoaded || current.updatingTenantId != null) {
      return;
    }
    emit(current.copyWith(updatingTenantId: tenantId));
    await runGuarded(
      () async {
        await _repository.updateTenantStatus(tenantId, status);
        emit(await _fetchLoaded());
      },
      onError: (error) => emit(
        current.copyWith(clearUpdating: true, actionError: error.message),
      ),
    );
  }

  Future<TenantListLoaded> _fetchLoaded() async {
    final tenants = await _repository.listTenants();
    return TenantListLoaded(
      tenants: tenants,
      canCreate: permissions.contains('tenants:create'),
      canEdit: permissions.contains('tenants:edit'),
    );
  }
}
