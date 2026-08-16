import 'dart:async';

import 'package:dio/dio.dart';
import 'package:madaris_core/config/app_config.dart';

import '../storage/secure_storage_service.dart';
import 'api_constants.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage, this._refreshDio);

  final SecureStorageService _storage;
  final Dio _refreshDio;

  Completer<void>? _refreshLock;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['skipAuth'] == true) {
      return handler.next(options);
    }

    final token = await _storage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    if (err.requestOptions.extra['retried'] == true) {
      return handler.next(err);
    }

    try {
      final accessToken = await _refreshAccessToken();
      if (accessToken == null) {
        await _storage.clearTokens();
        return handler.next(err);
      }

      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $accessToken';
      retryOptions.extra['retried'] = true;

      final client = err.requestOptions.extra['dio'] as Dio?;
      if (client == null) {
        return handler.next(err);
      }

      final response = await client.fetch(retryOptions);
      return handler.resolve(response);
    } catch (_) {
      await _storage.clearTokens();
      return handler.next(err);
    }
  }

  Future<String?> _refreshAccessToken() async {
    if (_refreshLock != null) {
      await _refreshLock!.future;
      return _storage.getAccessToken();
    }

    _refreshLock = Completer<void>();
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        _refreshLock!.complete();
        return null;
      }

      final response = await _refreshDio.post(
        ApiConstants.authRefresh,
        data: {'refresh_token': refreshToken},
      );

      final data = response.data as Map<String, dynamic>;
      final newAccess = data['access_token'] as String;
      final newRefresh = data['refresh_token'] as String;
      await _storage.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );

      _refreshLock!.complete();
      return newAccess;
    } catch (error, stackTrace) {
      if (!_refreshLock!.isCompleted) {
        _refreshLock!.completeError(error, stackTrace);
      }
      rethrow;
    } finally {
      _refreshLock = null;
    }
  }
}

Dio createRefreshDio() {
  return Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );
}
