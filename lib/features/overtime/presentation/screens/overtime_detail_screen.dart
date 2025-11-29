import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../flutter_flow/flutter_flow.dart';
import '../../../../core/localization/app_localizations.dart';
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
      'actionButtons': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effects: FFAnimations.fadeInSlideUp(
          delay: const Duration(milliseconds: 200),
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
  final l10n = AppLocalizations.of(context).overtime;
  final overtimeState = ref.watch(overtimeControllerProvider);
  final overtime = overtimeState.selectedOvertime;
  final canUpdate = overtime?.status?.toUpperCase() == 'PENDING';

  return Scaffold(
    backgroundColor: theme.primaryBackground,
    appBar: AppBar(
      title: Text(
        l10n.overtimeDetail,
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
            tooltip: l10n.edit,
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
                  l10n.notFound,
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
                    // Add spacing for action buttons
                    if (canUpdate) const SizedBox(height: 16),
                  ],
                ),
              ),
    bottomNavigationBar: canUpdate && overtime != null
        ? SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FFButton(
                onPressed: () {
                  _showCancelDialog(context, ref, l10n);
                },
                text: l10n.cancelRequest,
                icon: Icon(
                  Icons.cancel_outlined,
                  size: 20,
                  color: Colors.white,
                ),
                options: FFButtonOptions(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  // Visible primary background so the button stands out
                  color: theme.primaryColor,
                  textStyle: theme.subtitle1.override(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  // small elevation to separate from background
                  elevation: 2,
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          )
        : null,
  );
}
  void _showCancelDialog(BuildContext context, WidgetRef ref, dynamic l10n) {
    final theme = FlutterFlowTheme.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.secondaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.cancelOvertime,
          style: theme.title2.override(
            color: theme.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          FFButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            text: l10n.close,
            options: FFButtonOptions(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: theme.secondaryText.withValues(alpha: 0.1),
              textStyle: theme.bodyText1.override(
                color: theme.primaryText,
                fontWeight: FontWeight.w500,
              ),
              elevation: 0,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          FFButton(
            onPressed: () async {

              Navigator.of(dialogContext).pop();

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(
                  child: FFLoadingIndicator(color: theme.primaryColor),
                ),
              );

              // Call cancel API
              await ref
                  .read(overtimeControllerProvider.notifier)
                  .cancelOvertimeRequest(
                    widget.overtimeId
                  );

              // Close loading dialog
              if (context.mounted) {
                Navigator.of(context).pop();
              }

              // Check result
              final overtimeState = ref.read(overtimeControllerProvider);

              if (context.mounted) {
                if (overtimeState.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        overtimeState.errorMessage!,
                        style: theme.bodyText1.override(color: Colors.white),
                      ),
                      backgroundColor: theme.error,
                    ),
                  );
                } else if (overtimeState.successMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        overtimeState.successMessage!,
                        style: theme.bodyText1.override(color: Colors.white),
                      ),
                      backgroundColor: theme.success,
                    ),
                  );
                  // Refresh the leave details
                  await ref
                      .read(overtimeControllerProvider.notifier)
                      .getOvertimeRequestById(widget.overtimeId);
                }
              }
            },
            text: l10n.confirmCancel,
            options: FFButtonOptions(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: theme.error,
              textStyle: theme.bodyText1.override(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              elevation: 2,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildStatusCard(FlutterFlowTheme theme, dynamic overtime) {
    final l10n = AppLocalizations.of(context).overtime;
    final statusColor = _getStatusColor(overtime.status, theme);
    final statusText = _getStatusText(overtime.status, l10n);

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.status,
                style: theme.bodyText2.override(
                  color: theme.secondaryText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                statusText,
                style: theme.title2.override(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getStatusIcon(overtime.status),
              color: statusColor,
              size: 32,
            ),
          ),
        ],
      ),
    ).animateOnPageLoad(animationsMap['containerAnimation']!);
  }

  Widget _buildInfoCard(FlutterFlowTheme theme, dynamic overtime) {
    final l10n = AppLocalizations.of(context).overtime;
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
            l10n.generalInfo,
            style: theme.subtitle1.override(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            theme,
            Icons.tag,
            l10n.requestCode,
            '#${overtime.id}',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            theme,
            Icons.calendar_today,
            l10n.overtimeDate,
            overtime.overtimeDate != null
                ? DateFormat('dd/MM/yyyy').format(overtime.overtimeDate)
                : 'N/A',
          ),
          if (overtime.shiftId != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              theme,
              Icons.schedule,
              l10n.workShift,
              'Ca #${overtime.shiftId}',
            ),
          ],
        ],
      ),
    ).animateOnPageLoad(animationsMap['containerAnimation']!);
  }

  Widget _buildTimeCard(FlutterFlowTheme theme, dynamic overtime) {
    final l10n = AppLocalizations.of(context).overtime;
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
            l10n.overtimeTimeInfo,
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
                  l10n.startTime,
                  overtime.startTime != null
                      ? timeFormat.format(overtime.startTime)
                      : 'N/A',
                  theme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeBox(
                  theme,
                  l10n.endTime,
                  overtime.endTime != null
                      ? timeFormat.format(overtime.endTime)
                      : 'N/A',
                  theme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
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
                      l10n.estimatedHours,
                      style: theme.bodyText1.override(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${overtime.estimatedHours ?? 0} ${l10n.hours}',
                  style: theme.subtitle1.override(
                    color: theme.primaryText,
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
                color: theme.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: theme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.actualHours,
                        style: theme.bodyText1.override(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${overtime.actualHours ?? 0} ${l10n.hours}',
                    style: theme.subtitle1.override(
                      color: theme.primaryText,
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
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
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
              color: theme.primaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectionReasonCard(FlutterFlowTheme theme, dynamic overtime) {
    final l10n = AppLocalizations.of(context).overtime;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cancel_outlined,
                color: theme.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.rejectionReason,
                style: theme.subtitle1.override(
                  color: theme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            overtime.rejectionReason ?? '',
            style: theme.bodyText1.override(
              color: theme.error,
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

  String _getStatusText(String? status, dynamic l10n) {
    switch (status?.toUpperCase()) {
      case 'PENDING':
        return l10n.statusPending;
      case 'APPROVED':
        return l10n.statusApproved;
      case 'REJECTED':
        return l10n.statusRejected;
      case 'CANCELED':
        return l10n.statusCanceled;
      default:
        return l10n.statusUnknown;
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
