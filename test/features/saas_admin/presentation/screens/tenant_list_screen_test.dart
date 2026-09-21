import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saas_admin_web/features/saas_admin/domain/entities/platform_tenant.dart';
import 'package:saas_admin_web/features/saas_admin/presentation/screens/tenant_list_screen.dart';
import 'package:saas_admin_web/features/saas_admin/presentation/widgets/platform_status_chip.dart';
import 'package:saas_admin_web/features/saas_admin/presentation/widgets/tenant_type_badge.dart';

import '../../../../support/fake_platform_repository.dart';
import '../../../../support/pump_helpers.dart';

const _active = PlatformTenant(
  id: 't1',
  name: 'Active School',
  slug: 'active-school',
  status: 'active',
  planName: 'Standard',
  subscriptionStatus: 'past_due',
);

const _suspended = PlatformTenant(
  id: 't2',
  name: 'Blocked School',
  slug: 'blocked-school',
  status: 'suspended',
  planName: 'Standard',
  subscriptionStatus: 'suspended',
);

void main() {
  testWidgets("shows each tenant's type in a Type column", (tester) async {
    await pumpScreen(
      tester,
      screen: const TenantListScreen(),
      repository: FakePlatformRepository(
        tenants: [
          _active,
          const PlatformTenant(
            id: 't3',
            name: 'Grand Masjid',
            slug: 'grand-masjid',
            status: 'active',
            tenantType: 'masjid',
          ),
          const PlatformTenant(
            id: 't4',
            name: 'Coaching Academy',
            slug: 'coaching-academy',
            status: 'active',
            tenantType: 'academy',
          ),
        ],
      ),
      permissions: const [],
    );

    expect(find.text('Type'), findsOneWidget); // column header
    expect(find.byType(TenantTypeBadge), findsNWidgets(3));
    // _active leaves tenantType unset -> backend default, Madrasa.
    expect(find.text('Madrasa'), findsOneWidget);
    expect(find.text('Masjid'), findsOneWidget);
    expect(find.text('Academy'), findsOneWidget);
  });

  testWidgets("a status change keeps the tenant's type", (tester) async {
    final repository = FakePlatformRepository(
      tenants: [
        const PlatformTenant(
          id: 't3',
          name: 'Grand Masjid',
          slug: 'grand-masjid',
          status: 'active',
          tenantType: 'masjid',
        ),
      ],
    );
    await pumpScreen(
      tester,
      screen: const TenantListScreen(),
      repository: repository,
      permissions: const ['tenants:edit'],
    );

    await tester.ensureVisible(find.widgetWithText(TextButton, 'Suspend'));
    await tester.tap(find.widgetWithText(TextButton, 'Suspend'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Suspend'));
    await tester.pumpAndSettle();

    expect(find.text('Masjid'), findsOneWidget);
  });

  testWidgets('shows tenant and subscription status chips', (tester) async {
    await pumpScreen(
      tester,
      screen: const TenantListScreen(),
      repository: FakePlatformRepository(tenants: [_active, _suspended]),
      permissions: const [],
    );

    expect(find.text('Subscription'), findsWidgets); // column header
    expect(find.text('Past due'), findsOneWidget);
    expect(find.text('Suspended'), findsNWidgets(2));
    expect(find.byType(PlatformStatusChip), findsNWidgets(4));
  });

  testWidgets('hides suspend/activate without tenants:edit', (tester) async {
    await pumpScreen(
      tester,
      screen: const TenantListScreen(),
      repository: FakePlatformRepository(tenants: [_active]),
      permissions: const [],
    );

    expect(find.text('Suspend'), findsNothing);
    expect(find.text('Activate'), findsNothing);
  });

  testWidgets('suspending asks for confirmation, then patches and refreshes',
      (tester) async {
    final repository = FakePlatformRepository(tenants: [_active]);
    await pumpScreen(
      tester,
      screen: const TenantListScreen(),
      repository: repository,
      permissions: const ['tenants:edit'],
    );

    await tester.tap(find.widgetWithText(TextButton, 'Suspend'));
    await tester.pumpAndSettle();
    expect(find.text('Suspend tenant?'), findsOneWidget);
    expect(repository.tenantStatusCalls, isEmpty);

    await tester.tap(find.widgetWithText(FilledButton, 'Suspend'));
    await tester.pumpAndSettle();

    expect(repository.tenantStatusCalls, [('t1', 'suspended')]);
    // Row now offers Activate.
    expect(find.widgetWithText(TextButton, 'Activate'), findsOneWidget);
  });

  testWidgets('cancelling the confirmation does not call the API',
      (tester) async {
    final repository = FakePlatformRepository(tenants: [_active]);
    await pumpScreen(
      tester,
      screen: const TenantListScreen(),
      repository: repository,
      permissions: const ['tenants:edit'],
    );

    await tester.tap(find.widgetWithText(TextButton, 'Suspend'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(repository.tenantStatusCalls, isEmpty);
  });

  testWidgets('activating a suspended tenant sends status active',
      (tester) async {
    final repository = FakePlatformRepository(tenants: [_suspended]);
    await pumpScreen(
      tester,
      screen: const TenantListScreen(),
      repository: repository,
      permissions: const ['tenants:edit'],
    );

    // The table scrolls horizontally; bring the action into view first.
    await tester.ensureVisible(find.widgetWithText(TextButton, 'Activate'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Activate'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Activate'));
    await tester.pumpAndSettle();

    expect(repository.tenantStatusCalls, [('t2', 'active')]);
  });

  testWidgets('status chip tiers: normal, amber, red', (tester) async {
    expect(PlatformStatusChip.color('active'), Colors.green.shade700);
    expect(PlatformStatusChip.color('past_due'), Colors.amber.shade800);
    expect(PlatformStatusChip.color('suspended'), Colors.red.shade700);
    expect(PlatformStatusChip.label('past_due'), 'Past due');
  });
}
