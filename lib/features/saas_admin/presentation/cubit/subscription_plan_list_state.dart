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
    this.canEdit = false,
    this.canRetire = false,
  });

  final List<SubscriptionPlan> plans;
  final bool canCreate;
  final bool canEdit;
  final bool canRetire;

  @override
  List<Object?> get props => [plans, canCreate, canEdit, canRetire];
}

class SubscriptionPlanListError extends SubscriptionPlanListState {
  const SubscriptionPlanListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// A create, edit or retire request is in flight.
class SubscriptionPlanListSaving extends SubscriptionPlanListState {
  const SubscriptionPlanListSaving({
    required this.plans,
    required this.canCreate,
    this.canEdit = false,
    this.canRetire = false,
  });

  final List<SubscriptionPlan> plans;
  final bool canCreate;
  final bool canEdit;
  final bool canRetire;

  @override
  List<Object?> get props => [plans, canCreate, canEdit, canRetire];
}
