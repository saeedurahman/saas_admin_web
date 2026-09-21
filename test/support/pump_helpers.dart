import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:saas_admin_web/core/di/injection.dart';
import 'package:saas_admin_web/features/auth/domain/entities/auth_session.dart';
import 'package:saas_admin_web/features/auth/domain/entities/user.dart';
import 'package:saas_admin_web/features/saas_admin/domain/repositories/platform_repository.dart';
import 'package:saas_admin_web/features/saas_admin/domain/repositories/saas_auth_repository.dart';
import 'package:saas_admin_web/features/saas_admin/presentation/cubit/saas_auth_cubit.dart';
import 'package:saas_admin_web/features/saas_admin/presentation/cubit/saas_auth_state.dart';

class _UnusedAuthRepository implements SaasAuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubAuthCubit extends SaasAuthCubit {
  _StubAuthCubit(List<String> permissions) : super(_UnusedAuthRepository()) {
    emit(
      SaasAuthAuthenticated(
        session: AuthSession(
          user: const User(
            id: 'u1',
            email: 'admin@example.com',
            fullName: 'Admin',
            isActive: true,
          ),
          roles: const ['saas_admin'],
          permissions: permissions,
        ),
      ),
    );
  }
}

/// Registers [repository] in the service locator and pumps [screen] under an
/// authenticated [SaasAuthCubit] holding [permissions].
Future<void> pumpScreen(
  WidgetTester tester, {
  required Widget screen,
  required PlatformRepository repository,
  required List<String> permissions,
}) async {
  await sl.reset();
  sl.registerSingleton<PlatformRepository>(repository);
  addTearDown(sl.reset);

  await tester.binding.setSurfaceSize(const Size(1400, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    BlocProvider<SaasAuthCubit>(
      create: (_) => _StubAuthCubit(permissions),
      child: MaterialApp(home: Scaffold(body: screen)),
    ),
  );
  await tester.pumpAndSettle();
}

/// Like [pumpScreen], but for screens that call `context.pop` (go_router):
/// [screen] is pushed on top of a placeholder home route so there is
/// something to pop back to.
Future<void> pumpRoutedScreen(
  WidgetTester tester, {
  required Widget screen,
  required PlatformRepository repository,
  required List<String> permissions,
}) async {
  await sl.reset();
  sl.registerSingleton<PlatformRepository>(repository);
  addTearDown(sl.reset);

  await tester.binding.setSurfaceSize(const Size(1400, 1400));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Text('home')),
      ),
      GoRoute(path: '/screen', builder: (_, _) => screen),
    ],
  );

  await tester.pumpWidget(
    BlocProvider<SaasAuthCubit>(
      create: (_) => _StubAuthCubit(permissions),
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  router.push('/screen');
  await tester.pumpAndSettle();
}
