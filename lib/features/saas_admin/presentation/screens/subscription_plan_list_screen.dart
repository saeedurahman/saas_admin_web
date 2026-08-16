import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import 'package:madaris_core/widgets/app_loading_indicator.dart';
import '../cubit/saas_auth_cubit.dart';
import '../cubit/saas_auth_state.dart';
import '../cubit/subscription_plan_list_cubit.dart';
import '../cubit/subscription_plan_list_state.dart';

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
    final nameController = TextEditingController();
    final monthlyController = TextEditingController();
    final annualController = TextEditingController();
    var hostel = false;
    var payroll = false;

    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create plan'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: monthlyController,
                      decoration: const InputDecoration(
                        labelText: 'Monthly price',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: annualController,
                      decoration: const InputDecoration(
                        labelText: 'Annual price (optional)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Hostel module'),
                      value: hostel,
                      onChanged: (value) =>
                          setState(() => hostel = value ?? false),
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Payroll module'),
                      value: payroll,
                      onChanged: (value) =>
                          setState(() => payroll = value ?? false),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );

    if (created != true || !context.mounted) return;

    final flags = <String, bool>{
      if (hostel) 'hostel': true,
      if (payroll) 'payroll': true,
    };

    await context.read<SubscriptionPlanListCubit>().createPlan(
          name: nameController.text.trim(),
          priceMonthly: monthlyController.text.trim(),
          priceAnnual: annualController.text.trim().isEmpty
              ? null
              : annualController.text.trim(),
          featureFlags: flags.isEmpty ? null : flags,
        );

    nameController.dispose();
    monthlyController.dispose();
    annualController.dispose();
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
        state is SubscriptionPlanListCreating) {
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
              'Monthly: ${plan.priceMonthly} · Annual: ${plan.priceAnnual ?? '—'}',
            ),
            trailing: Chip(
              label: Text(plan.isActive ? 'Active' : 'Inactive'),
            ),
          );
        },
      );
    }
    return const SizedBox.shrink();
  }
}
