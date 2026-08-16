import 'package:equatable/equatable.dart';

import '../../domain/entities/tenant_create_result.dart';
import '../../domain/entities/tenant_form_data.dart';

sealed class TenantFormState extends Equatable {
  const TenantFormState();

  @override
  List<Object?> get props => [];
}

class TenantFormEditing extends TenantFormState {
  const TenantFormEditing({
    required this.formData,
    this.fieldErrors = const {},
    this.isSubmitting = false,
  });

  final TenantFormData formData;
  final Map<String, String> fieldErrors;
  final bool isSubmitting;

  TenantFormEditing copyWith({
    TenantFormData? formData,
    Map<String, String>? fieldErrors,
    bool? isSubmitting,
  }) {
    return TenantFormEditing(
      formData: formData ?? this.formData,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [formData, fieldErrors, isSubmitting];
}

class TenantFormSuccess extends TenantFormState {
  const TenantFormSuccess(this.result);

  final TenantCreateResult result;

  @override
  List<Object?> get props => [result];
}

class TenantFormServerError extends TenantFormState {
  const TenantFormServerError({
    required this.message,
    required this.formData,
    this.fieldErrors = const {},
  });

  final String message;
  final TenantFormData formData;
  final Map<String, String> fieldErrors;

  @override
  List<Object?> get props => [message, formData, fieldErrors];
}
