import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:madaris_core/cubit/safe_cubit.dart';
import '../../domain/repositories/platform_repository.dart';
import 'platform_dashboard_state.dart';

class PlatformDashboardCubit extends Cubit<PlatformDashboardState>
    with SafeCubitMixin {
  PlatformDashboardCubit(this._repository)
      : super(const PlatformDashboardInitial());

  final PlatformRepository _repository;

  Future<void> load() async {
    emit(const PlatformDashboardLoading());
    await runGuarded(
      () async {
        final dashboard = await _repository.getDashboard();
        emit(PlatformDashboardLoaded(dashboard: dashboard));
      },
      onError: (error) => emit(PlatformDashboardError(error.message)),
    );
  }
}
