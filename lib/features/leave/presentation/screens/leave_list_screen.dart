import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/routing/routes.dart';
import '../../../../flutter_flow/flutter_flow.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../providers/leave_providers.dart';
import 'leave_detail_screen.dart';

class LeaveListScreen extends ConsumerStatefulWidget {
  const LeaveListScreen({super.key});

  @override
  ConsumerState<LeaveListScreen> createState() => _LeaveListScreenState();
}

class _LeaveListScreenState extends ConsumerState<LeaveListScreen>
    with TickerProviderStateMixin, AnimationControllerMixin {
  // Filter state
  String? _selectedStatus;
  int? _selectedLeaveTypeId;
  DateTime? _startDate;
  DateTime? _endDate;

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
      ref.read(leaveControllerProvider.notifier).getLeaveBalance();
      ref.read(leaveControllerProvider.notifier).getLeaveTypes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final l10n = AppLocalizations.of(context);
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
          l10n.leave.leaveManagement,
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
                  .getLeaveBalance();
            },
            buttonSize: 48,
          ),
          FFIconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              _showFilterBottomSheet(context);
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
                    .getLeaveBalance();
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
                        l10n,
                      ).animateOnPageLoad(animationsMap['headerAnimation']!),

                    // Quick Filter Bar
                    _buildQuickFilterBar(context, theme, l10n, leaveState),

                    // Active Filters
                    _buildActiveFilters(context, theme, l10n, leaveState),

                    // Leave Records List
                    if (leaveState.leaveRecords.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(
                          child: Text(
                            l10n.leave.noLeaveRequests,
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
                            l10n,
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
          l10n.leave.createLeaveRequest,
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

  Widget _buildLeaveBalanceCard(
      FlutterFlowTheme theme, dynamic leaveState, AppLocalizations l10n) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
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
          /// Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: theme.primaryColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.leave.leaveBalance,
                style: theme.title2.override(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// Danh sách leave
          ...leaveState.leaveBalances.map<Widget>((b) {
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.05),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// Tên loại nghỉ + tổng
                  // Column(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     Text(
                  //       b.leaveTypeName,
                  //       style: theme.subtitle1.override(
                  //         color: Colors.black87,
                  //         fontWeight: FontWeight.w600,
                  //       ),
                  //     ),
                  //     const SizedBox(height: 4),
                  //     Text(
                  //       'Total: ${b.totalDays.toStringAsFixed(1)} days',
                  //       style: theme.bodyText2.override(
                  //         color: Colors.black54,
                  //       ),
                  //     ),
                  //   ],
                  // ),

                  /// Remaining dạng chip
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${b.remainingDays.toStringAsFixed(1)} ${l10n.leave.daysLeft}',
                      style: theme.bodyText1.override(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
    AppLocalizations l10n,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final statusColor = _getStatusColor(leave.status, theme);
    final statusText = _getStatusText(leave.status, l10n);

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
                      '${l10n.leave.leaveId} #${leave.id}',
                      style: theme.subtitle1.override(
                        color: theme.primaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  // Container(
                  //   padding: const EdgeInsets.symmetric(
                  //     horizontal: 12,
                  //     vertical: 6,
                  //   ),
                  //   decoration: BoxDecoration(
                  //     color: statusColor.withValues(alpha: 0.15),
                  //     borderRadius: BorderRadius.circular(12),
                  //     border: Border.all(color: statusColor, width: 1.5),
                  //   ),
                  //   child: Text(
                  //     statusText,
                  //     style: theme.bodyText2.override(
                  //       color: statusColor,
                  //       fontWeight: FontWeight.w600,
                  //     ),
                  //   ),
                  // ),
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
                    '${leave.totalLeaveDays?.toStringAsFixed(1) ?? 0} ${l10n.leave.days}',
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
  void _showFilterBottomSheet(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final leaveState = ref.read(leaveControllerProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.leave.filterTitle,
                        style: theme.title2.override(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status Filter
                          Text(
                            l10n.leave.filterStatus,
                            style: theme.subtitle2.override(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              'PENDING',
                              'APPROVED',
                              'REJECTED',
                              'CANCELLED'
                            ].map((status) {
                              final isSelected = _selectedStatus == status;
                              return ChoiceChip(
                                label: Text(_getStatusText(status, l10n)),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedStatus = selected ? status : null;
                                  });
                                },
                                selectedColor: theme.primaryColor,
                                labelStyle: theme.bodyText2.override(
                                  color: isSelected
                                      ? Colors.white
                                      : theme.primaryText,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),

                          // Leave Type Filter
                          Text(
                            l10n.leave.filterLeaveType,
                            style: theme.subtitle2.override(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            value: _selectedLeaveTypeId,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            items: leaveState.leaveTypes.map((type) {
                              return DropdownMenuItem<int>(
                                value: type.id,
                                child: Text(type.leaveTypeName),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedLeaveTypeId = value;
                              });
                            },
                            hint: Text(l10n.leave.filterSelectLeaveType),
                          ),
                          const SizedBox(height: 20),

                          // Date Range Filter
                          Text(
                            l10n.leave.filterTime,
                            style: theme.subtitle2.override(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _startDate ?? DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        _startDate = picked;
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _startDate != null
                                          ? DateFormat('dd/MM/yyyy')
                                              .format(_startDate!)
                                          : l10n.leave.filterFromDate,
                                      style: theme.bodyText2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _endDate ?? DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        _endDate = picked;
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _endDate != null
                                          ? DateFormat('dd/MM/yyyy')
                                              .format(_endDate!)
                                          : l10n.leave.filterToDate,
                                      style: theme.bodyText2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _selectedStatus = null;
                              _selectedLeaveTypeId = null;
                              _startDate = null;
                              _endDate = null;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: theme.primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            l10n.leave.filterReset,
                            style: TextStyle(color: theme.primaryColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // Apply filters
                            _refreshList();
                            
                            // Update local state to reflect changes if needed
                            this.setState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            l10n.leave.filterApply,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuickFilterBar(BuildContext context, FlutterFlowTheme theme,
      AppLocalizations l10n, dynamic leaveState) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          // Status Dropdown
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: theme.primaryBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: _selectedStatus,
                isExpanded: true,
                underline: const SizedBox(),
                hint: Text(
                  l10n.leave.filterStatus,
                  style: theme.bodyText2.override(
                    color: theme.secondaryText,
                    fontSize: 13,
                  ),
                ),
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(
                      l10n.leave.status,
                      style: theme.bodyText2.override(fontSize: 13),
                    ),
                  ),
                  ...['PENDING', 'APPROVED', 'REJECTED', 'CANCELLED'].map(
                    (status) => DropdownMenuItem<String>(
                      value: status,
                      child: Text(
                        _getStatusText(status, l10n),
                        style: theme.bodyText2.override(fontSize: 13),
                      ),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                  _refreshList();
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Leave Type Dropdown
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: theme.primaryBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<int>(
                value: _selectedLeaveTypeId,
                isExpanded: true,
                underline: const SizedBox(),
                hint: Text(
                  l10n.leave.leaveType,
                  style: theme.bodyText2.override(
                    color: theme.secondaryText,
                    fontSize: 13,
                  ),
                ),
                items: [
                  DropdownMenuItem<int>(
                    value: null,
                    child: Text(
                      l10n.leave.leaveType,
                      style: theme.bodyText2.override(fontSize: 13),
                    ),
                  ),
                  ...leaveState.leaveTypes.map(
                    (type) => DropdownMenuItem<int>(
                      value: type.id,
                      child: Text(
                        type.leaveTypeName,
                        style: theme.bodyText2.override(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedLeaveTypeId = value;
                  });
                  _refreshList();
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          // More Filters Button
          IconButton(
            icon: Icon(
              Icons.tune,
              color: theme.primaryColor,
              size: 20,
            ),
            onPressed: () => _showFilterBottomSheet(context),
            tooltip: l10n.leave.filterTitle,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters(BuildContext context, FlutterFlowTheme theme,
      AppLocalizations l10n, dynamic leaveState) {
    if (_selectedStatus == null &&
        _selectedLeaveTypeId == null &&
        _startDate == null &&
        _endDate == null) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          if (_selectedStatus != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(
                    '${l10n.leave.filterStatus}: ${_getStatusText(_selectedStatus, l10n)}'),
                backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                labelStyle: theme.bodyText2.override(color: theme.primaryColor),
                onDeleted: () {
                  setState(() {
                    _selectedStatus = null;
                  });
                  _refreshList();
                },
                deleteIconColor: theme.primaryColor,
              ),
            ),
          if (_selectedLeaveTypeId != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(
                    '${l10n.leave.filterLeaveType}: ${leaveState.leaveTypes.where((t) => t.id == _selectedLeaveTypeId).isNotEmpty ? leaveState.leaveTypes.where((t) => t.id == _selectedLeaveTypeId).first.leaveTypeName : ''}'),
                backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                labelStyle: theme.bodyText2.override(color: theme.primaryColor),
                onDeleted: () {
                  setState(() {
                    _selectedLeaveTypeId = null;
                  });
                  _refreshList();
                },
                deleteIconColor: theme.primaryColor,
              ),
            ),
          if (_startDate != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(
                    '${l10n.leave.filterFromDate}: ${DateFormat('dd/MM/yyyy').format(_startDate!)}'),
                backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                labelStyle: theme.bodyText2.override(color: theme.primaryColor),
                onDeleted: () {
                  setState(() {
                    _startDate = null;
                  });
                  _refreshList();
                },
                deleteIconColor: theme.primaryColor,
              ),
            ),
          if (_endDate != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(
                    '${l10n.leave.filterToDate}: ${DateFormat('dd/MM/yyyy').format(_endDate!)}'),
                backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                labelStyle: theme.bodyText2.override(color: theme.primaryColor),
                onDeleted: () {
                  setState(() {
                    _endDate = null;
                  });
                  _refreshList();
                },
                deleteIconColor: theme.primaryColor,
              ),
            ),
          Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedStatus = null;
                      _selectedLeaveTypeId = null;
                      _startDate = null;
                      _endDate = null;
                    });
                    _refreshList();
                  },
                  child: Chip(
                    label: Text(l10n.leave.filterReset),
                    backgroundColor: theme.secondaryBackground,
                    labelStyle: theme.bodyText2,
                  )))
        ],
      ),
    );
  }

  void _refreshList() {
    ref.read(leaveControllerProvider.notifier).getLeaveRecords(
          status: _selectedStatus,
          leaveTypeId: _selectedLeaveTypeId,
          startDate: _startDate?.toIso8601String().split('T')[0],
          endDate: _endDate?.toIso8601String().split('T')[0],
        );
  }
}
