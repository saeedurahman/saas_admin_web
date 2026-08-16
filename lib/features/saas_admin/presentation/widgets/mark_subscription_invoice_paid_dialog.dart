import 'package:flutter/material.dart';

import 'package:madaris_core/widgets/app_button.dart';
import 'package:madaris_core/widgets/app_text_field.dart';
import 'package:madaris_core/widgets/form/app_form_dropdown_field.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/mark_invoice_paid_data.dart';
import '../../domain/entities/subscription_invoice.dart';
import '../../domain/entities/subscription_invoice_constants.dart';
import '../../domain/repositories/platform_repository.dart';

class MarkSubscriptionInvoicePaidDialog extends StatefulWidget {
  const MarkSubscriptionInvoicePaidDialog({
    super.key,
    required this.invoice,
  });

  final SubscriptionInvoice invoice;

  @override
  State<MarkSubscriptionInvoicePaidDialog> createState() =>
      _MarkSubscriptionInvoicePaidDialogState();
}

class _MarkSubscriptionInvoicePaidDialogState
    extends State<MarkSubscriptionInvoicePaidDialog> {
  String _paymentMethod = SubscriptionInvoiceConstants.paymentMethods.first.$1;
  final _referenceController = TextEditingController();
  DateTime? _paidDate;
  bool _submitting = false;
  String? _error;

  DateTime get _minPaidDate {
    final due = widget.invoice.dueDate;
    final created = widget.invoice.createdAt;
    return due.isAfter(created) ? due : created;
  }

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _pickPaidDate() async {
    final now = DateTime.now();
    final min = DateTime(_minPaidDate.year, _minPaidDate.month, _minPaidDate.day);
    final initial = _paidDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(min) ? min : initial,
      firstDate: min,
      lastDate: now,
      helpText: 'Select paid date',
    );
    if (picked != null) {
      setState(() => _paidDate = picked);
    }
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final repository = sl<PlatformRepository>();
      final updated = await repository.markInvoicePaid(
        widget.invoice.id,
        MarkInvoicePaidData(
          paymentMethod: _paymentMethod,
          referenceNumber: _referenceController.text.trim().isEmpty
              ? null
              : _referenceController.text.trim(),
          paidDate: _paidDate,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(updated);
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
      title: Text('Mark ${widget.invoice.invoiceNumber} as paid'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppFormDropdownField<String>(
              label: 'Payment method',
              icon: Icons.payments_outlined,
              value: _paymentMethod,
              items: SubscriptionInvoiceConstants.paymentMethods
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item.$1,
                      child: Text(item.$2),
                    ),
                  )
                  .toList(),
              onChanged: _submitting
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() => _paymentMethod = value);
                      }
                    },
            ),
            const SizedBox(height: 12),
            IgnorePointer(
              ignoring: _submitting,
              child: AppTextField(
                controller: _referenceController,
                label: 'Reference number (optional)',
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Paid date (optional)'),
              subtitle: Text(
                _paidDate == null
                    ? 'Defaults to today'
                    : _paidDate!.toIso8601String().split('T').first,
              ),
              trailing: IconButton(
                onPressed: _submitting ? null : _pickPaidDate,
                icon: const Icon(Icons.calendar_today_outlined),
              ),
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
          label: _submitting ? 'Saving...' : 'Mark paid',
          onPressed: _submitting ? null : _submit,
        ),
      ],
    );
  }
}

Future<SubscriptionInvoice?> showMarkSubscriptionInvoicePaidDialog({
  required BuildContext context,
  required SubscriptionInvoice invoice,
}) {
  return showDialog<SubscriptionInvoice>(
    context: context,
    builder: (dialogContext) =>
        MarkSubscriptionInvoicePaidDialog(invoice: invoice),
  );
}
