import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saas_admin_web/features/saas_admin/domain/entities/platform_tenant.dart';
import 'package:saas_admin_web/features/saas_admin/domain/entities/subscription_plan.dart';
import 'package:saas_admin_web/features/saas_admin/presentation/screens/tenant_subscription_screen.dart';

import '../../../../support/fake_platform_repository.dart';
import '../../../../support/pump_helpers.dart';

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

Future<FakePlatformRepository> _pump(WidgetTester tester) async {
  final repository = FakePlatformRepository(plans: [_plan]);
  await pumpScreen(
    tester,
    screen: const TenantSubscriptionScreen(tenant: _tenant),
    repository: repository,
    permissions: const ['tenant_subscriptions:edit'],
  );
  return repository;
}

Future<void> _chooseCustomMonths(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Default for billing cycle'));
  await tester.tap(find.text('Default for billing cycle'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Custom number of months').last);
  await tester.pumpAndSettle();
}

Future<void> _save(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Save subscription'));
  await tester.tap(find.text('Save subscription'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('empty custom months blocks save and shows the error',
      (tester) async {
    final repository = await _pump(tester);
    await _chooseCustomMonths(tester);

    // Just selecting Custom doesn't flag the untouched field.
    expect(find.text('Please enter number of months'), findsNothing);

    await _save(tester);

    expect(repository.assignCalls, isEmpty);
    // Inline field error plus the snackbar.
    expect(find.text('Please enter number of months'), findsNWidgets(2));
  });

  testWidgets('non-numeric custom months also blocks save', (tester) async {
    final repository = await _pump(tester);
    await _chooseCustomMonths(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Period months'), 'abc');
    await tester.pump();
    expect(find.text('Enter 1–120 months'), findsOneWidget);

    await _save(tester);

    expect(repository.assignCalls, isEmpty);
  });

  testWidgets('a valid month count saves with the override', (tester) async {
    final repository = await _pump(tester);
    await _chooseCustomMonths(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Period months'), '14');
    await tester.pump();
    await _save(tester);

    expect(repository.assignCalls.single.periodMonths, 14);
  });

  testWidgets('switching back to the default clears the block',
      (tester) async {
    final repository = await _pump(tester);
    await _chooseCustomMonths(tester);

    await tester.tap(find.text('Custom number of months'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Default for billing cycle').last);
    await tester.pumpAndSettle();
    await _save(tester);

    expect(repository.assignCalls.single.periodMonths, isNull);
  });
}
