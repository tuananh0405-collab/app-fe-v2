import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../flutter_flow/flutter_flow.dart';
import '../../providers/overtime_providers.dart';
import 'overtime_detail_screen.dart';
import 'create_overtime_screen.dart';

class OvertimeListScreen extends ConsumerStatefulWidget {
  const OvertimeListScreen({super.key});

  @override
  ConsumerState<OvertimeListScreen> createState() =>
      _OvertimeListScreenState();
}

class _OvertimeListScreenState extends ConsumerState<OvertimeListScreen>
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

    // Load overtime requests when screen opens
    Future.microtask(() {
      ref.read(overtimeControllerProvider.notifier).getMyOvertimeRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final overtimeState = ref.watch(overtimeControllerProvider);

    // Listen for error messages
    ref.listen(overtimeControllerProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        showSnackbar(context, next.errorMessage!);
      }
    });

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        title: Text(
          'Quản lý làm thêm giờ',
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
              ref
                  .read(overtimeControllerProvider.notifier)
                  .getMyOvertimeRequests();
            },
            buttonSize: 48,
          ),
        ],
      ),
      body: overtimeState.isLoading
          ? Center(child: FFLoadingIndicator(color: theme.primaryColor))
          : RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(overtimeControllerProvider.notifier)
                    .getMyOvertimeRequests();
              },
              color: theme.primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Overtime Requests List
                    if (overtimeState.overtimeRequests.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(
                          child: Text(
                            'Chưa có đơn làm thêm giờ nào',
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
                        itemCount: overtimeState.overtimeRequests.length,
                        itemBuilder: (context, index) {
                          final overtimeRequest =
                              overtimeState.overtimeRequests[index];
                          return _buildOvertimeCard(
                            context,
                            theme,
                            overtimeRequest,
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
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateOvertimeScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(
          'Tạo đơn làm thêm',
          style: theme.subtitle1.override(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.primaryColor,
      ),
    );
  }

  Widget _buildOvertimeCard(
    BuildContext context,
    FlutterFlowTheme theme,
    overtimeRequest,
    int index,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

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
          final navigator = Navigator.of(context);
          
          await ref
              .read(overtimeControllerProvider.notifier)
              .getOvertimeRequestById(overtimeRequest.id!);

          if (!mounted) return;

          final state = ref.read(overtimeControllerProvider);
          if (state.errorMessage == null) {
            navigator.push(
              MaterialPageRoute(
                builder: (context) => OvertimeDetailScreen(
                  overtimeId: overtimeRequest.id!,
                ),
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
                      'Đơn làm thêm #${overtimeRequest.id}',
                      style: theme.subtitle1.override(
                        color: theme.primaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(overtimeRequest.status, theme),
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
                    dateFormat.format(overtimeRequest.overtimeDate),
                    style: theme.bodyText2.override(color: theme.primaryText),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: theme.secondaryText,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${timeFormat.format(overtimeRequest.startTime)} - ${timeFormat.format(overtimeRequest.endTime)}',
                    style: theme.bodyText2.override(
                      color: theme.primaryText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: theme.secondaryText,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${overtimeRequest.estimatedHours} giờ',
                    style: theme.bodyText2.override(
                      color: theme.primaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 16,
                    color: theme.secondaryText,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      overtimeRequest.reason,
                      style: theme.bodyText2.override(
                        color: theme.secondaryText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animateOnPageLoad(animationsMap['cardAnimation']!);
  }

  Widget _buildStatusChip(String? status, FlutterFlowTheme theme) {
    final statusColor = _getStatusColor(status, theme);
    final statusText = _getStatusText(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        statusText,
        style: theme.bodyText2.override(
          color: statusColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
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
}
