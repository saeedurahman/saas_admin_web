import 'package:flutter_test/flutter_test.dart';
import 'package:saas_admin_web/features/saas_admin/domain/entities/platform_tenant.dart';
import 'package:saas_admin_web/features/saas_admin/domain/entities/subscription_plan.dart';
import 'package:saas_admin_web/features/saas_admin/presentation/cubit/tenant_subscription_cubit.dart';
import 'package:saas_admin_web/features/saas_admin/presentation/cubit/tenant_subscription_state.dart';

import '../../../../support/fake_platform_repository.dart';

const _tenant = PlatformTenant(
  id: 't1',
  name: 'School',
  slug: 'school',
  status: 'active',
);

const _plan = SubscriptionPlan(
  id: 'p1',
  name: 'Standard',
  priceMonthly: '1000.00',
  featureFlags: {},
  isActive: true,
);

void main() {
  late FakePlatformRepository repository;
  late TenantSubscriptionCubit cubit;

  setUp(() async {
    repository = FakePlatformRepository(plans: [_plan]);
    cubit = TenantSubscriptionCubit(
      repository,
      permissions: const ['tenant_subscriptions:edit'],
    );
    await cubit.load(_tenant);
  });

  tearDown(() => cubit.close());

  test('submit passes a custom month count through to the repository',
      () async {
    final editing = cubit.state as TenantSubscriptionEditing;
    cubit.updateForm(
      editing.formData
          .copyWith(currentPeriodStart: DateTime(2026, 1, 1))
          .withPeriodOverride(months: 14),
    );

    await cubit.submit();

    expect(repository.assignCalls.single.periodMonths, 14);
    expect(repository.assignCalls.single.currentPeriodEnd, isNull);
    final after = cubit.state as TenantSubscriptionEditing;
    expect(after.existingSubscription!.currentPeriodEnd, DateTime(2027, 3, 1));
    // The override is one-shot: the form resyncs to the saved subscription.
    expect(after.formData.periodMonths, isNull);
  });

  test('submit passes an explicit period end through', () async {
    final editing = cubit.state as TenantSubscriptionEditing;
    cubit.updateForm(
      editing.formData
          .copyWith(currentPeriodStart: DateTime(2026, 1, 1))
          .withPeriodOverride(end: DateTime(2026, 12, 31)),
    );

    await cubit.submit();

    expect(repository.assignCalls.single.currentPeriodEnd, DateTime(2026, 12, 31));
    expect(repository.assignCalls.single.periodMonths, isNull);
  });

  test('submit rejects a period end before the period start', () async {
    final editing = cubit.state as TenantSubscriptionEditing;
    cubit.updateForm(
      editing.formData
          .copyWith(currentPeriodStart: DateTime(2026, 6, 1))
          .withPeriodOverride(end: DateTime(2026, 5, 1)),
    );

    final emitted = <TenantSubscriptionState>[];
    final sub = cubit.stream.listen(emitted.add);
    await cubit.submit();
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(repository.assignCalls, isEmpty);
    expect(
      (emitted.first as TenantSubscriptionError).message,
      'Period end must not be before period start',
    );
    expect(cubit.state, isA<TenantSubscriptionEditing>());
  });

  test('submit is blocked while the period control reports an error',
      () async {
    cubit.setPeriodError('Please enter number of months');

    final emitted = <TenantSubscriptionState>[];
    final sub = cubit.stream.listen(emitted.add);
    await cubit.submit();
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(repository.assignCalls, isEmpty);
    expect(
      (emitted.first as TenantSubscriptionError).message,
      'Please enter number of months',
    );
    final after = cubit.state as TenantSubscriptionEditing;
    expect(after.showPeriodError, isTrue);
    expect(after.periodError, 'Please enter number of months');
  });

  test('clearing the period error lets submit proceed', () async {
    cubit.setPeriodError('Please enter number of months');
    cubit.setPeriodError(null);

    await cubit.submit();

    expect(repository.assignCalls, hasLength(1));
    expect((cubit.state as TenantSubscriptionEditing).periodError, isNull);
  });
}
