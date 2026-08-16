import 'package:equatable/equatable.dart';

class TenantFormData extends Equatable {
  const TenantFormData({
    this.name = '',
    this.slug = '',
    this.address = '',
    this.contactEmail = '',
    this.contactPhone = '',
    this.adminEmail = '',
    this.adminFullName = '',
    this.adminPassword = '',
  });

  final String name;
  final String slug;
  final String address;
  final String contactEmail;
  final String contactPhone;
  final String adminEmail;
  final String adminFullName;
  final String adminPassword;

  TenantFormData copyWith({
    String? name,
    String? slug,
    String? address,
    String? contactEmail,
    String? contactPhone,
    String? adminEmail,
    String? adminFullName,
    String? adminPassword,
  }) {
    return TenantFormData(
      name: name ?? this.name,
      slug: slug ?? this.slug,
      address: address ?? this.address,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      adminEmail: adminEmail ?? this.adminEmail,
      adminFullName: adminFullName ?? this.adminFullName,
      adminPassword: adminPassword ?? this.adminPassword,
    );
  }

  Map<String, String?> validate() {
    final errors = <String, String?>{};

    if (name.trim().isEmpty) {
      errors['name'] = 'Name is required';
    }
    if (slug.trim().isEmpty) {
      errors['slug'] = 'Slug is required';
    } else if (!RegExp(r'^[a-z0-9-]+$').hasMatch(slug.trim())) {
      errors['slug'] = 'Use lowercase letters, numbers, and hyphens';
    }
    if (adminEmail.trim().isEmpty) {
      errors['adminEmail'] = 'Admin email is required';
    } else if (!adminEmail.contains('@')) {
      errors['adminEmail'] = 'Enter a valid email';
    }
    if (adminFullName.trim().isEmpty) {
      errors['adminFullName'] = 'Admin name is required';
    }
    if (adminPassword.isNotEmpty && adminPassword.length < 8) {
      errors['adminPassword'] = 'Password must be at least 8 characters';
    }

    return errors;
  }

  @override
  List<Object?> get props => [
        name,
        slug,
        address,
        contactEmail,
        contactPhone,
        adminEmail,
        adminFullName,
        adminPassword,
      ];
}
