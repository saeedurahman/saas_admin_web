import 'package:flutter/material.dart';
import 'package:madaris_core/utils/date_formatter.dart';
import 'package:madaris_core/widgets/form/app_form_card.dart';

enum _PeriodMode { cycleDefault, months, endDate }

/// Lets the admin override the first subscription period's length: the
/// billing-cycle default, a number of months (1–120), or an explicit end date.
/// The two overrides are mutually exclusive, matching the backend.
class PeriodOverrideField extends StatefulWidget {
  const PeriodOverrideField({
    super.key,
    required this.enabled,
    required this.periodMonths,
    required this.periodEnd,
    required this.periodStart,
    required this.onChanged,
    required this.onValidationChanged,
    this.showError = false,
  });

  final bool enabled;
  final int? periodMonths;
  final DateTime? periodEnd;
  final DateTime? periodStart;
  final void Function({int? months, DateTime? end}) onChanged;

  /// Reports the control's current validity: null when complete, otherwise
  /// the message that should block saving.
  final ValueChanged<String?> onValidationChanged;

  /// Show the empty-months error even before the user has typed anything
  /// (set after a blocked submit).
  final bool showError;

  @override
  State<PeriodOverrideField> createState() => _PeriodOverrideFieldState();
}

class _PeriodOverrideFieldState extends State<PeriodOverrideField> {
  late _PeriodMode _mode;
  late final TextEditingController _months;

  @override
  void initState() {
    super.initState();
    _mode = widget.periodMonths != null
        ? _PeriodMode.months
        : widget.periodEnd != null
            ? _PeriodMode.endDate
            : _PeriodMode.cycleDefault;
    _months = TextEditingController(
      text: widget.periodMonths?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _months.dispose();
    super.dispose();
  }

  static int? _parseMonths(String text) {
    final value = int.tryParse(text.trim());
    return value != null && value >= 1 && value <= 120 ? value : null;
  }

  static const _emptyMessage = 'Please enter number of months';
  static const _invalidMessage = 'Enter 1–120 months';

  /// Blocking error for the current input; only "Custom months" can have one.
  String? get _validationError {
    if (_mode != _PeriodMode.months) return null;
    final text = _months.text.trim();
    if (text.isEmpty) return _emptyMessage;
    return _parseMonths(text) == null ? _invalidMessage : null;
  }

  /// Inline text: invalid input shows immediately, empty only once a submit
  /// was blocked so the untouched field isn't flagged on selection.
  String? get _displayedError {
    final error = _validationError;
    if (error == _emptyMessage && !widget.showError) return null;
    return error;
  }

  void _setMode(_PeriodMode mode) {
    setState(() => _mode = mode);
    // Switching modes drops the previous override; the new one starts blank.
    _months.clear();
    widget.onChanged();
    widget.onValidationChanged(_validationError);
  }

  Future<void> _pickEnd() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.periodEnd ?? widget.periodStart ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Select period end',
    );
    if (picked == null) return;
    widget.onChanged(end: picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<_PeriodMode>(
          initialValue: _mode,
          decoration: const InputDecoration(
            labelText: 'Period length',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: _PeriodMode.cycleDefault,
              child: Text('Default for billing cycle'),
            ),
            DropdownMenuItem(
              value: _PeriodMode.months,
              child: Text('Custom number of months'),
            ),
            DropdownMenuItem(
              value: _PeriodMode.endDate,
              child: Text('Custom end date'),
            ),
          ],
          onChanged: widget.enabled
              ? (value) {
                  if (value != null) _setMode(value);
                }
              : null,
        ),
        if (_mode == _PeriodMode.months) ...[
          const SizedBox(height: AppFormCard.fieldGap),
          TextField(
            controller: _months,
            enabled: widget.enabled,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Period months',
              hintText: 'e.g. 14',
              border: const OutlineInputBorder(),
              errorText: _displayedError,
            ),
            onChanged: (text) {
              setState(() {});
              widget.onChanged(months: _parseMonths(text));
              widget.onValidationChanged(_validationError);
            },
          ),
        ],
        if (_mode == _PeriodMode.endDate)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Period end'),
            subtitle: Text(
              DateFormatter.formatFriendly(widget.periodEnd) ??
                  'Select period end',
            ),
            trailing: widget.enabled
                ? IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _pickEnd,
                  )
                : null,
          ),
      ],
    );
  }
}
