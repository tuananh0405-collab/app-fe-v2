import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/routing/routes.dart';
import '../../../../flutter_flow/flutter_flow.dart';
import '../../providers/leave_providers.dart';
import 'leave_detail_screen.dart';

class LeaveListScreen extends ConsumerStatefulWidget {
  const LeaveListScreen({super.key});

  @override
  ConsumerState<LeaveListScreen> createState() => _LeaveListScreenState();
}

class _LeaveListScreenState extends ConsumerState<LeaveListScreen>
    with TickerProviderStateMixin, AnimationControllerMixin {
  @override
  void initState() {
    super.initState();

    // Setup animations
    setupAnimations({
      'headerAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effects: FFAnimations.fadeInSlideUp(
          delay: const Duration(milliseconds: 0),
          duration: const Duration(milliseconds: 600),
        ),
      ),
      'cardAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effects: FFAnimations.fadeInSlideUp(
          delay: const Duration(milliseconds: 100),
          duration: const Duration(milliseconds: 600),
        ),
      ),
    });

    // Load leave records when screen opens
    Future.microtask(() {
      ref.read(leaveControllerProvider.notifier).getLeaveRecords();
      // Mock employeeId = 7 as per requirement
      ref.read(leaveControllerProvider.notifier).getLeaveBalance(employeeId: 7);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final leaveState = ref.watch(leaveControllerProvider);

    // Listen for error messages
    ref.listen(leaveControllerProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        showSnackbar(context, next.errorMessage!);
      }
    });

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        title: Text(
          'Quản lý nghỉ phép',
          style: theme.title2.override(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 2,
        backgroundColor: theme.primaryColor,
        actions: [
          FFIconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () {
              ref.read(leaveControllerProvider.notifier).getLeaveRecords();
              ref
                  .read(leaveControllerProvider.notifier)
                  .getLeaveBalance(employeeId: 7);
            },
            buttonSize: 48,
          ),
        ],
      ),
      body: leaveState.isLoading
          ? Center(child: FFLoadingIndicator(color: theme.primaryColor))
          : RefreshIndicator(
              onRefresh: () async {
                ref.read(leaveControllerProvider.notifier).getLeaveRecords();
                await ref
                    .read(leaveControllerProvider.notifier)
                    .getLeaveBalance(employeeId: 7);
              },
              color: theme.primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Leave Balance Card
                    if (leaveState.leaveBalances.isNotEmpty)
                      _buildLeaveBalanceCard(
                        theme,
                        leaveState,
                      ).animateOnPageLoad(animationsMap['headerAnimation']!),

                    // Leave Records List
                    if (leaveState.leaveRecords.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(
                          child: Text(
                            'Chưa có đơn xin nghỉ nào',
                            style: theme.bodyText1.override(
                              color: theme.secondaryText,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: leaveState.leaveRecords.length,
                        itemBuilder: (context, index) {
                          final leaveRecord = leaveState.leaveRecords[index];
                          return _buildLeaveCard(
                            context,
                            theme,
                            leaveRecord,
                            index,
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(AppRoutePath.leavesCreate);
        },
        icon: const Icon(Icons.add),
        label: Text(
          'Tạo đơn nghỉ',
          style: theme.subtitle1.override(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.primaryColor,
        elevation: 6,
      ),
    );
  }

  Widget _buildLeaveBalanceCard(FlutterFlowTheme theme, dynamic leaveState) {
    return Container(
      margin: const EdgeInsets.all(16),
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

  Widget _buildLeaveCard(
    BuildContext context,
    FlutterFlowTheme theme,
    dynamic leave,
    int index,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final statusColor = _getStatusColor(leave.status, theme);
    final statusText = _getStatusText(leave.status);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          // Store the BuildContext before async operation
          final navigator = Navigator.of(context);

          // Call selectLeave and wait for it to complete
          await ref
              .read(leaveControllerProvider.notifier)
              .selectLeave(leave.id!);

          // Check if widget is still mounted before using context
          if (!mounted) return;

          final state = ref.read(leaveControllerProvider);
          if (state.errorMessage == null) {
            // Use the stored navigator instead of context.push
            navigator.push(
              MaterialPageRoute(
                builder: (context) =>
                    LeaveDetailScreen(leaveId: leave.id!.toString()),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Đơn nghỉ #${leave.id}',
                      style: theme.subtitle1.override(
                        color: theme.primaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor, width: 1.5),
                    ),
                    child: Text(
                      statusText,
                      style: theme.bodyText2.override(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: theme.secondaryText,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${dateFormat.format(leave.startDate)} - ${dateFormat.format(leave.endDate)}',
                    style: theme.bodyText2.override(color: theme.primaryText),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.event_available_outlined,
                    size: 16,
                    color: theme.secondaryText,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${leave.totalLeaveDays?.toStringAsFixed(1) ?? 0} ngày nghỉ',
                    style: theme.bodyText2.override(
                      color: theme.primaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (leave.reason.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.primaryBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.note_outlined,
                        size: 16,
                        color: theme.secondaryText,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          leave.reason,
                          style: theme.bodyText2.override(
                            color: theme.secondaryText,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ).animateOnPageLoad(
      AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effects: FFAnimations.fadeInSlideUp(
          delay: Duration(milliseconds: 100 + (index * 50)),
          duration: const Duration(milliseconds: 600),
        ),
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

  String _getStatusText(String? status) {
    switch (status?.toUpperCase()) {
      case 'PENDING':
        return 'Chờ duyệt';
      case 'APPROVED':
        return 'Đã duyệt';
      case 'REJECTED':
        return 'Từ chối';
      case 'CANCELLED':
        return 'Đã hủy';
      default:
        return 'Không rõ';
    }
  }
}
