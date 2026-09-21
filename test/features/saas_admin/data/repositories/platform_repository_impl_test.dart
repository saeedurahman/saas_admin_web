import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saas_admin_web/features/saas_admin/data/datasources/platform_remote_data_source.dart';
import 'package:saas_admin_web/features/saas_admin/data/repositories/platform_repository_impl.dart';
import 'package:saas_admin_web/features/saas_admin/domain/entities/tenant_form_data.dart';

/// Records the request and answers `POST /platform/tenants` with a created
/// tenant that echoes the requested `tenant_type`.
class _CapturingAdapter implements HttpClientAdapter {
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    final body = options.data as Map<String, dynamic>;
    return ResponseBody.fromString(
      jsonEncode({
        'tenant': {
          'id': 't1',
          'name': body['name'],
          'slug': body['slug'],
          'status': 'trial',
          'tenant_type': body['tenant_type'],
        },
        'admin_user': {
          'id': 'u1',
          'email': body['admin_email'],
          'full_name': body['admin_full_name'],
          'is_active': true,
        },
        'temp_password': 'TempPass123!',
      }),
      201,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _CapturingAdapter adapter;
  late PlatformRepositoryImpl repository;

  setUp(() {
    adapter = _CapturingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://test'))
      ..httpClientAdapter = adapter;
    repository = PlatformRepositoryImpl(PlatformRemoteDataSource(dio));
  });

  const base = TenantFormData(
    name: 'New School',
    slug: 'new-school',
    adminEmail: 'admin@school.com',
    adminFullName: 'Admin User',
  );

  for (final type in ['madrasa', 'masjid', 'academy']) {
    test('createTenant sends tenant_type "$type" in the POST body', () async {
      final result = await repository.createTenant(
        base.copyWith(tenantType: type),
      );

      expect(adapter.request!.method, 'POST');
      expect(adapter.request!.path, '/api/v1/platform/tenants');
      expect((adapter.request!.data as Map)['tenant_type'], type);
      // The created tenant's type round-trips into the entity.
      expect(result.tenant.tenantType, type);
    });
  }

  test('createTenant defaults to madrasa when no type is chosen', () async {
    await repository.createTenant(base);

    expect((adapter.request!.data as Map)['tenant_type'], 'madrasa');
  });
}
