import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saas_admin_web/features/saas_admin/domain/entities/subscription_plan.dart';
import 'package:saas_admin_web/features/saas_admin/presentation/screens/subscription_plan_list_screen.dart';

import '../../../../support/fake_platform_repository.dart';
import '../../../../support/pump_helpers.dart';

const _plan = SubscriptionPlan(
  id: 'p1',
  name: 'Standard',
  priceMonthly: '1000.00',
  priceAnnual: '10000.00',
  maxUsers: 50,
  featureFlags: {'hostel': true, 'custom_flag': true, 'library': false},
  isActive: true,
);

const _allPermissions = [
  'subscription_plans:create',
  'subscription_plans:edit',
  'subscription_plans:delete',
];

Finder _field(String label) => find.widgetWithText(TextFormField, label);

void main() {
  testWidgets('hides edit and retire without permissions', (tester) async {
    await pumpScreen(
      tester,
      screen: const SubscriptionPlanListScreen(),
      repository: FakePlatformRepository(plans: [_plan]),
      permissions: const [],
    );

    expect(find.byTooltip('Edit plan'), findsNothing);
    expect(find.byTooltip('Retire plan'), findsNothing);
  });

  testWidgets('edit dialog prefills, saves and preserves existing flags',
      (tester) async {
    final repository = FakePlatformRepository(plans: [_plan]);
    await pumpScreen(
      tester,
      screen: const SubscriptionPlanListScreen(),
      repository: repository,
      permissions: _allPermissions,
    );

    await tester.tap(find.byTooltip('Edit plan'));
    await tester.pumpAndSettle();

    expect(find.text('Edit plan'), findsOneWidget);
    expect(
      tester.widget<TextFormField>(_field('Name')).controller!.text,
      'Standard',
    );

    await tester.enterText(_field('Name'), 'Standard Plus');
    await tester.enterText(_field('Max users (blank = unlimited)'), '');
    // Flags are opt-out and not editable here: no module toggles are offered.
    expect(find.byType(CheckboxListTile), findsNothing);
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    final (planId, data) = repository.planUpdateCalls.single;
    expect(planId, 'p1');
    expect(data.name, 'Standard Plus');
    expect(data.maxUsers, isNull);
    expect(data.priceAnnual, '10000.00');
    // Untouched, including an explicit `false` set through the API.
    expect(data.featureFlags, {
      'hostel': true,
      'custom_flag': true,
      'library': false,
    });
    expect(find.text('Standard Plus'), findsOneWidget);
  });

  testWidgets('edit dialog validates before saving', (tester) async {
    final repository = FakePlatformRepository(plans: [_plan]);
    await pumpScreen(
      tester,
      screen: const SubscriptionPlanListScreen(),
      repository: repository,
      permissions: _allPermissions,
    );

    await tester.tap(find.byTooltip('Edit plan'));
    await tester.pumpAndSettle();
    await tester.enterText(_field('Monthly price'), 'abc');
    await tester.enterText(_field('Max users (blank = unlimited)'), '0');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid amount'), findsOneWidget);
    expect(find.text('Enter a whole number ≥ 1'), findsOneWidget);
    expect(repository.planUpdateCalls, isEmpty);
  });

  testWidgets('retire confirms, deactivates and hides the action',
      (tester) async {
    final repository = FakePlatformRepository(plans: [_plan]);
    await pumpScreen(
      tester,
      screen: const SubscriptionPlanListScreen(),
      repository: repository,
      permissions: _allPermissions,
    );

    await tester.tap(find.byTooltip('Retire plan'));
    await tester.pumpAndSettle();
    expect(find.text('Retire plan?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Retire'));
    await tester.pumpAndSettle();

    expect(repository.retireCalls, ['p1']);
    expect(find.text('Inactive'), findsOneWidget);
    expect(find.byTooltip('Retire plan'), findsNothing);
  });
}
