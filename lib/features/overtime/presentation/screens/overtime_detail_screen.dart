import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../flutter_flow/flutter_flow.dart';
import '../../providers/overtime_providers.dart';
import 'update_overtime_screen.dart';

class OvertimeDetailScreen extends ConsumerStatefulWidget {
  final int overtimeId;

  const OvertimeDetailScreen({
    super.key,
    required this.overtimeId,
  });

  @override
  ConsumerState<OvertimeDetailScreen> createState() =>
      _OvertimeDetailScreenState();
}

class _OvertimeDetailScreenState extends ConsumerState<OvertimeDetailScreen>
    with TickerProviderStateMixin, AnimationControllerMixin {
  @override
  void initState() {
    super.initState();

    // Setup animations
    setupAnimations({
      'containerAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effects: FFAnimations.fadeInSlideUp(
          delay: const Duration(milliseconds: 0),
          duration: const Duration(milliseconds: 600),
        ),
      ),
    });

    // Load overtime request details
    Future.microtask(() {
      ref
          .read(overtimeControllerProvider.notifier)
          .getOvertimeRequestById(widget.overtimeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final overtimeState = ref.watch(overtimeControllerProvider);
    final overtime = overtimeState.selectedOvertime;
    final canUpdate = overtime?.status?.toUpperCase() == 'PENDING';

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        title: Text(
          'Chi tiết đơn làm thêm',
          style: theme.title2.override(color: Colors.white),
        ),
        backgroundColor: theme.primaryColor,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (canUpdate && overtime != null)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              tooltip: 'Chỉnh sửa',
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => UpdateOvertimeScreen(
                      overtime: overtime,
                    ),
                  ),
                );
                // Reload data if update was successful
                if (result == true && mounted) {
                  ref
                      .read(overtimeControllerProvider.notifier)
                      .getOvertimeRequestById(widget.overtimeId);
                }
              },
            ),
        ],
      ),
      body: overtimeState.isLoading
          ? Center(child: FFLoadingIndicator(color: theme.primaryColor))
          : overtime == null
              ? Center(
                  child: Text(
                    'Không tìm thấy thông tin đơn làm thêm',
                    style: theme.bodyText1,
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusCard(theme, overtime),
                      const SizedBox(height: 16),
                      _buildInfoCard(theme, overtime),
                      const SizedBox(height: 16),
                      _buildTimeCard(theme, overtime),
                      const SizedBox(height: 16),
                      _buildReasonCard(theme, overtime),
                      if (overtime.rejectionReason != null) ...[
                        const SizedBox(height: 16),
                        _buildRejectionReasonCard(theme, overtime),
                      ],
                      // Add spacing for FAB
                      if (canUpdate) const SizedBox(height: 80),
                    ],
                  ),
                ),
      floatingActionButton: canUpdate && overtime != null
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => UpdateOvertimeScreen(
                      overtime: overtime,
                    ),
                  ),
                );
                // Reload data if update was successful
                if (result == true && mounted) {
                  ref
                      .read(overtimeControllerProvider.notifier)
                      .getOvertimeRequestById(widget.overtimeId);
                }
              },
              icon: const Icon(Icons.edit),
              label: Text(
                'Chỉnh sửa',
                style: theme.subtitle1.override(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: theme.primaryColor,
            )
          : null,
    );
  }

  Widget _buildStatusCard(FlutterFlowTheme theme, dynamic overtime) {
    final statusColor = _getStatusColor(overtime.status, theme);
    final statusText = _getStatusText(overtime.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor,
            statusColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trạng thái',
                style: theme.bodyText2.override(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                statusText,
                style: theme.title2.override(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getStatusIcon(overtime.status),
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    ).animateOnPageLoad(animationsMap['containerAnimation']!);
  }

  Widget _buildInfoCard(FlutterFlowTheme theme, dynamic overtime) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.primaryText.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin chung',
            style: theme.subtitle1.override(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            theme,
            Icons.tag,
            'Mã đơn',
            '#${overtime.id}',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            theme,
            Icons.calendar_today,
            'Ngày làm thêm',
            DateFormat('dd/MM/yyyy').format(overtime.overtimeDate),
          ),
          if (overtime.shiftId != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              theme,
              Icons.schedule,
              'Ca làm việc',
              'Ca #${overtime.shiftId}',
            ),
          ],
        ],
      ),
    ).animateOnPageLoad(animationsMap['containerAnimation']!);
  }

  Widget _buildTimeCard(FlutterFlowTheme theme, dynamic overtime) {
    final timeFormat = DateFormat('HH:mm');
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.primaryText.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thời gian làm thêm',
            style: theme.subtitle1.override(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTimeBox(
                  theme,
                  'Bắt đầu',
                  timeFormat.format(overtime.startTime),
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeBox(
                  theme,
                  'Kết thúc',
                  timeFormat.format(overtime.endTime),
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color: theme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Số giờ dự kiến',
                      style: theme.bodyText1.override(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${overtime.estimatedHours} giờ',
                  style: theme.subtitle1.override(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (overtime.actualHours != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Số giờ thực tế',
                        style: theme.bodyText1.override(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${overtime.actualHours} giờ',
                    style: theme.subtitle1.override(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animateOnPageLoad(animationsMap['containerAnimation']!);
  }

  Widget _buildTimeBox(
    FlutterFlowTheme theme,
    String label,
    String time,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.bodyText2.override(
              color: theme.secondaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: theme.subtitle1.override(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonCard(FlutterFlowTheme theme, dynamic overtime) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.primaryText.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: theme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Lý do',
                style: theme.subtitle1.override(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            overtime.reason,
            style: theme.bodyText1.override(
              color: theme.primaryText,
            ),
          ),
        ],
      ),
    ).animateOnPageLoad(animationsMap['containerAnimation']!);
  }

  Widget _buildRejectionReasonCard(FlutterFlowTheme theme, dynamic overtime) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.cancel_outlined,
                color: Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Lý do từ chối',
                style: theme.subtitle1.override(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            overtime.rejectionReason ?? '',
            style: theme.bodyText1.override(
              color: Colors.red.shade700,
            ),
          ),
        ],
      ),
    ).animateOnPageLoad(animationsMap['containerAnimation']!);
  }

  Widget _buildInfoRow(
    FlutterFlowTheme theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.primaryColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.bodyText2.override(
                  color: theme.secondaryText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.bodyText1.override(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String? status, FlutterFlowTheme theme) {
    switch (status?.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return theme.secondaryText;
    }
  }

  String _getStatusText(String? status) {
    switch (status?.toUpperCase()) {
      case 'PENDING':
        return 'Chờ duyệt';
      case 'APPROVED':
        return 'Đã duyệt';
      case 'REJECTED':
        return 'Từ chối';
      default:
        return 'Không xác định';
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toUpperCase()) {
      case 'PENDING':
        return Icons.pending_actions;
      case 'APPROVED':
        return Icons.check_circle;
      case 'REJECTED':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }
}
