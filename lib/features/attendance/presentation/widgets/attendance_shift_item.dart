import 'package:flutter/material.dart';
import '../../data/models/attendance_model.dart';
import '../../domain/entities/attendance_entity.dart';

class AttendanceShiftItem extends StatelessWidget {
  final AttendanceShift shift;

  const AttendanceShiftItem({Key? key, required this.shift}) : super(key: key);

  Color _getStatusColor(ShiftStatus status) {
    switch (status) {
      case ShiftStatus.SCHEDULED:
        return Colors.blue;
      case ShiftStatus.IN_PROGRESS:
        return Colors.orange;
      case ShiftStatus.COMPLETED:
        return Colors.green;
      case ShiftStatus.ABSENT:
        return Colors.red;
      case ShiftStatus.ON_LEAVE:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(ShiftStatus status) {
    switch (status) {
      case ShiftStatus.COMPLETED:
        return 'Completed';
      case ShiftStatus.IN_PROGRESS:
        return 'In Progress';
      case ShiftStatus.ABSENT:
        return 'Absent';
      case ShiftStatus.ON_LEAVE:
        return 'On Leave';
      default:
        return 'Scheduled';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(shift.status);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shift.shiftDate,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    shift.dayOfWeek,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusText(shift.status),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeInfo('Check In', shift.checkInTime),
              _buildTimeInfo('Check Out', shift.checkOutTime),
              _buildTimeInfo('Work Hours', '${shift.workHours}h'),
            ],
          ),
          if (shift.lateMinutes > 0 || shift.earlyLeaveMinutes > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (shift.lateMinutes > 0)
                  _buildWarningTag('Late: ${shift.lateMinutes}m'),
                if (shift.lateMinutes > 0 && shift.earlyLeaveMinutes > 0)
                  const SizedBox(width: 8),
                if (shift.earlyLeaveMinutes > 0)
                  _buildWarningTag('Early: ${shift.earlyLeaveMinutes}m'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeInfo(String label, String? time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time != null ? _formatTime(time) : '--:--',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildWarningTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatTime(String isoString) {
    try {
      // Assuming isoString is full ISO date, we just want HH:mm
      // Or if it's just HH:mm:ss, we take HH:mm
      if (isoString.contains('T')) {
        final date = DateTime.parse(isoString);
        return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      }
      return isoString.substring(0, 5);
    } catch (e) {
      return isoString;
    }
  }
}
