import 'package:flutter_test/flutter_test.dart';
import 'package:madaris_core/errors/app_exception.dart';
import 'package:saas_admin_web/features/saas_admin/domain/entities/subscription_plan.dart';
import 'package:saas_admin_web/features/saas_admin/domain/entities/subscription_plan_update_data.dart';
import 'package:saas_admin_web/features/saas_admin/presentation/cubit/subscription_plan_list_cubit.dart';
import 'package:saas_admin_web/features/saas_admin/presentation/cubit/subscription_plan_list_state.dart';

import '../../../../support/fake_platform_repository.dart';

const _plan = SubscriptionPlan(
  id: 'p1',
  name: 'Standard',
  priceMonthly: '1000.00',
  priceAnnual: '10000.00',
  maxUsers: 50,
  featureFlags: {'hostel': true},
  isActive: true,
);

void main() {
  late FakePlatformRepository repository;

  Future<SubscriptionPlanListCubit> loadedCubit({
    List<String> permissions = const [
      'subscription_plans:edit',
      'subscription_plans:delete',
    ],
  }) async {
    final cubit = SubscriptionPlanListCubit(
      repository,
      permissions: permissions,
    );
    await cubit.load();
    return cubit;
  }

  setUp(() => repository = FakePlatformRepository(plans: [_plan]));

  test('load maps edit and delete permissions', () async {
    final cubit = await loadedCubit();
    final state = cubit.state as SubscriptionPlanListLoaded;
    expect(state.canEdit, isTrue);
    expect(state.canRetire, isTrue);
    expect(state.canCreate, isFalse);
    await cubit.close();
  });

  test('updatePlan sends the data and reloads the updated plan', () async {
    final cubit = await loadedCubit();
    const data = SubscriptionPlanUpdateData(
      name: 'Standard Plus',
      priceMonthly: '1200',
      featureFlags: {'hostel': true, 'payroll': true},
    );

    await cubit.updatePlan('p1', data);

    expect(repository.planUpdateCalls, [('p1', data)]);
    final state = cubit.state as SubscriptionPlanListLoaded;
    expect(state.plans.single.name, 'Standard Plus');
    expect(state.plans.single.featureFlags['payroll'], isTrue);
    await cubit.close();
  });

  test('retirePlan deactivates the plan', () async {
    final cubit = await loadedCubit();

    await cubit.retirePlan('p1');

    expect(repository.retireCalls, ['p1']);
    final state = cubit.state as SubscriptionPlanListLoaded;
    expect(state.plans.single.isActive, isFalse);
    await cubit.close();
  });

  test('a failed edit emits the error then restores the list', () async {
    final cubit = await loadedCubit();
    repository.failNextWith =
        const ConflictException('Subscription plan name already exists');

    final emitted = <SubscriptionPlanListState>[];
    final sub = cubit.stream.listen(emitted.add);
    await cubit.updatePlan(
      'p1',
      const SubscriptionPlanUpdateData(
        name: 'Dup',
        priceMonthly: '1',
        featureFlags: {},
      ),
    );
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(emitted[0], isA<SubscriptionPlanListSaving>());
    expect(
      (emitted[1] as SubscriptionPlanListError).message,
      'Subscription plan name already exists',
    );
    final restored = emitted[2] as SubscriptionPlanListLoaded;
    expect(restored.plans.single.name, 'Standard');
    await cubit.close();
  });
}
