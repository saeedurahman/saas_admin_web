import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:madaris_core/cubit/safe_cubit.dart';
import 'package:madaris_core/errors/app_exception.dart';
import '../../domain/entities/tenant_form_data.dart';
import '../../domain/repositories/platform_repository.dart';
import 'tenant_form_state.dart';

class TenantFormCubit extends Cubit<TenantFormState> with SafeCubitMixin {
  TenantFormCubit(this._repository)
      : super(const TenantFormEditing(formData: TenantFormData()));

  final PlatformRepository _repository;

  void updateForm(TenantFormData data) {
    final current = state;
    if (current is TenantFormEditing) {
      emit(current.copyWith(formData: data, fieldErrors: {}));
    } else if (current is TenantFormServerError) {
      emit(TenantFormEditing(formData: data));
    }
  }

  Future<void> submit(TenantFormData data) async {
    final validationErrors = data.validate();
    if (validationErrors.isNotEmpty) {
      emit(
        TenantFormEditing(
          formData: data,
          fieldErrors: Map<String, String>.from(
            validationErrors.map((key, value) => MapEntry(key, value!)),
          ),
        ),
      );
      return;
    }

    emit(TenantFormEditing(formData: data, isSubmitting: true));
    await runGuarded(
      () async {
        final result = await _repository.createTenant(data);
        emit(TenantFormSuccess(result));
      },
      onError: (error) {
        if (error is ConflictException &&
            error.message.toLowerCase().contains('slug')) {
          emit(
            TenantFormEditing(
              formData: data,
              fieldErrors: const {'slug': 'This slug is already taken'},
            ),
          );
          return;
        }
        emit(
          TenantFormServerError(
            message: error.message,
            formData: data,
          ),
        );
      },
    );
  }
}
