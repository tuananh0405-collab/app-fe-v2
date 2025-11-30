import 'package:equatable/equatable.dart';
import '../../domain/entities/attendance_entity.dart';

enum AttendanceStatus { initial, loading, success, failure }

class AttendanceState extends Equatable {
  final AttendanceStatus status;
  final AttendanceResponse? data;
  final String? errorMessage;
  final String startDate; // YYYY-MM-DD
  final String endDate; // YYYY-MM-DD
  final String? selectedStatus; // SCHEDULED, IN_PROGRESS, COMPLETED, ON_LEAVE, ABSENT

  const AttendanceState({
    this.status = AttendanceStatus.initial,
    this.data,
    this.errorMessage,
    required this.startDate,
    required this.endDate,
    this.selectedStatus,
  });

  AttendanceState copyWith({
    AttendanceStatus? status,
    AttendanceResponse? data,
    String? errorMessage,
    String? startDate,
    String? endDate,
    String? selectedStatus,
    bool clearSelectedStatus = false,
  }) {
    return AttendanceState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      selectedStatus: clearSelectedStatus ? null : (selectedStatus ?? this.selectedStatus),
    );
  }

  @override
  List<Object?> get props =>
      [status, data, errorMessage, startDate, endDate, selectedStatus];
}
