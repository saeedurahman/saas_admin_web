import 'package:equatable/equatable.dart';

class PlatformDashboard extends Equatable {
  const PlatformDashboard({
    required this.totalTenants,
    required this.tenantStatusCounts,
    required this.subscriptionStatusCounts,
    required this.mrrEstimate,
  });

  final int totalTenants;
  final Map<String, int> tenantStatusCounts;
  final Map<String, int> subscriptionStatusCounts;
  final double mrrEstimate;

  @override
  List<Object?> get props => [
        totalTenants,
        tenantStatusCounts,
        subscriptionStatusCounts,
        mrrEstimate,
      ];
}
