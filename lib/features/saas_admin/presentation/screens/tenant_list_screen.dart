import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../domain/entities/platform_tenant.dart';
import 'package:madaris_core/widgets/app_loading_indicator.dart';
import '../cubit/saas_auth_cubit.dart';
import '../cubit/saas_auth_state.dart';
import '../cubit/tenant_list_cubit.dart';
import '../cubit/tenant_list_state.dart';
import '../widgets/platform_status_chip.dart';
import '../widgets/tenant_type_badge.dart';

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
    return BlocConsumer<TenantListCubit, TenantListState>(
      listenWhen: (previous, current) =>
          current is TenantListLoaded && current.actionError != null,
      listener: (context, state) {
        final error = (state as TenantListLoaded).actionError;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error!)),
        );
      },
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

  Future<void> _confirmStatusChange(
    BuildContext context,
    PlatformTenant tenant,
  ) async {
    final suspend = tenant.status != 'suspended';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(suspend ? 'Suspend tenant?' : 'Activate tenant?'),
        content: Text(
          suspend
              ? 'Suspending ${tenant.name} blocks its users from signing in '
                  'until it is activated again.'
              : 'Activating ${tenant.name} restores access for its users.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(suspend ? 'Suspend' : 'Activate'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await context
        .read<TenantListCubit>()
        .setTenantStatus(tenant.id, suspend ? 'suspended' : 'active');
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
          columnSpacing: 24,
          horizontalMargin: 16,
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Slug')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Subscription')),
            DataColumn(label: Text('Plan')),
            DataColumn(label: Text('Actions')),
          ],
          rows: state.tenants.map((tenant) {
            return DataRow(
              cells: [
                DataCell(Text(tenant.name)),
                DataCell(Text(tenant.slug)),
                DataCell(TenantTypeBadge(type: tenant.tenantType)),
                DataCell(PlatformStatusChip(status: tenant.status)),
                DataCell(PlatformStatusChip(status: tenant.subscriptionStatus)),
                DataCell(Text(tenant.planName ?? '—')),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () => context.push(
                          AppRoutes.tenantSubscriptionPath(tenant.id),
                          extra: tenant,
                        ),
                        child: const Text('Subscription'),
                      ),
                      if (state.canEdit)
                        TextButton(
                          onPressed: state.updatingTenantId != null
                              ? null
                              : () => _confirmStatusChange(context, tenant),
                          child: Text(
                            tenant.status == 'suspended'
                                ? 'Activate'
                                : 'Suspend',
                          ),
                        ),
                    ],
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
