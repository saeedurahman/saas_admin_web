import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import 'package:madaris_core/widgets/app_loading_indicator.dart';
import '../cubit/saas_auth_cubit.dart';
import '../cubit/saas_auth_state.dart';
import '../cubit/tenant_list_cubit.dart';
import '../cubit/tenant_list_state.dart';

class TenantListScreen extends StatelessWidget {
  const TenantListScreen({super.key});

  List<String> _permissions(BuildContext context) {
    final state = context.read<SaasAuthCubit>().state;
    if (state is SaasAuthAuthenticated) {
      return state.session.permissions;
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TenantListCubit(
        sl(),
        permissions: _permissions(context),
      )..load(),
      child: const _TenantListBody(),
    );
  }
}

class _TenantListBody extends StatelessWidget {
  const _TenantListBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TenantListCubit, TenantListState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsetsDirectional.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    'Tenants',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  if (state is TenantListLoaded && state.canCreate)
                    FilledButton.icon(
                      onPressed: () async {
                        final created = await context.push<bool>(
                          AppRoutes.tenantsNew,
                        );
                        if (created == true && context.mounted) {
                          await context.read<TenantListCubit>().load();
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Create tenant'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildContent(context, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, TenantListState state) {
    if (state is TenantListLoading) {
      return const Center(child: AppLoadingIndicator());
    }
    if (state is TenantListError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.message),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => context.read<TenantListCubit>().load(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (state is TenantListLoaded) {
      if (state.tenants.isEmpty) {
        return const Center(child: Text('No tenants yet.'));
      }
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Slug')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Plan')),
            DataColumn(label: Text('Actions')),
          ],
          rows: state.tenants.map((tenant) {
            return DataRow(
              cells: [
                DataCell(Text(tenant.name)),
                DataCell(Text(tenant.slug)),
                DataCell(Text(tenant.status)),
                DataCell(Text(tenant.planName ?? '—')),
                DataCell(
                  TextButton(
                    onPressed: () => context.push(
                      AppRoutes.tenantSubscriptionPath(tenant.id),
                      extra: tenant,
                    ),
                    child: const Text('Subscription'),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
