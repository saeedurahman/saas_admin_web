import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../cubit/saas_auth_cubit.dart';

class SaasAdminShell extends StatelessWidget {
  const SaasAdminShell({super.key, required this.child});

  final Widget child;

  int _selectedIndex(String location) {
    if (location.startsWith(AppRoutes.invoices)) return 3;
    if (location.startsWith(AppRoutes.plans)) return 2;
    if (location.startsWith(AppRoutes.tenants)) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final selectedIndex = _selectedIndex(location);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Madaris Platform'),
        actions: [
          TextButton(
            onPressed: () async {
              await context.read<SaasAuthCubit>().logout();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              switch (index) {
                case 0:
                  context.go(AppRoutes.dashboard);
                case 1:
                  context.go(AppRoutes.tenants);
                case 2:
                  context.go(AppRoutes.plans);
                case 3:
                  context.go(AppRoutes.invoices);
              }
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.business_outlined),
                selectedIcon: Icon(Icons.business),
                label: Text('Tenants'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.card_membership_outlined),
                selectedIcon: Icon(Icons.card_membership),
                label: Text('Plans'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: Text('Invoices'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
