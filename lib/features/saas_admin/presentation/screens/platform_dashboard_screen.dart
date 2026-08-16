import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import 'package:madaris_core/widgets/app_loading_indicator.dart';
import '../cubit/platform_dashboard_cubit.dart';
import '../cubit/platform_dashboard_state.dart';

class PlatformDashboardScreen extends StatelessWidget {
  const PlatformDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PlatformDashboardCubit(sl())..load(),
      child: const _PlatformDashboardBody(),
    );
  }
}

class _PlatformDashboardBody extends StatelessWidget {
  const _PlatformDashboardBody();

  String _formatStatusLabel(String key) {
    return key
        .split('_')
        .map(
          (part) => part.isEmpty
              ? part
              : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.all(16),
      child: BlocBuilder<PlatformDashboardCubit, PlatformDashboardState>(
        builder: (context, state) {
          if (state is PlatformDashboardInitial ||
              state is PlatformDashboardLoading) {
            return const Center(child: AppLoadingIndicator());
          }
          if (state is PlatformDashboardError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () =>
                        context.read<PlatformDashboardCubit>().load(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is! PlatformDashboardLoaded) {
            return const SizedBox.shrink();
          }

          final dashboard = state.dashboard;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Dashboard',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _StatCard(
                      title: 'Total tenants',
                      value: dashboard.totalTenants.toString(),
                    ),
                    _StatCard(
                      title: 'MRR estimate',
                      value: dashboard.mrrEstimate.toStringAsFixed(2),
                    ),
                    _BreakdownCard(
                      title: 'Tenant status',
                      counts: dashboard.tenantStatusCounts,
                      labelBuilder: _formatStatusLabel,
                    ),
                    _BreakdownCard(
                      title: 'Subscription status',
                      counts: dashboard.subscriptionStatusCounts,
                      labelBuilder: _formatStatusLabel,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({
    required this.title,
    required this.counts,
    required this.labelBuilder,
  });

  final String title;
  final Map<String, int> counts;
  final String Function(String key) labelBuilder;

  @override
  Widget build(BuildContext context) {
    final entries = counts.entries.where((entry) => entry.value > 0).toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return SizedBox(
      width: 320,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              if (entries.isEmpty)
                const Text('No data')
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final entry in entries)
                      Chip(
                        label: Text(
                          '${labelBuilder(entry.key)}: ${entry.value}',
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
