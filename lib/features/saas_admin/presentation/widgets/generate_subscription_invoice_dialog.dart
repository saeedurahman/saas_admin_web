import 'package:flutter/material.dart';

import 'package:madaris_core/widgets/app_button.dart';
import 'package:madaris_core/widgets/app_text_field.dart';
import 'package:madaris_core/widgets/form/app_form_dropdown_field.dart';
import '../../domain/entities/generate_subscription_invoice_data.dart';
import '../../domain/entities/platform_tenant.dart';

class GenerateSubscriptionInvoiceDialog extends StatefulWidget {
  const GenerateSubscriptionInvoiceDialog({
    super.key,
    required this.tenants,
  });

  final List<PlatformTenant> tenants;

  @override
  State<GenerateSubscriptionInvoiceDialog> createState() =>
      _GenerateSubscriptionInvoiceDialogState();
}

class _GenerateSubscriptionInvoiceDialogState
    extends State<GenerateSubscriptionInvoiceDialog> {
  final _periodController = TextEditingController();
  String? _tenantId;
  DateTime? _dueDate;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _periodController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 5, 12, 31),
      helpText: 'Select due date',
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _submit() async {
    final periodLabel = _periodController.text.trim();
    if (periodLabel.isEmpty) {
      setState(() => _error = 'Billing period label is required');
      return;
    }
    if (_dueDate == null) {
      setState(() => _error = 'Due date is required');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    final data = GenerateSubscriptionInvoiceData(
      billingPeriodLabel: periodLabel,
      dueDate: _dueDate!,
      tenantId: _tenantId,
    );

    if (!mounted) return;
    Navigator.of(context).pop(data);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Generate invoices'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IgnorePointer(
              ignoring: _submitting,
              child: AppTextField(
                controller: _periodController,
                label: 'Billing period label',
                hint: '2026-08',
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Due date'),
              subtitle: Text(
                _dueDate == null
                    ? 'Select due date'
                    : _dueDate!.toIso8601String().split('T').first,
              ),
              trailing: IconButton(
                onPressed: _submitting ? null : _pickDueDate,
                icon: const Icon(Icons.calendar_today_outlined),
              ),
            ),
            const SizedBox(height: 12),
            AppFormDropdownField<String?>(
              label: 'Tenant',
              icon: Icons.business_outlined,
              value: _tenantId,
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All active/trial/past due subscriptions'),
                ),
                ...widget.tenants.map(
                  (tenant) => DropdownMenuItem<String?>(
                    value: tenant.id,
                    child: Text(tenant.name),
                  ),
                ),
              ],
              onChanged: _submitting
                  ? null
                  : (value) => setState(() => _tenantId = value),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        AppButton(
          label: 'Continue',
          onPressed: _submitting ? null : _submit,
        ),
      ],
    );
  }
}

Future<int?> showGenerateSubscriptionInvoiceFlow({
  required BuildContext context,
  required List<PlatformTenant> tenants,
  required Future<int> Function(GenerateSubscriptionInvoiceData data) onGenerate,
}) async {
  final data = await showDialog<GenerateSubscriptionInvoiceData>(
    context: context,
    builder: (dialogContext) =>
        GenerateSubscriptionInvoiceDialog(tenants: tenants),
  );
  if (data == null || !context.mounted) return null;

  return showDialog<int>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => _GenerateConfirmDialog(
      data: data,
      onGenerate: onGenerate,
    ),
  );
}

class _GenerateConfirmDialog extends StatefulWidget {
  const _GenerateConfirmDialog({
    required this.data,
    required this.onGenerate,
  });

  final GenerateSubscriptionInvoiceData data;
  final Future<int> Function(GenerateSubscriptionInvoiceData data) onGenerate;

  @override
  State<_GenerateConfirmDialog> createState() => _GenerateConfirmDialogState();
}

class _GenerateConfirmDialogState extends State<_GenerateConfirmDialog> {
  bool _submitting = false;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final count = await widget.onGenerate(widget.data);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (resultContext) => AlertDialog(
          title: const Text('Invoices generated'),
          content: Text(
            count == 0
                ? 'No new invoices were created. Eligible subscriptions may '
                    'already have invoices for this billing period.'
                : 'Invoices generated successfully for $count tenant(s).',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(resultContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (mounted) {
        Navigator.of(context).pop(count);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm generation'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.data.tenantId == null
                ? 'Generate subscription invoices for billing period '
                    '${widget.data.billingPeriodLabel} for all eligible '
                    'subscriptions?'
                : 'Generate a subscription invoice for billing period '
                    '${widget.data.billingPeriodLabel} for the selected tenant?',
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        AppButton(
          label: _submitting ? 'Generating...' : 'Generate',
          isLoading: _submitting,
          onPressed: _submitting ? null : _submit,
        ),
      ],
    );
  }
}
