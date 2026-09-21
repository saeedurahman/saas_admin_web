import 'package:flutter/material.dart';

import 'package:madaris_core/utils/date_formatter.dart';
import 'package:madaris_core/widgets/app_button.dart';
import 'package:madaris_core/widgets/app_text_field.dart';
import 'package:madaris_core/widgets/form/app_form_dropdown_field.dart';
import '../../domain/entities/generate_subscription_invoice_data.dart';
import '../../domain/entities/platform_tenant.dart';

enum _InvoiceMode { label, dated }

enum _LengthMode { months, endDate }

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
  final _monthsController = TextEditingController();
  _InvoiceMode _mode = _InvoiceMode.label;
  _LengthMode _lengthMode = _LengthMode.months;
  String? _tenantId;
  DateTime? _dueDate;
  DateTime? _periodStart;
  DateTime? _periodEnd;
  String? _error;

  @override
  void dispose() {
    _periodController.dispose();
    _monthsController.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDate(
    DateTime? initial, {
    required String helpText,
  }) {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 10, 12, 31),
      helpText: helpText,
    );
  }

  Future<void> _pickDueDate() async {
    final picked = await _pickDate(_dueDate, helpText: 'Select due date');
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickPeriodStart() async {
    final picked = await _pickDate(
      _periodStart,
      helpText: 'Select period start',
    );
    if (picked != null) setState(() => _periodStart = picked);
  }

  Future<void> _pickPeriodEnd() async {
    final picked = await _pickDate(
      _periodEnd ?? _periodStart,
      helpText: 'Select period end',
    );
    if (picked != null) setState(() => _periodEnd = picked);
  }

  void _submit() {
    final label = _periodController.text.trim();
    int? months;
    DateTime? start;
    DateTime? end;

    if (_mode == _InvoiceMode.label) {
      if (label.isEmpty) {
        setState(() => _error = 'Billing period label is required');
        return;
      }
    } else {
      start = _periodStart;
      if (start == null) {
        setState(() => _error = 'Period start is required');
        return;
      }
      if (_lengthMode == _LengthMode.months) {
        months = int.tryParse(_monthsController.text.trim());
        if (months == null || months < 1 || months > 120) {
          setState(() => _error = 'Enter a period length of 1–120 months');
          return;
        }
      } else {
        end = _periodEnd;
        if (end == null) {
          setState(() => _error = 'Period end is required');
          return;
        }
        if (end.isBefore(start)) {
          setState(() => _error = 'Period end must not be before period start');
          return;
        }
      }
    }
    if (_dueDate == null) {
      setState(() => _error = 'Due date is required');
      return;
    }

    Navigator.of(context).pop(
      GenerateSubscriptionInvoiceData(
        billingPeriodLabel: label.isEmpty ? null : label,
        dueDate: _dueDate!,
        tenantId: _tenantId,
        periodStart: start,
        periodMonths: months,
        periodEnd: end,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Generate invoices'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<_InvoiceMode>(
                segments: const [
                  ButtonSegment(
                    value: _InvoiceMode.label,
                    label: Text('Billing label'),
                  ),
                  ButtonSegment(
                    value: _InvoiceMode.dated,
                    label: Text('Custom dates'),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (selection) => setState(() {
                  _mode = selection.first;
                  _error = null;
                }),
              ),
              const SizedBox(height: 12),
              if (_mode == _InvoiceMode.dated) ..._datedFields(context),
              AppTextField(
                controller: _periodController,
                label: _mode == _InvoiceMode.label
                    ? 'Billing period label'
                    : 'Billing period label (optional)',
                hint: _mode == _InvoiceMode.label
                    ? '2026-08'
                    : 'Defaults to the date range',
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Due date'),
                subtitle: Text(
                  DateFormatter.toApiDate(_dueDate) ?? 'Select due date',
                ),
                trailing: IconButton(
                  onPressed: _pickDueDate,
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
                onChanged: (value) => setState(() => _tenantId = value),
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        AppButton(label: 'Continue', onPressed: _submit),
      ],
    );
  }

  List<Widget> _datedFields(BuildContext context) {
    return [
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Period start'),
        subtitle: Text(
          DateFormatter.toApiDate(_periodStart) ?? 'Select period start',
        ),
        trailing: IconButton(
          onPressed: _pickPeriodStart,
          icon: const Icon(Icons.calendar_today_outlined),
        ),
      ),
      SegmentedButton<_LengthMode>(
        segments: const [
          ButtonSegment(value: _LengthMode.months, label: Text('Months')),
          ButtonSegment(value: _LengthMode.endDate, label: Text('End date')),
        ],
        selected: {_lengthMode},
        onSelectionChanged: (selection) => setState(() {
          _lengthMode = selection.first;
          _error = null;
        }),
      ),
      const SizedBox(height: 12),
      if (_lengthMode == _LengthMode.months)
        AppTextField(
          controller: _monthsController,
          label: 'Period length (months)',
          hint: 'e.g. 14',
          keyboardType: TextInputType.number,
        )
      else
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Period end'),
          subtitle: Text(
            DateFormatter.toApiDate(_periodEnd) ?? 'Select period end',
          ),
          trailing: IconButton(
            onPressed: _pickPeriodEnd,
            icon: const Icon(Icons.calendar_today_outlined),
          ),
        ),
      const SizedBox(height: 12),
    ];
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

  /// e.g. "billing period 2026-08" or "the period 2026-01-01 → 14 months".
  String get _periodDescription {
    final data = widget.data;
    if (!data.isDated) return 'billing period ${data.billingPeriodLabel}';
    final start = DateFormatter.toApiDate(data.periodStart);
    final length = data.periodMonths != null
        ? '${data.periodMonths} month(s)'
        : 'to ${DateFormatter.toApiDate(data.periodEnd)}';
    return 'the period starting $start for $length';
  }

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
                ? 'Generate subscription invoices for $_periodDescription '
                    'for all eligible subscriptions?'
                : 'Generate a subscription invoice for $_periodDescription '
                    'for the selected tenant?',
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
