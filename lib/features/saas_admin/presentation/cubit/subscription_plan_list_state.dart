import 'package:equatable/equatable.dart';

import '../../domain/entities/subscription_plan.dart';

sealed class SubscriptionPlanListState extends Equatable {
  const SubscriptionPlanListState();

  @override
  List<Object?> get props => [];
}

class SubscriptionPlanListLoading extends SubscriptionPlanListState {
  const SubscriptionPlanListLoading();
}

class SubscriptionPlanListLoaded extends SubscriptionPlanListState {
  const SubscriptionPlanListLoaded({
    required this.plans,
    required this.canCreate,
  });

  final List<SubscriptionPlan> plans;
  final bool canCreate;

  @override
  List<Object?> get props => [plans, canCreate];
}

class SubscriptionPlanListError extends SubscriptionPlanListState {
  const SubscriptionPlanListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class SubscriptionPlanListCreating extends SubscriptionPlanListState {
  const SubscriptionPlanListCreating({
    required this.plans,
    required this.canCreate,
  });

  final List<SubscriptionPlan> plans;
  final bool canCreate;

  @override
  List<Object?> get props => [plans, canCreate];
}
