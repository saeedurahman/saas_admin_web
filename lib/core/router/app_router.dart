import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../features/saas_admin/domain/entities/platform_tenant.dart';
import '../../features/saas_admin/presentation/cubit/saas_auth_cubit.dart';
import '../../features/saas_admin/presentation/cubit/saas_auth_state.dart';
import '../../features/saas_admin/presentation/screens/platform_dashboard_screen.dart';
import '../../features/saas_admin/presentation/screens/saas_login_screen.dart';
import '../../features/saas_admin/presentation/screens/subscription_invoice_detail_screen.dart';
import '../../features/saas_admin/presentation/screens/subscription_invoice_list_screen.dart';
import '../../features/saas_admin/presentation/screens/subscription_plan_list_screen.dart';
import '../../features/saas_admin/presentation/screens/tenant_form_screen.dart';
import '../../features/saas_admin/presentation/screens/tenant_list_screen.dart';
import '../../features/saas_admin/presentation/screens/tenant_subscription_screen.dart';
import '../../features/saas_admin/presentation/widgets/saas_admin_shell.dart';
import 'app_routes.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter createAppRouter(SaasAuthCubit authCubit) {
  final refresh = GoRouterRefreshStream(authCubit.stream);

  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: refresh,
    redirect: (context, state) {
      final authState = authCubit.state;
      final path = state.matchedLocation;
      final isLoginRoute = path == AppRoutes.login;

      if (authState is SaasAuthInitial || authState is SaasAuthLoading) {
        return null;
      }

      final authenticated = authState is SaasAuthAuthenticated;

      if (authenticated && isLoginRoute) {
        return AppRoutes.dashboard;
      }

      if (!authenticated && !isLoginRoute) {
        return AppRoutes.login;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (_, _) => const SaasLoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => SaasAdminShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder: (_, _) => const NoTransitionPage(
              child: PlatformDashboardScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.tenants,
            pageBuilder: (_, _) => const NoTransitionPage(
              child: TenantListScreen(),
            ),
            routes: [
              GoRoute(
                path: 'new',
                pageBuilder: (_, _) => const NoTransitionPage(
                  child: TenantFormScreen(),
                ),
              ),
              GoRoute(
                path: ':tenantId/subscription',
                pageBuilder: (_, state) => NoTransitionPage(
                  child: TenantSubscriptionScreen(
                    tenant: state.extra as PlatformTenant,
                  ),
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.plans,
            pageBuilder: (_, _) => const NoTransitionPage(
              child: SubscriptionPlanListScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.invoices,
            pageBuilder: (_, _) => const NoTransitionPage(
              child: SubscriptionInvoiceListScreen(),
            ),
            routes: [
              GoRoute(
                path: ':invoiceId',
                pageBuilder: (_, state) => NoTransitionPage(
                  child: SubscriptionInvoiceDetailScreen(
                    invoiceId: state.pathParameters['invoiceId']!,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
