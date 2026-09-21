/// Tenant types accepted by `POST /platform/tenants` (`tenant_type`).
abstract final class TenantTypeConstants {
  TenantTypeConstants._();

  /// Backend default when the field is omitted.
  static const defaultType = 'madrasa';

  static const types = [
    ('madrasa', 'Madrasa'),
    ('masjid', 'Masjid'),
    ('academy', 'Academy'),
  ];

  static String label(String value) {
    for (final item in types) {
      if (item.$1 == value) return item.$2;
    }
    return value;
  }
}
