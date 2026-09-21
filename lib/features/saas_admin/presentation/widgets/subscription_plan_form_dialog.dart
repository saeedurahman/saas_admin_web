import 'package:flutter/material.dart';

import '../../domain/entities/subscription_plan.dart';
import '../../domain/entities/subscription_plan_update_data.dart';

/// Create/edit form for a plan. Pass [plan] to edit; returns the entered
/// [SubscriptionPlanUpdateData], or null when cancelled.
class SubscriptionPlanFormDialog extends StatefulWidget {
  const SubscriptionPlanFormDialog({super.key, this.plan});

  final SubscriptionPlan? plan;

  @override
  State<SubscriptionPlanFormDialog> createState() =>
      _SubscriptionPlanFormDialogState();
}

class _SubscriptionPlanFormDialogState
    extends State<SubscriptionPlanFormDialog> {
  static final _pricePattern = RegExp(r'^\d+(\.\d{1,2})?$');

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _monthly;
  late final TextEditingController _annual;
  late final TextEditingController _maxUsers;
  late final TextEditingController _maxStudents;
  late final Map<String, bool> _flags;

  bool get _isEdit => widget.plan != null;

  @override
  void initState() {
    super.initState();
    final plan = widget.plan;
    _name = TextEditingController(text: plan?.name ?? '');
    _monthly = TextEditingController(text: plan?.priceMonthly ?? '');
    _annual = TextEditingController(text: plan?.priceAnnual ?? '');
    _maxUsers = TextEditingController(text: plan?.maxUsers?.toString() ?? '');
    _maxStudents =
        TextEditingController(text: plan?.maxStudents?.toString() ?? '');
    // Feature flags are opt-out (a missing key means "allowed") and this form
    // exposes none of them. Carry the plan's existing map through unchanged so
    // an edit never drops an explicit `false` that was set through the API.
    _flags = Map.of(plan?.featureFlags ?? const {});
  }

  @override
  void dispose() {
    _name.dispose();
    _monthly.dispose();
    _annual.dispose();
    _maxUsers.dispose();
    _maxStudents.dispose();
    super.dispose();
  }

  String? _validatePrice(String? value, {required bool required}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return required ? 'Required' : null;
    return _pricePattern.hasMatch(text) ? null : 'Enter a valid amount';
  }

  String? _validateLimit(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final parsed = int.tryParse(text);
    return parsed != null && parsed >= 1 ? null : 'Enter a whole number ≥ 1';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    String? optional(TextEditingController c) =>
        c.text.trim().isEmpty ? null : c.text.trim();
    Navigator.pop(
      context,
      SubscriptionPlanUpdateData(
        name: _name.text.trim(),
        priceMonthly: _monthly.text.trim(),
        priceAnnual: optional(_annual),
        maxUsers: int.tryParse(_maxUsers.text.trim()),
        maxStudents: int.tryParse(_maxStudents.text.trim()),
        featureFlags: Map.unmodifiable(_flags),
      ),
    );
  }

  InputDecoration _decoration(String label) =>
      InputDecoration(labelText: label, border: const OutlineInputBorder());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEdit ? 'Edit plan' : 'Create plan'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: _decoration('Name'),
                  validator: (value) => (value?.trim().isEmpty ?? true)
                      ? 'Required'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _monthly,
                  decoration: _decoration('Monthly price'),
                  keyboardType: TextInputType.number,
                  validator: (value) => _validatePrice(value, required: true),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _annual,
                  decoration: _decoration('Annual price (optional)'),
                  keyboardType: TextInputType.number,
                  validator: (value) => _validatePrice(value, required: false),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _maxUsers,
                  decoration: _decoration('Max users (blank = unlimited)'),
                  keyboardType: TextInputType.number,
                  validator: _validateLimit,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _maxStudents,
                  decoration: _decoration('Max students (blank = unlimited)'),
                  keyboardType: TextInputType.number,
                  validator: _validateLimit,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(_isEdit ? 'Save' : 'Create'),
        ),
      ],
    );
  }
}
