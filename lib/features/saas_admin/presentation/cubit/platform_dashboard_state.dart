import 'package:equatable/equatable.dart';

import '../../domain/entities/platform_dashboard.dart';

sealed class PlatformDashboardState extends Equatable {
  const PlatformDashboardState();

  @override
  List<Object?> get props => [];
}

class PlatformDashboardInitial extends PlatformDashboardState {
  const PlatformDashboardInitial();
}

class PlatformDashboardLoading extends PlatformDashboardState {
  const PlatformDashboardLoading();
}

class PlatformDashboardLoaded extends PlatformDashboardState {
  const PlatformDashboardLoaded({required this.dashboard});

  final PlatformDashboard dashboard;

  @override
  List<Object?> get props => [dashboard];
}

class PlatformDashboardError extends PlatformDashboardState {
  const PlatformDashboardError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
