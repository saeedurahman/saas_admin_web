import 'package:dio/dio.dart';
import 'package:madaris_core/config/app_config.dart';

import '../storage/secure_storage_service.dart';
import 'auth_interceptor.dart';

Dio createApiClient({
  required SecureStorageService secureStorage,
  required Dio refreshDio,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  final authInterceptor = AuthInterceptor(secureStorage, refreshDio);

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.extra['dio'] = dio;
        handler.next(options);
      },
    ),
  );
  dio.interceptors.add(authInterceptor);

  return dio;
}
