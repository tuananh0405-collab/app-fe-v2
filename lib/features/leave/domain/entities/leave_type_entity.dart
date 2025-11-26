class LeaveTypeEntity {
  final int id;
  final String leaveTypeCode;
  final String leaveTypeName;
  final String? description;
  final bool isPaid;
  final bool requiresApproval;
  final bool requiresDocument;
  final bool deductsFromBalance;
  final int? maxDaysPerYear;
  final int? maxConsecutiveDays;
  final int minNoticeDays;
  final bool excludeHolidays;
  final bool excludeWeekends;
  final bool allowCarryOver;
  final int? maxCarryOverDays;
  final int carryOverExpiryMonths;
  final bool isProrated;
  final String prorationBasis;
  final bool isAccrued;
  final int? accrualRate;
  final int accrualStartMonth;
  final String colorHex;
  final String? icon;
  final int sortOrder;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  LeaveTypeEntity({
    required this.id,
    required this.leaveTypeCode,
    required this.leaveTypeName,
    this.description,
    required this.isPaid,
    required this.requiresApproval,
    required this.requiresDocument,
    required this.deductsFromBalance,
    this.maxDaysPerYear,
    this.maxConsecutiveDays,
    required this.minNoticeDays,
    required this.excludeHolidays,
    required this.excludeWeekends,
    required this.allowCarryOver,
    this.maxCarryOverDays,
    required this.carryOverExpiryMonths,
    required this.isProrated,
    required this.prorationBasis,
    required this.isAccrued,
    this.accrualRate,
    required this.accrualStartMonth,
    required this.colorHex,
    this.icon,
    required this.sortOrder,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
}
