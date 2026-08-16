import 'package:dio/dio.dart';
import 'package:madaris_core/errors/dio_error_mapper.dart';

import '../../../../core/network/api_constants.dart';
import '../models/platform_models.dart';

class PlatformRemoteDataSource {
  PlatformRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<PlatformTenantModel>> fetchTenants() async {
    try {
      final response = await _dio.get(ApiConstants.platformTenants);
      return (response.data as List<dynamic>)
          .map(
            (item) =>
                PlatformTenantModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<TenantCreateResponseModel> createTenant(
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.platformTenants,
        data: body,
      );
      return TenantCreateResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<TenantSubscriptionModel?> fetchTenantSubscription(
    String tenantId,
  ) async {
    try {
      final response = await _dio.get(
        ApiConstants.platformTenantSubscription(tenantId),
      );
      return TenantSubscriptionModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      throw mapDioException(error);
    }
  }

  Future<TenantSubscriptionModel> assignTenantSubscription(
    String tenantId,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.put(
        ApiConstants.platformTenantSubscription(tenantId),
        data: body,
      );
      return TenantSubscriptionModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<List<SubscriptionPlanModel>> fetchSubscriptionPlans({
    bool activeOnly = false,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.platformSubscriptionPlans,
        queryParameters: {'active_only': activeOnly},
      );
      return (response.data as List<dynamic>)
          .map(
            (item) =>
                SubscriptionPlanModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<SubscriptionPlanModel> createSubscriptionPlan(
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.platformSubscriptionPlans,
        data: body,
      );
      return SubscriptionPlanModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<PlatformDashboardModel> fetchDashboard() async {
    try {
      final response = await _dio.get(ApiConstants.platformDashboard);
      return PlatformDashboardModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<SubscriptionInvoiceListResponseModel> fetchSubscriptionInvoices({
    required Map<String, dynamic> queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.platformSubscriptionInvoices,
        queryParameters: queryParameters,
      );
      return SubscriptionInvoiceListResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<List<SubscriptionInvoiceModel>> generateSubscriptionInvoices(
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.platformSubscriptionInvoicesGenerate,
        data: body,
      );
      return (response.data as List<dynamic>)
          .map(
            (item) => SubscriptionInvoiceModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<SubscriptionInvoiceModel> markSubscriptionInvoicePaid(
    String invoiceId,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.platformSubscriptionInvoiceMarkPaid(invoiceId),
        data: body,
      );
      return SubscriptionInvoiceModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<SubscriptionInvoiceModel> fetchSubscriptionInvoice(
    String invoiceId,
  ) async {
    try {
      final response = await _dio.get(
        ApiConstants.platformSubscriptionInvoice(invoiceId),
      );
      return SubscriptionInvoiceModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}
