import 'package:flutter_test/flutter_test.dart';
import 'package:madaris_core/errors/app_exception.dart';
import 'package:saas_admin_web/features/saas_admin/domain/entities/platform_tenant.dart';
import 'package:saas_admin_web/features/saas_admin/presentation/cubit/tenant_list_cubit.dart';
import 'package:saas_admin_web/features/saas_admin/presentation/cubit/tenant_list_state.dart';

import '../../../../support/fake_platform_repository.dart';

const _tenant = PlatformTenant(
  id: 't1',
  name: 'School',
  slug: 'school',
  status: 'active',
  planName: 'Standard',
  subscriptionStatus: 'past_due',
);

void main() {
  late FakePlatformRepository repository;

  TenantListCubit buildCubit({
    List<String> permissions = const ['tenants:edit'],
  }) {
    return TenantListCubit(repository, permissions: permissions);
  }

  setUp(() => repository = FakePlatformRepository(tenants: [_tenant]));

  test('load exposes subscription status and edit permission', () async {
    final cubit = buildCubit();
    await cubit.load();

    final state = cubit.state as TenantListLoaded;
    expect(state.tenants.single.subscriptionStatus, 'past_due');
    expect(state.canEdit, isTrue);
    expect(state.canCreate, isFalse);
    await cubit.close();
  });

  test('canEdit is false without tenants:edit', () async {
    final cubit = buildCubit(permissions: const []);
    await cubit.load();

    expect((cubit.state as TenantListLoaded).canEdit, isFalse);
    await cubit.close();
  });

  test('setTenantStatus patches then reloads the list', () async {
    final cubit = buildCubit();
    await cubit.load();

    final emitted = <TenantListState>[];
    final sub = cubit.stream.listen(emitted.add);
    await cubit.setTenantStatus('t1', 'suspended');
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(repository.tenantStatusCalls, [('t1', 'suspended')]);
    expect((emitted.first as TenantListLoaded).updatingTenantId, 't1');
    final done = cubit.state as TenantListLoaded;
    expect(done.tenants.single.status, 'suspended');
    expect(done.updatingTenantId, isNull);
    expect(done.actionError, isNull);
    await cubit.close();
  });

  test('setTenantStatus failure keeps the list and reports the error',
      () async {
    final cubit = buildCubit();
    await cubit.load();
    repository.failNextWith = const ServerException('Not allowed');

    await cubit.setTenantStatus('t1', 'suspended');

    final state = cubit.state as TenantListLoaded;
    expect(state.actionError, 'Not allowed');
    expect(state.updatingTenantId, isNull);
    expect(state.tenants.single.status, 'active');
    await cubit.close();
  });

  test('setTenantStatus is ignored while another change is in flight',
      () async {
    final cubit = buildCubit();
    await cubit.load();

    final first = cubit.setTenantStatus('t1', 'suspended');
    await cubit.setTenantStatus('t1', 'active');
    await first;

    expect(repository.tenantStatusCalls, [('t1', 'suspended')]);
    await cubit.close();
  });
}
