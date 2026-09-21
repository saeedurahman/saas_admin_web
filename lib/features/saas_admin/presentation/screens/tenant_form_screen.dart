import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import 'package:madaris_core/widgets/app_button.dart';
import 'package:madaris_core/widgets/app_text_field.dart';
import 'package:madaris_core/widgets/form/app_form_card.dart';
import 'package:madaris_core/widgets/form/app_form_dropdown_field.dart';
import 'package:madaris_core/widgets/form/app_form_section.dart';
import '../../domain/entities/tenant_form_data.dart';
import '../../domain/entities/tenant_type_constants.dart';
import '../cubit/tenant_form_cubit.dart';
import '../cubit/tenant_form_state.dart';
import '../widgets/tenant_credentials_dialog.dart';

class TenantFormScreen extends StatefulWidget {
  const TenantFormScreen({super.key});

  @override
  State<TenantFormScreen> createState() => _TenantFormScreenState();
}

class _TenantFormScreenState extends State<TenantFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _slugController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _adminEmailController = TextEditingController();
  final _adminFullNameController = TextEditingController();
  final _adminPasswordController = TextEditingController();
  String _tenantType = TenantTypeConstants.defaultType;

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _addressController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _adminEmailController.dispose();
    _adminFullNameController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }

  TenantFormData _readFormData() {
    return TenantFormData(
      name: _nameController.text,
      slug: _slugController.text,
      address: _addressController.text,
      contactEmail: _contactEmailController.text,
      contactPhone: _contactPhoneController.text,
      adminEmail: _adminEmailController.text,
      adminFullName: _adminFullNameController.text,
      adminPassword: _adminPasswordController.text,
      tenantType: _tenantType,
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<TenantFormCubit>().submit(_readFormData());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TenantFormCubit(sl()),
      child: BlocConsumer<TenantFormCubit, TenantFormState>(
        listener: (context, state) async {
          if (state is TenantFormSuccess) {
            await showTenantCredentialsDialog(context, state.result);
            if (context.mounted) {
              context.pop(true);
            }
          }
        },
        builder: (context, state) {
          final fieldErrors = switch (state) {
            TenantFormEditing(:final fieldErrors) => fieldErrors,
            TenantFormServerError(:final fieldErrors) => fieldErrors,
            _ => const <String, String>{},
          };
          final isSubmitting =
              state is TenantFormEditing && state.isSubmitting;
          final serverError =
              state is TenantFormServerError ? state.message : null;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Create tenant'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),
            body: AppFormCard(
              scrollable: true,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppFormSection(
                      title: 'Tenant details',
                      children: [
                        AppFormDropdownField<String>(
                          label: 'Tenant type',
                          icon: Icons.category_outlined,
                          required: true,
                          value: _tenantType,
                          items: [
                            for (final (value, label)
                                in TenantTypeConstants.types)
                              DropdownMenuItem(value: value, child: Text(label)),
                          ],
                          onChanged: isSubmitting
                              ? null
                              : (value) {
                                  if (value != null) {
                                    setState(() => _tenantType = value);
                                  }
                                },
                        ),
                        AppTextField(
                          controller: _nameController,
                          label: 'Name',
                          validator: (value) =>
                              fieldErrors['name'] ??
                              (value == null || value.trim().isEmpty
                                  ? 'Name is required'
                                  : null),
                        ),
                        AppTextField(
                          controller: _slugController,
                          label: 'Slug',
                          hint: 'new-school',
                          validator: (value) =>
                              fieldErrors['slug'] ??
                              (value == null || value.trim().isEmpty
                                  ? 'Slug is required'
                                  : null),
                        ),
                        TextFormField(
                          controller: _addressController,
                          decoration:
                              const InputDecoration(labelText: 'Address'),
                          maxLines: 2,
                        ),
                        AppTextField(
                          controller: _contactEmailController,
                          label: 'Contact email',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        AppTextField(
                          controller: _contactPhoneController,
                          label: 'Contact phone',
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppFormCard.sectionGap),
                    AppFormSection(
                      title: 'First admin user',
                      children: [
                        AppTextField(
                          controller: _adminEmailController,
                          label: 'Admin email',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) =>
                              fieldErrors['adminEmail'] ??
                              (value == null || value.trim().isEmpty
                                  ? 'Admin email is required'
                                  : null),
                        ),
                        AppTextField(
                          controller: _adminFullNameController,
                          label: 'Admin full name',
                          validator: (value) =>
                              fieldErrors['adminFullName'] ??
                              (value == null || value.trim().isEmpty
                                  ? 'Admin name is required'
                                  : null),
                        ),
                        AppTextField(
                          controller: _adminPasswordController,
                          label: 'Admin password (optional)',
                          obscureText: true,
                          validator: (value) => fieldErrors['adminPassword'],
                        ),
                      ],
                    ),
                    if (serverError != null) ...[
                      const SizedBox(height: AppFormCard.fieldGap),
                      Text(
                        serverError,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppFormCard.sectionGap),
                    AppButton(
                      label: 'Create tenant',
                      isLoading: isSubmitting,
                      onPressed: () => _submit(context),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
