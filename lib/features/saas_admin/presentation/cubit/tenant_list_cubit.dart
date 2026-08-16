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
        final tenants = await _repository.listTenants();
        emit(
          TenantListLoaded(
            tenants: tenants,
            canCreate: permissions.contains('tenants:create'),
          ),
        );
      },
      onError: (error) => emit(TenantListError(error.message)),
    );
  }
}
