import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:madaris_core/widgets/app_button.dart';
import 'package:saas_admin_web/features/saas_admin/presentation/screens/tenant_form_screen.dart';

import '../../../../support/fake_platform_repository.dart';
import '../../../../support/pump_helpers.dart';

Future<FakePlatformRepository> _pump(WidgetTester tester) async {
  final repository = FakePlatformRepository();
  await pumpRoutedScreen(
    tester,
    screen: const TenantFormScreen(),
    repository: repository,
    permissions: const ['tenants:create'],
  );
  return repository;
}

Future<void> _fillRequired(WidgetTester tester) async {
  await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'New School');
  await tester.enterText(find.widgetWithText(TextFormField, 'Slug'), 'new-school');
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Admin email'),
    'admin@school.com',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Admin full name'),
    'Admin User',
  );
}

Future<void> _chooseType(WidgetTester tester, String label) async {
  // The dropdown shows the current selection (Madrasa by default).
  await tester.tap(find.byType(DropdownButtonFormField<String>));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

Future<void> _submit(WidgetTester tester) async {
  await tester.ensureVisible(find.byType(AppButton));
  await tester.tap(find.byType(AppButton));
  await tester.pumpAndSettle();
  // Success shows the credentials dialog, then pops back to the caller.
  await tester.tap(find.text('Done'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('offers Madrasa, Masjid and Academy, defaulting to Madrasa',
      (tester) async {
    await _pump(tester);

    // The label carries a required marker, so it renders as rich text.
    expect(
      find.textContaining('Tenant type', findRichText: true),
      findsOneWidget,
    );
    final dropdown = tester.widget<DropdownButtonFormField<String>>(
      find.byType(DropdownButtonFormField<String>),
    );
    expect(dropdown.initialValue, 'madrasa');

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    // The open menu lists all three choices (the closed field keeps its
    // items laid out too, hence findsWidgets).
    expect(find.text('Madrasa'), findsWidgets);
    expect(find.text('Masjid'), findsWidgets);
    expect(find.text('Academy'), findsWidgets);
  });

  testWidgets('creating without touching the selector sends madrasa',
      (tester) async {
    final repository = await _pump(tester);
    await _fillRequired(tester);
    await _submit(tester);

    expect(repository.createTenantCalls.single.tenantType, 'madrasa');
    expect(find.text('home'), findsOneWidget); // popped back after success
  });

  for (final (label, value) in [
    ('Madrasa', 'madrasa'),
    ('Masjid', 'masjid'),
    ('Academy', 'academy'),
  ]) {
    testWidgets('choosing $label creates a "$value" tenant', (tester) async {
      final repository = await _pump(tester);
      await _fillRequired(tester);
      // Switch away first so choosing Madrasa is a real selection too.
      if (value == 'madrasa') await _chooseType(tester, 'Masjid');
      await _chooseType(tester, label);
      await _submit(tester);

      final call = repository.createTenantCalls.single;
      expect(call.tenantType, value);
      expect(call.name, 'New School');
    });
  }
}
