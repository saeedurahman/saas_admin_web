import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/saas_admin/data/datasources/platform_remote_data_source.dart';
import '../../features/saas_admin/data/datasources/saas_auth_remote_data_source.dart';
import '../../features/saas_admin/data/repositories/platform_repository_impl.dart';
import '../../features/saas_admin/data/repositories/saas_auth_repository_impl.dart';
import '../../features/saas_admin/domain/repositories/platform_repository.dart';
import '../../features/saas_admin/domain/repositories/saas_auth_repository.dart';
import '../../features/saas_admin/presentation/cubit/saas_auth_cubit.dart';
import '../network/auth_interceptor.dart';
import '../network/dio_client.dart';
import '../storage/preferences_service.dart';
import '../storage/secure_storage_service.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();

  sl
    ..registerSingleton<SecureStorageService>(SecureStorageService())
    ..registerSingleton<PreferencesService>(PreferencesService(prefs))
    ..registerSingleton<Dio>(createRefreshDio(), instanceName: 'refreshDio')
    ..registerSingleton<Dio>(
      createApiClient(
        secureStorage: sl(),
        refreshDio: sl(instanceName: 'refreshDio'),
      ),
    )
    ..registerLazySingleton<SaasAuthRemoteDataSource>(
      () => SaasAuthRemoteDataSource(sl()),
    )
    ..registerLazySingleton<SaasAuthRepository>(
      () => SaasAuthRepositoryImpl(sl(), sl(), sl()),
    )
    ..registerSingleton<SaasAuthCubit>(SaasAuthCubit(sl()))
    ..registerLazySingleton<PlatformRemoteDataSource>(
      () => PlatformRemoteDataSource(sl()),
    )
    ..registerLazySingleton<PlatformRepository>(
      () => PlatformRepositoryImpl(sl()),
    );
}
