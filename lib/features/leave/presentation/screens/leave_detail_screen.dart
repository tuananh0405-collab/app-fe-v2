import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/routing/routes.dart';
import '../../../../flutter_flow/flutter_flow.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../providers/leave_providers.dart';

class LeaveDetailScreen extends ConsumerStatefulWidget {
  final String leaveId;

  const LeaveDetailScreen({super.key, required this.leaveId});

  @override
  ConsumerState<LeaveDetailScreen> createState() => _LeaveDetailScreenState();
}

class _LeaveDetailScreenState extends ConsumerState<LeaveDetailScreen>
    with TickerProviderStateMixin, AnimationControllerMixin {
  @override
  void initState() {
    super.initState();

    // Load leave balance
    Future.microtask(() {
      ref.read(leaveControllerProvider.notifier).getLeaveBalance(employeeId: 7);
    });

    // Setup animations
    setupAnimations({
      'statusCardAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effects: FFAnimations.fadeInSlideUp(
          delay: const Duration(milliseconds: 0),
          duration: const Duration(milliseconds: 600),
        ),
      ),
      'infoCardAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effects: FFAnimations.fadeInSlideUp(
          delay: const Duration(milliseconds: 100),
          duration: const Duration(milliseconds: 600),
        ),
      ),
      'detailsAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effects: FFAnimations.fadeInSlideUp(
          delay: const Duration(milliseconds: 200),
          duration: const Duration(milliseconds: 600),
        ),
      ),
      'reasonCard': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effects: FFAnimations.fadeInSlideUp(
          delay: const Duration(milliseconds: 300),
          duration: const Duration(milliseconds: 600),
        ),
      ),
      'rejectionCard': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effects: FFAnimations.fadeInSlideUp(
          delay: const Duration(milliseconds: 350),
          duration: const Duration(milliseconds: 600),
        ),
      ),
      'actionButtons': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effects: FFAnimations.fadeInSlideUp(
          delay: const Duration(milliseconds: 400),
          duration: const Duration(milliseconds: 600),
        ),
      ),
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final leaveState = ref.watch(leaveControllerProvider);
    final leave = leaveState.selectedLeave;

    if (leave == null) {
      return Scaffold(
        backgroundColor: theme.primaryBackground,
        appBar: AppBar(
          title: Text(
            l10n.leave.leaveDetails,
            style: theme.title2.override(color: Colors.white),
          ),
          backgroundColor: theme.primaryColor,
        ),
        body: Center(
          child: Text(
            l10n.leave.leaveNotFound,
            style: theme.bodyText1.override(color: theme.secondaryText),
          ),
        ),
      );
    }

    final dateFormat = DateFormat('dd/MM/yyyy');
    final dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
    final statusColor = _getStatusColor(leave.status, theme);
    final statusText = _getStatusText(leave.status, l10n);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        title: Text(
          l10n.leave.leaveDetails,
          style: theme.title2.override(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 2,
        backgroundColor: theme.primaryColor,
        leading: FFIconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
          buttonSize: 48,
        ),
        actions: [
          if (leave.status?.toUpperCase() == 'PENDING')
            FFIconButton(
              icon: const Icon(Icons.edit_rounded, color: Colors.white),
              onPressed: () {
                context.push(AppRoutePath.leaveEdit(widget.leaveId));
              },
              buttonSize: 48,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(leaveControllerProvider.notifier)
              .selectLeave(int.parse(widget.leaveId));
          await ref
              .read(leaveControllerProvider.notifier)
              .getLeaveBalance(employeeId: 7);
        },
        color: theme.primaryColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Leave Balance Card
              if (leaveState.leaveBalances.isNotEmpty)
                _buildLeaveBalanceCard(theme, leaveState),
              const SizedBox(height: 16),

              // Status Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [statusColor.withValues(alpha: 0.8), statusColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getStatusIcon(leave.status),
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.leave.status,
                            style: theme.bodyText2.override(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            statusText,
                            style: theme.title1.override(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animateOnPageLoad(animationsMap['statusCardAnimation']!),
              const SizedBox(height: 20),

              // Leave Information
              Container(
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryText.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.leave.leaveInformation,
                        style: theme.title3.override(
                          color: theme.primaryText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Divider(
                        height: 24,
                        color: theme.secondaryText.withValues(alpha: 0.2),
                      ),
                      // Leave ID and Leave Name on same row
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoRow(
                              theme,
                              l10n.leave.leaveId,
                              '#${leave.id}',
                              Icons.tag,
                            ),
                          ),
                          Expanded(
                            child: _buildInfoRow(
                              theme,
                              l10n.leave.employeeCode,
                              leave.employeeCode,
                              Icons.badge,
                            ),
                          ),
                        ],
                      ),
                      // Start Date and End Date on same row
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoRow(
                              theme,
                              l10n.leave.startDate,
                              dateFormat.format(leave.startDate),
                              Icons.calendar_today,
                            ),
                          ),
                          Expanded(
                            child: _buildInfoRow(
                              theme,
                              l10n.leave.endDate,
                              dateFormat.format(leave.endDate),
                              Icons.calendar_today,
                            ),
                          ),
                        ],
                      ),
                      if (leave.isHalfDayStart)
                        _buildInfoRow(
                          theme,
                          '',
                          l10n.leave.halfDayLeaveStart,
                          Icons.access_time,
                        ),
                      if (leave.isHalfDayEnd)
                        _buildInfoRow(
                          theme,
                          '',
                          l10n.leave.halfDayLeaveEnd,
                          Icons.access_time,
                        ),
                      _buildInfoRow(
                        theme,
                        l10n.leave.totalLeaveDays,
                        '${leave.totalLeaveDays?.toStringAsFixed(1) ?? 0} ${l10n.leave.days}',
                        Icons.event_available,
                      ),
                      _buildInfoRow(
                        theme,
                        l10n.leave.totalWorkingDays,
                        '${leave.totalWorkingDays ?? 0} ${l10n.leave.days}',
                        Icons.work,
                      ),
                      _buildInfoRow(
                        theme,
                        l10n.leave.submittedAt,
                        leave.requestedAt != null
                            ? dateTimeFormat.format(leave.requestedAt!)
                            : 'N/A',
                        Icons.send,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Reason Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.leave.reasonLabel,
                        style: theme.title3.override(
                          color: theme.primaryText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        leave.reason,
                        style: theme.bodyText1.override(
                          color: theme.primaryText,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animateOnPageLoad(animationsMap['reasonCard']!),

              // Supporting Document
              if (leave.supportingDocumentUrl != null &&
                  leave.supportingDocumentUrl!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.secondaryBackground,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.attach_file,
                              color: theme.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.leave.supportingDocumentLabel,
                              style: theme.title3.override(
                                color: theme.primaryText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () {
                            // TODO: Open URL
                          },
                          child: Text(
                            leave.supportingDocumentUrl!,
                            style: theme.bodyText2.override(
                              color: theme.primaryColor,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Approval Information
              if (leave.status?.toUpperCase() == 'APPROVED') ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.secondaryBackground,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.verified,
                              color: theme.success,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.leave.approvalInformation,
                              style: theme.title3.override(
                                color: theme.primaryText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          height: 24,
                          color: theme.secondaryText.withValues(alpha: 0.2),
                        ),
                        // Approval Level and Approved At on same row
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoRow(
                                theme,
                                l10n.leave.approvalLevel,
                                '${leave.approvalLevel ?? 'N/A'}',
                                Icons.approval,
                              ),
                            ),
                            if (leave.approvedAt != null)
                              Expanded(
                                child: _buildInfoRow(
                                  theme,
                                  l10n.leave.approvedAt,
                                  dateTimeFormat.format(leave.approvedAt!),
                                  Icons.check_circle,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ).animateOnPageLoad(animationsMap['detailsAnimation']!),
              ],

              // Rejection Information
              if (leave.status?.toUpperCase() == 'REJECTED') ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.error.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.cancel, color: theme.error),
                            const SizedBox(width: 8),
                            Text(
                              'Lý do từ chối',
                              style: theme.title3.override(
                                color: theme.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          leave.rejectionReason ?? 'Không có lý do',
                          style: theme.bodyText1.override(
                            color: theme.primaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animateOnPageLoad(animationsMap['rejectionCard']!),
              ],

              // Edit and Cancel Buttons (only for PENDING status)
              if (leave.status?.toUpperCase() == 'PENDING') ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    // Edit Button
                    Expanded(
                      child: FFButton(
                        onPressed: () {
                          context.push(AppRoutePath.leaveEdit(widget.leaveId));
                        },
                        text: 'Chỉnh sửa',
                        icon: Icon(
                          Icons.edit_rounded,
                          size: 22,
                          color: Colors.white,
                        ),
                        options: FFButtonOptions(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          color: theme.warning,
                          textStyle: theme.subtitle1.override(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          elevation: 4,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Cancel Button
                    Expanded(
                      child: FFButton(
                        onPressed: () {
                          _showCancelDialog(context, ref);
                        },
                        text: 'Hủy đơn',
                        icon: Icon(
                          Icons.cancel_outlined,
                          size: 22,
                          color: Colors.white,
                        ),
                        options: FFButtonOptions(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          color: theme.error,
                          textStyle: theme.subtitle1.override(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          elevation: 4,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ).animateOnPageLoad(animationsMap['actionButtons']!),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Chỉ có thể chỉnh sửa hoặc hủy khi trạng thái là "Chờ duyệt"',
                    style: theme.bodyText2.override(
                      color: theme.secondaryText,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],

              // Info for non-PENDING status
              if (leave.status?.toUpperCase() != 'PENDING') ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Cannot edit leave request with status "${statusText}"',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveBalanceCard(FlutterFlowTheme theme, dynamic leaveState) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor,
            theme.primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Số ngày nghỉ còn lại',
                  style: theme.title3.override(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...leaveState.leaveBalances.map<Widget>((balance) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        balance.leaveTypeName,
                        style: theme.subtitle1.override(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Tổng: ',
                          style: theme.bodyText2.override(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${balance.totalDays.toStringAsFixed(1)} | ',
                          style: theme.subtitle1.override(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Còn lại: ',
                          style: theme.bodyText2.override(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${balance.remainingDays.toStringAsFixed(1)}',
                            style: theme.subtitle1.override(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    FlutterFlowTheme theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 15, color: theme.primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (label.isNotEmpty)
                  Text(
                    label,
                    style: theme.bodyText2.override(
                      color: theme.secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (label.isNotEmpty) const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.subtitle1.override(
                    color: theme.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status, FlutterFlowTheme theme) {
    switch (status?.toUpperCase()) {
      case 'PENDING':
        return theme.warning;
      case 'APPROVED':
        return theme.success;
      case 'REJECTED':
        return theme.error;
      case 'CANCELLED':
        return theme.secondaryText;
      default:
        return theme.primaryColor;
    }
  }

  String _getStatusText(String? status, AppLocalizations l10n) {
    switch (status?.toUpperCase()) {
      case 'PENDING':
        return l10n.leave.statusPending;
      case 'APPROVED':
        return l10n.leave.statusApproved;
      case 'REJECTED':
        return l10n.leave.statusRejected;
      case 'CANCELLED':
        return l10n.leave.statusCancelled;
      default:
        return l10n.leave.statusUnknown;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toUpperCase()) {
      case 'PENDING':
        return Icons.hourglass_empty;
      case 'APPROVED':
        return Icons.check_circle;
      case 'REJECTED':
        return Icons.cancel;
      case 'CANCELLED':
        return Icons.block;
      default:
        return Icons.help;
    }
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref) {
    final theme = FlutterFlowTheme.of(context);
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.secondaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hủy đơn nghỉ',
          style: theme.title2.override(
            color: theme.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vui lòng cung cấp lý do hủy đơn:',
              style: theme.bodyText2.override(color: theme.secondaryText),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              style: theme.bodyText1.override(color: theme.primaryText),
              decoration: InputDecoration(
                hintText: 'Nhập lý do hủy đơn...',
                hintStyle: theme.bodyText2.override(color: theme.secondaryText),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: theme.secondaryText.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.primaryColor, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          FFButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            text: 'Đóng',
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
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Vui lòng nhập lý do hủy',
                      style: theme.bodyText1.override(color: Colors.white),
                    ),
                    backgroundColor: theme.error,
                  ),
                );
                return;
              }

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
                  .read(leaveControllerProvider.notifier)
                  .cancelLeaveRequest(
                    leaveId: int.parse(widget.leaveId),
                    cancellationReason: reasonController.text.trim(),
                  );

              // Close loading dialog
              if (context.mounted) {
                Navigator.of(context).pop();
              }

              // Check result
              final leaveState = ref.read(leaveControllerProvider);

              if (context.mounted) {
                if (leaveState.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        leaveState.errorMessage!,
                        style: theme.bodyText1.override(color: Colors.white),
                      ),
                      backgroundColor: theme.error,
                    ),
                  );
                } else if (leaveState.successMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        leaveState.successMessage!,
                        style: theme.bodyText1.override(color: Colors.white),
                      ),
                      backgroundColor: theme.success,
                    ),
                  );
                  // Refresh the leave details
                  await ref
                      .read(leaveControllerProvider.notifier)
                      .selectLeave(int.parse(widget.leaveId));
                }
              }
            },
            text: 'Xác nhận hủy',
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
}
