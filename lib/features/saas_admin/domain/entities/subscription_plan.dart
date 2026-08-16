import 'package:equatable/equatable.dart';

class SubscriptionPlan extends Equatable {
  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.priceMonthly,
    this.priceAnnual,
    this.maxUsers,
    this.maxStudents,
    required this.featureFlags,
    required this.isActive,
  });

  final String id;
  final String name;
  final String priceMonthly;
  final String? priceAnnual;
  final int? maxUsers;
  final int? maxStudents;
  final Map<String, bool> featureFlags;
  final bool isActive;

  @override
  List<Object?> get props => [
        id,
        name,
        priceMonthly,
        priceAnnual,
        maxUsers,
        maxStudents,
        featureFlags,
        isActive,
      ];
}
