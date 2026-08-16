import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:madaris_core/theme/app_theme.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'features/saas_admin/presentation/cubit/saas_auth_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  sl<SaasAuthCubit>().checkSession();
  runApp(const SaasAdminApp());
}

class SaasAdminApp extends StatefulWidget {
  const SaasAdminApp({super.key});

  @override
  State<SaasAdminApp> createState() => _SaasAdminAppState();
}

class _SaasAdminAppState extends State<SaasAdminApp> {
  late final _router = createAppRouter(sl<SaasAuthCubit>());

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<SaasAuthCubit>(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Madaris Platform Admin',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        routerConfig: _router,
      ),
    );
  }
}
