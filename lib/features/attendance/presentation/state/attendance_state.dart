import 'package:equatable/equatable.dart';
import '../../domain/entities/attendance_entity.dart';

enum AttendanceStatus { initial, loading, success, failure }

class AttendanceState extends Equatable {
  final AttendanceStatus status;
  final AttendanceResponse? data;
  final String? errorMessage;
  final String selectedPeriod; // DAY, WEEK, MONTH, YEAR
  final String referenceDate; // YYYY-MM-DD

  const AttendanceState({
    this.status = AttendanceStatus.initial,
    this.data,
    this.errorMessage,
    this.selectedPeriod = 'MONTH',
    required this.referenceDate,
  });

  AttendanceState copyWith({
    AttendanceStatus? status,
    AttendanceResponse? data,
    String? errorMessage,
    String? selectedPeriod,
    String? referenceDate,
  }) {
    return AttendanceState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      referenceDate: referenceDate ?? this.referenceDate,
    );
  }

  @override
  List<Object?> get props =>
      [status, data, errorMessage, selectedPeriod, referenceDate];
}
