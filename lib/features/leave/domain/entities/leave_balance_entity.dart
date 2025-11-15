class LeaveBalanceEntity {
  final int id;
  final int employeeId;
  final int leaveTypeId;
  final String leaveTypeName;
  final double totalDays;
  final double usedDays;
  final double remainingDays;
  final int year;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LeaveBalanceEntity({
    required this.id,
    required this.employeeId,
    required this.leaveTypeId,
    required this.leaveTypeName,
    required this.totalDays,
    required this.usedDays,
    required this.remainingDays,
    required this.year,
    this.createdAt,
    this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaveBalanceEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          employeeId == other.employeeId;

  @override
  int get hashCode => id.hashCode ^ employeeId.hashCode;
}
