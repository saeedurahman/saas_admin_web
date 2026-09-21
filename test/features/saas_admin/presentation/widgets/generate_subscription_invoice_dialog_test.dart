import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saas_admin_web/features/saas_admin/domain/entities/generate_subscription_invoice_data.dart';
import 'package:saas_admin_web/features/saas_admin/presentation/widgets/generate_subscription_invoice_dialog.dart';

Future<GenerateSubscriptionInvoiceData?> _open(WidgetTester tester) async {
  GenerateSubscriptionInvoiceData? result;
  await tester.binding.setSurfaceSize(const Size(1000, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            result = await showDialog<GenerateSubscriptionInvoiceData>(
              context: context,
              builder: (_) =>
                  const GenerateSubscriptionInvoiceDialog(tenants: []),
            );
          },
          child: const Text('open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return result;
}

Future<void> _pickDate(WidgetTester tester, String tileTitle, int day) async {
  await tester.tap(
    find.descendant(
      of: find.widgetWithText(ListTile, tileTitle),
      matching: find.byType(IconButton),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('$day').last);
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('label mode still requires a label', (tester) async {
    await _open(tester);

    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(find.text('Billing period label is required'), findsOneWidget);
  });

  testWidgets('dated mode validates period fields in order', (tester) async {
    await _open(tester);
    await tester.tap(find.text('Custom dates'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.text('Period start is required'), findsOneWidget);

    await _pickDate(tester, 'Period start', 10);
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.text('Enter a period length of 1–120 months'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Period length (months)'), '121');
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.text('Enter a period length of 1–120 months'), findsOneWidget);
  });

  testWidgets('dated mode returns start + months with no label',
      (tester) async {
    GenerateSubscriptionInvoiceData? result;
    await tester.binding.setSurfaceSize(const Size(1000, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showDialog<GenerateSubscriptionInvoiceData>(
                context: context,
                builder: (_) =>
                    const GenerateSubscriptionInvoiceDialog(tenants: []),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Custom dates'));
    await tester.pumpAndSettle();
    await _pickDate(tester, 'Period start', 10);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Period length (months)'),
      '14',
    );
    await _pickDate(tester, 'Due date', 15);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.isDated, isTrue);
    expect(result!.periodStart!.day, 10);
    expect(result!.periodMonths, 14);
    expect(result!.periodEnd, isNull);
    expect(result!.billingPeriodLabel, isNull);
    expect(result!.dueDate.day, 15);
  });

  testWidgets('dated mode rejects an end date before the start',
      (tester) async {
    await _open(tester);
    await tester.tap(find.text('Custom dates'));
    await tester.pumpAndSettle();
    await _pickDate(tester, 'Period start', 20);
    await tester.tap(find.text('End date'));
    await tester.pumpAndSettle();
    await _pickDate(tester, 'Period end', 5);
    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(
      find.text('Period end must not be before period start'),
      findsOneWidget,
    );
  });
}
