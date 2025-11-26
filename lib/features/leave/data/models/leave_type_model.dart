import '../../domain/entities/leave_type_entity.dart';

class LeaveTypeModel extends LeaveTypeEntity {
  LeaveTypeModel({
    required super.id,
    required super.leaveTypeCode,
    required super.leaveTypeName,
    super.description,
    required super.isPaid,
    required super.requiresApproval,
    required super.requiresDocument,
    required super.deductsFromBalance,
    super.maxDaysPerYear,
    super.maxConsecutiveDays,
    required super.minNoticeDays,
    required super.excludeHolidays,
    required super.excludeWeekends,
    required super.allowCarryOver,
    super.maxCarryOverDays,
    required super.carryOverExpiryMonths,
    required super.isProrated,
    required super.prorationBasis,
    required super.isAccrued,
    super.accrualRate,
    required super.accrualStartMonth,
    required super.colorHex,
    super.icon,
    required super.sortOrder,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory LeaveTypeModel.fromJson(Map<String, dynamic> json) {
    return LeaveTypeModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      leaveTypeCode: json['leave_type_code'] as String,
      leaveTypeName: json['leave_type_name'] as String,
      description: json['description'] as String?,
      isPaid: json['is_paid'] as bool,
      requiresApproval: json['requires_approval'] as bool,
      requiresDocument: json['requires_document'] as bool,
      deductsFromBalance: json['deducts_from_balance'] as bool,
      maxDaysPerYear: json['max_days_per_year'] != null
          ? (json['max_days_per_year'] is int
              ? json['max_days_per_year']
              : int.parse(json['max_days_per_year'].toString()))
          : null,
      maxConsecutiveDays: json['max_consecutive_days'] != null
          ? (json['max_consecutive_days'] is int
              ? json['max_consecutive_days']
              : int.parse(json['max_consecutive_days'].toString()))
          : null,
      minNoticeDays: json['min_notice_days'] is int
          ? json['min_notice_days']
          : int.parse(json['min_notice_days'].toString()),
      excludeHolidays: json['exclude_holidays'] as bool,
      excludeWeekends: json['exclude_weekends'] as bool,
      allowCarryOver: json['allow_carry_over'] as bool,
      maxCarryOverDays: json['max_carry_over_days'] != null
          ? (json['max_carry_over_days'] is int
              ? json['max_carry_over_days']
              : int.parse(
                  double.parse(json['max_carry_over_days'].toString())
                      .toInt()
                      .toString()))
          : null,
      carryOverExpiryMonths: json['carry_over_expiry_months'] is int
          ? json['carry_over_expiry_months']
          : int.parse(json['carry_over_expiry_months'].toString()),
      isProrated: json['is_prorated'] as bool,
      prorationBasis: json['proration_basis'] as String,
      isAccrued: json['is_accrued'] as bool,
      accrualRate: json['accrual_rate'] != null
          ? (json['accrual_rate'] is int
              ? json['accrual_rate']
              : int.parse(
                  double.parse(json['accrual_rate'].toString()).toInt().toString()))
          : null,
      accrualStartMonth: json['accrual_start_month'] is int
          ? json['accrual_start_month']
          : int.parse(json['accrual_start_month'].toString()),
      colorHex: json['color_hex'] as String,
      icon: json['icon'] as String?,
      sortOrder: json['sort_order'] is int
          ? json['sort_order']
          : int.parse(json['sort_order'].toString()),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'leave_type_code': leaveTypeCode,
      'leave_type_name': leaveTypeName,
      'description': description,
      'is_paid': isPaid,
      'requires_approval': requiresApproval,
      'requires_document': requiresDocument,
      'deducts_from_balance': deductsFromBalance,
      'max_days_per_year': maxDaysPerYear,
      'max_consecutive_days': maxConsecutiveDays,
      'min_notice_days': minNoticeDays,
      'exclude_holidays': excludeHolidays,
      'exclude_weekends': excludeWeekends,
      'allow_carry_over': allowCarryOver,
      'max_carry_over_days': maxCarryOverDays,
      'carry_over_expiry_months': carryOverExpiryMonths,
      'is_prorated': isProrated,
      'proration_basis': prorationBasis,
      'is_accrued': isAccrued,
      'accrual_rate': accrualRate,
      'accrual_start_month': accrualStartMonth,
      'color_hex': colorHex,
      'icon': icon,
      'sort_order': sortOrder,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
