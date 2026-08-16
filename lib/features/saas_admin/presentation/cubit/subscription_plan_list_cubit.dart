import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:madaris_core/cubit/safe_cubit.dart';
import '../../domain/repositories/platform_repository.dart';
import 'subscription_plan_list_state.dart';

class SubscriptionPlanListCubit extends Cubit<SubscriptionPlanListState>
    with SafeCubitMixin {
  SubscriptionPlanListCubit(this._repository, {required this.permissions})
      : super(const SubscriptionPlanListLoading());

  final PlatformRepository _repository;
  final List<String> permissions;

  Future<void> load() async {
    emit(const SubscriptionPlanListLoading());
    await runGuarded(
      () async {
        final plans = await _repository.listSubscriptionPlans();
        emit(
          SubscriptionPlanListLoaded(
            plans: plans,
            canCreate: permissions.contains('subscription_plans:create'),
          ),
        );
      },
      onError: (error) => emit(SubscriptionPlanListError(error.message)),
    );
  }

  Future<void> createPlan({
    required String name,
    required String priceMonthly,
    String? priceAnnual,
    int? maxUsers,
    int? maxStudents,
    Map<String, bool>? featureFlags,
  }) async {
    final current = state;
    if (current is! SubscriptionPlanListLoaded) return;

    emit(
      SubscriptionPlanListCreating(
        plans: current.plans,
        canCreate: current.canCreate,
      ),
    );

    await runGuarded(
      () async {
        await _repository.createSubscriptionPlan(
          name: name,
          priceMonthly: priceMonthly,
          priceAnnual: priceAnnual,
          maxUsers: maxUsers,
          maxStudents: maxStudents,
          featureFlags: featureFlags,
        );
        await load();
      },
      onError: (error) {
        emit(SubscriptionPlanListError(error.message));
        emit(current);
      },
    );
  }
}
