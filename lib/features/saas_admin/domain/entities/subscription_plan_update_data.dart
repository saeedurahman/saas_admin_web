import 'package:equatable/equatable.dart';

/// Full editable state of a plan, sent as a PATCH. Null [priceAnnual],
/// [maxUsers] and [maxStudents] are sent as explicit nulls so the admin can
/// clear a limit.
class SubscriptionPlanUpdateData extends Equatable {
  const SubscriptionPlanUpdateData({
    required this.name,
    required this.priceMonthly,
    this.priceAnnual,
    this.maxUsers,
    this.maxStudents,
    required this.featureFlags,
  });

  final String name;
  final String priceMonthly;
  final String? priceAnnual;
  final int? maxUsers;
  final int? maxStudents;
  final Map<String, bool> featureFlags;

  @override
  List<Object?> get props => [
        name,
        priceMonthly,
        priceAnnual,
        maxUsers,
        maxStudents,
        featureFlags,
      ];
}
