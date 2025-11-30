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
      id: num.parse(json['id'].toString()).toInt(),
      leaveTypeCode: json['leave_type_code'] as String,
      leaveTypeName: json['leave_type_name'] as String,
      description: json['description'] as String?,
      isPaid: json['is_paid'] is bool
          ? json['is_paid']
          : (json['is_paid'] == 1 || json['is_paid'] == '1' || json['is_paid'] == 'true'),
      requiresApproval: json['requires_approval'] is bool
          ? json['requires_approval']
          : (json['requires_approval'] == 1 || json['requires_approval'] == '1' || json['requires_approval'] == 'true'),
      requiresDocument: json['requires_document'] is bool
          ? json['requires_document']
          : (json['requires_document'] == 1 || json['requires_document'] == '1' || json['requires_document'] == 'true'),
      deductsFromBalance: json['deducts_from_balance'] is bool
          ? json['deducts_from_balance']
          : (json['deducts_from_balance'] == 1 || json['deducts_from_balance'] == '1' || json['deducts_from_balance'] == 'true'),
      maxDaysPerYear: json['max_days_per_year'] == null
          ? null
          : num.tryParse(json['max_days_per_year'].toString())?.toInt(),
      maxConsecutiveDays: json['max_consecutive_days'] == null
          ? null
          : num.tryParse(json['max_consecutive_days'].toString())?.toInt(),
      minNoticeDays: num.parse(json['min_notice_days'].toString()).toInt(),
      excludeHolidays: json['exclude_holidays'] is bool
          ? json['exclude_holidays']
          : (json['exclude_holidays'] == 1 || json['exclude_holidays'] == '1' || json['exclude_holidays'] == 'true'),
      excludeWeekends: json['exclude_weekends'] is bool
          ? json['exclude_weekends']
          : (json['exclude_weekends'] == 1 || json['exclude_weekends'] == '1' || json['exclude_weekends'] == 'true'),
      allowCarryOver: json['allow_carry_over'] is bool
          ? json['allow_carry_over']
          : (json['allow_carry_over'] == 1 || json['allow_carry_over'] == '1' || json['allow_carry_over'] == 'true'),
      maxCarryOverDays: json['max_carry_over_days'] == null
          ? null
          : num.tryParse(json['max_carry_over_days'].toString())?.toInt(),
      carryOverExpiryMonths: num.parse(json['carry_over_expiry_months'].toString()).toInt(),
      isProrated: json['is_prorated'] is bool
          ? json['is_prorated']
          : (json['is_prorated'] == 1 || json['is_prorated'] == '1' || json['is_prorated'] == 'true'),
      prorationBasis: json['proration_basis'] as String,
      isAccrued: json['is_accrued'] is bool
          ? json['is_accrued']
          : (json['is_accrued'] == 1 || json['is_accrued'] == '1' || json['is_accrued'] == 'true'),
      accrualRate: json['accrual_rate'] == null
          ? null
          : num.tryParse(json['accrual_rate'].toString())?.toInt(),
      accrualStartMonth: num.parse(json['accrual_start_month'].toString()).toInt(),
      colorHex: json['color_hex'] as String,
      icon: json['icon'] as String?,
      sortOrder: num.parse(json['sort_order'].toString()).toInt(),
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
