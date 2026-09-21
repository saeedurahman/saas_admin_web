import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import 'package:madaris_core/widgets/app_loading_indicator.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/entities/subscription_plan_update_data.dart';
import '../cubit/saas_auth_cubit.dart';
import '../cubit/saas_auth_state.dart';
import '../cubit/subscription_plan_list_cubit.dart';
import '../cubit/subscription_plan_list_state.dart';
import '../widgets/subscription_plan_form_dialog.dart';

class SubscriptionPlanListScreen extends StatelessWidget {
  const SubscriptionPlanListScreen({super.key});

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
      create: (_) => SubscriptionPlanListCubit(
        sl(),
        permissions: _permissions(context),
      )..load(),
      child: const _SubscriptionPlanListBody(),
    );
  }
}

class _SubscriptionPlanListBody extends StatelessWidget {
  const _SubscriptionPlanListBody();

  Future<void> _showCreateDialog(BuildContext context) async {
    final data = await showDialog<SubscriptionPlanUpdateData>(
      context: context,
      builder: (_) => const SubscriptionPlanFormDialog(),
    );
    if (data == null || !context.mounted) return;

    await context.read<SubscriptionPlanListCubit>().createPlan(
          name: data.name,
          priceMonthly: data.priceMonthly,
          priceAnnual: data.priceAnnual,
          maxUsers: data.maxUsers,
          maxStudents: data.maxStudents,
          featureFlags: data.featureFlags.isEmpty ? null : data.featureFlags,
        );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    SubscriptionPlan plan,
  ) async {
    final data = await showDialog<SubscriptionPlanUpdateData>(
      context: context,
      builder: (_) => SubscriptionPlanFormDialog(plan: plan),
    );
    if (data == null || !context.mounted) return;
    await context.read<SubscriptionPlanListCubit>().updatePlan(plan.id, data);
  }

  Future<void> _confirmRetire(
    BuildContext context,
    SubscriptionPlan plan,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Retire plan?'),
        content: Text(
          '${plan.name} will no longer be offered when assigning '
          'subscriptions. Tenants already on it are not changed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Retire'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<SubscriptionPlanListCubit>().retirePlan(plan.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionPlanListCubit, SubscriptionPlanListState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsetsDirectional.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    'Subscription plans',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  if (state is SubscriptionPlanListLoaded && state.canCreate)
                    FilledButton.icon(
                      onPressed: () => _showCreateDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Create plan'),
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

  Widget _buildContent(
    BuildContext context,
    SubscriptionPlanListState state,
  ) {
    if (state is SubscriptionPlanListLoading ||
        state is SubscriptionPlanListSaving) {
      return const Center(child: AppLoadingIndicator());
    }
    if (state is SubscriptionPlanListError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.message),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () =>
                  context.read<SubscriptionPlanListCubit>().load(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (state is SubscriptionPlanListLoaded) {
      if (state.plans.isEmpty) {
        return const Center(child: Text('No plans yet.'));
      }
      return ListView.separated(
        itemCount: state.plans.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final plan = state.plans[index];
          return ListTile(
            title: Text(plan.name),
            subtitle: Text(
              'Monthly: ${plan.priceMonthly} · Annual: ${plan.priceAnnual ?? '—'}'
              ' · Users: ${plan.maxUsers ?? '∞'} · Students: ${plan.maxStudents ?? '∞'}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Chip(label: Text(plan.isActive ? 'Active' : 'Inactive')),
                if (state.canEdit)
                  IconButton(
                    tooltip: 'Edit plan',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _showEditDialog(context, plan),
                  ),
                if (state.canRetire && plan.isActive)
                  IconButton(
                    tooltip: 'Retire plan',
                    icon: const Icon(Icons.archive_outlined),
                    onPressed: () => _confirmRetire(context, plan),
                  ),
              ],
            ),
          );
        },
      );
    }
    return const SizedBox.shrink();
  }
}
