import 'package:dio/dio.dart';
import 'package:madaris_core/errors/dio_error_mapper.dart';

import '../../../../core/network/api_constants.dart';
import '../../../auth/data/models/auth_models.dart';

class SaasAuthRemoteDataSource {
  SaasAuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.authLogin,
        data: {'email': email, 'password': password},
        options: Options(extra: {'skipAuth': true}),
      );
      return LoginResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<MeResponseModel> fetchMe() async {
    try {
      final response = await _dio.get(ApiConstants.authMe);
      return MeResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<void> logout({required String refreshToken}) async {
    try {
      await _dio.post(
        ApiConstants.authLogout,
        data: {'refresh_token': refreshToken},
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}
