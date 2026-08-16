import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import 'package:madaris_core/widgets/app_button.dart';
import 'package:madaris_core/widgets/app_loading_indicator.dart';
import 'package:madaris_core/widgets/form/app_form_card.dart';
import '../../domain/entities/platform_tenant.dart';
import '../../domain/entities/tenant_subscription.dart';
import '../cubit/saas_auth_cubit.dart';
import '../cubit/saas_auth_state.dart';
import '../cubit/tenant_subscription_cubit.dart';
import '../cubit/tenant_subscription_state.dart';

class TenantSubscriptionScreen extends StatelessWidget {
  const TenantSubscriptionScreen({
    super.key,
    required this.tenant,
  });

  final PlatformTenant tenant;

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
      create: (_) => TenantSubscriptionCubit(
        sl(),
        permissions: _permissions(context),
      )..load(tenant),
      child: _TenantSubscriptionBody(tenant: tenant),
    );
  }
}

class _TenantSubscriptionBody extends StatelessWidget {
  const _TenantSubscriptionBody({required this.tenant});

  final PlatformTenant tenant;

  Future<void> _pickDate(
    BuildContext context,
    TenantSubscriptionEditing state, {
    required bool trialEnd,
  }) async {
    final initial = trialEnd
        ? state.formData.trialEndsAt ?? DateTime.now()
        : state.formData.currentPeriodStart ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null || !context.mounted) return;

    final cubit = context.read<TenantSubscriptionCubit>();
    cubit.updateForm(
      TenantSubscriptionAssignData(
        planId: state.formData.planId,
        billingCycle: state.formData.billingCycle,
        status: state.formData.status,
        trialEndsAt: trialEnd ? picked : state.formData.trialEndsAt,
        currentPeriodStart:
            trialEnd ? state.formData.currentPeriodStart : picked,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TenantSubscriptionCubit, TenantSubscriptionState>(
      listener: (context, state) {
        if (state is TenantSubscriptionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Subscription saved')),
          );
        } else if (state is TenantSubscriptionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text('${tenant.name} — Subscription'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          body: switch (state) {
            TenantSubscriptionLoading() =>
              const Center(child: AppLoadingIndicator()),
            TenantSubscriptionError(:final message) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(message),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => context
                          .read<TenantSubscriptionCubit>()
                          .load(tenant),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            TenantSubscriptionEditing() => _buildForm(context, state),
            TenantSubscriptionSuccess() => const SizedBox.shrink(),
          },
        );
      },
    );
  }

  Widget _buildForm(BuildContext context, TenantSubscriptionEditing state) {
    if (state.plans.isEmpty) {
      return const Center(
        child: Text('No active subscription plans. Create a plan first.'),
      );
    }

    return AppFormCard(
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.existingSubscription == null)
            const Text('No subscription assigned yet.')
          else
            Text(
              'Current plan: ${state.existingSubscription!.plan?.name ?? state.existingSubscription!.planId}',
            ),
          const SizedBox(height: AppFormCard.fieldGap),
          DropdownButtonFormField<String>(
              initialValue: state.formData.planId.isEmpty
                  ? null
                  : state.formData.planId,
              decoration: const InputDecoration(
                labelText: 'Plan',
                border: OutlineInputBorder(),
              ),
              items: state.plans
                  .map(
                    (plan) => DropdownMenuItem(
                      value: plan.id,
                      child: Text(plan.name),
                    ),
                  )
                  .toList(),
              onChanged: state.canEdit
                  ? (value) {
                      if (value == null) return;
                      context.read<TenantSubscriptionCubit>().updateForm(
                            TenantSubscriptionAssignData(
                              planId: value,
                              billingCycle: state.formData.billingCycle,
                              status: state.formData.status,
                              trialEndsAt: state.formData.trialEndsAt,
                              currentPeriodStart:
                                  state.formData.currentPeriodStart,
                            ),
                          );
                    }
                  : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: state.formData.billingCycle,
              decoration: const InputDecoration(
                labelText: 'Billing cycle',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                DropdownMenuItem(value: 'annual', child: Text('Annual')),
              ],
              onChanged: state.canEdit
                  ? (value) {
                      if (value == null) return;
                      context.read<TenantSubscriptionCubit>().updateForm(
                            TenantSubscriptionAssignData(
                              planId: state.formData.planId,
                              billingCycle: value,
                              status: state.formData.status,
                              trialEndsAt: state.formData.trialEndsAt,
                              currentPeriodStart:
                                  state.formData.currentPeriodStart,
                            ),
                          );
                    }
                  : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: state.formData.status,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'trial', child: Text('Trial')),
                DropdownMenuItem(value: 'active', child: Text('Active')),
                DropdownMenuItem(value: 'past_due', child: Text('Past due')),
                DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
                DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
              ],
              onChanged: state.canEdit
                  ? (value) {
                      if (value == null) return;
                      context.read<TenantSubscriptionCubit>().updateForm(
                            TenantSubscriptionAssignData(
                              planId: state.formData.planId,
                              billingCycle: state.formData.billingCycle,
                              status: value,
                              trialEndsAt: state.formData.trialEndsAt,
                              currentPeriodStart:
                                  state.formData.currentPeriodStart,
                            ),
                          );
                    }
                  : null,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Trial ends at'),
              subtitle: Text(
                state.formData.trialEndsAt?.toIso8601String().split('T').first ??
                    'Not set',
              ),
              trailing: state.canEdit
                  ? IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () =>
                          _pickDate(context, state, trialEnd: true),
                    )
                  : null,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Period start'),
              subtitle: Text(
                state.formData.currentPeriodStart
                        ?.toIso8601String()
                        .split('T')
                        .first ??
                    'Today (default)',
              ),
              trailing: state.canEdit
                  ? IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () =>
                          _pickDate(context, state, trialEnd: false),
                    )
                  : null,
            ),
            const SizedBox(height: AppFormCard.sectionGap),
            if (state.canEdit)
              AppButton(
                label: 'Save subscription',
                isLoading: state.isSubmitting,
                onPressed: () =>
                    context.read<TenantSubscriptionCubit>().submit(),
              ),
        ],
      ),
    );
  }
}
