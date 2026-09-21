import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:madaris_core/cubit/safe_cubit.dart';
import '../../domain/entities/subscription_plan_update_data.dart';
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
            canEdit: permissions.contains('subscription_plans:edit'),
            canRetire: permissions.contains('subscription_plans:delete'),
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
  }) {
    return _save((_) async {
      await _repository.createSubscriptionPlan(
        name: name,
        priceMonthly: priceMonthly,
        priceAnnual: priceAnnual,
        maxUsers: maxUsers,
        maxStudents: maxStudents,
        featureFlags: featureFlags,
      );
    });
  }

  Future<void> updatePlan(String planId, SubscriptionPlanUpdateData data) {
    return _save((_) => _repository.updateSubscriptionPlan(planId, data));
  }

  /// Deactivates the plan; existing tenant subscriptions keep working.
  Future<void> retirePlan(String planId) {
    return _save((_) => _repository.retireSubscriptionPlan(planId));
  }

  Future<void> _save(
    Future<void> Function(SubscriptionPlanListLoaded current) action,
  ) async {
    final current = state;
    if (current is! SubscriptionPlanListLoaded) return;

    emit(
      SubscriptionPlanListSaving(
        plans: current.plans,
        canCreate: current.canCreate,
        canEdit: current.canEdit,
        canRetire: current.canRetire,
      ),
    );

    await runGuarded(
      () async {
        await action(current);
        await load();
      },
      onError: (error) {
        emit(SubscriptionPlanListError(error.message));
        emit(current);
      },
    );
  }
}
