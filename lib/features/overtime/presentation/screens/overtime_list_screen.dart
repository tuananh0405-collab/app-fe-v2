import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/localization/app_localizations.dart';
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
  // Filter state
  String? _selectedStatus;
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

    // Load overtime requests when screen opens
    Future.microtask(() {
      ref.read(overtimeControllerProvider.notifier).getMyOvertimeRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final overtime = l10n.overtime;
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
          overtime.manageOvertime,
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
                    // Quick Filter Bar
                    _buildQuickFilterBar(context, theme, overtime, overtimeState),
                    
                    // Active Filters
                    _buildActiveFilters(context, theme, overtime),
                    
                    // Overtime Requests List
                    if (_getFilteredOvertimeRequests(overtimeState.overtimeRequests).isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(
                          child: Text(
                            overtime.noOvertimeRequests,
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
                        itemCount: _getFilteredOvertimeRequests(overtimeState.overtimeRequests).length,
                        itemBuilder: (context, index) {
                          final overtimeRequest =
                              _getFilteredOvertimeRequests(overtimeState.overtimeRequests)[index];
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
          overtime.createOvertime,
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
    final l10n = AppLocalizations.of(context);
    final overtime = l10n.overtime;
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
                      '${overtime.overtimeRequestNumber}${overtimeRequest.id}',
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
                    '${overtimeRequest.estimatedHours} ${overtime.hours}',
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
        color: statusColor.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha:0.3),
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
    final l10n = AppLocalizations.of(context);
    final overtime = l10n.overtime;
    
    switch (status?.toUpperCase()) {
      case 'PENDING':
        return overtime.statusPending;
      case 'CANCELED':
        return overtime.statusCanceled;
      case 'APPROVED':
        return overtime.statusApproved;
      case 'REJECTED':
        return overtime.statusRejected;
      default:
        return overtime.statusCanceled;
    }
  }

  // Filter overtime requests locally
  List<dynamic> _getFilteredOvertimeRequests(List<dynamic> requests) {
    return requests.where((request) {
      // Filter by status
      if (_selectedStatus != null && request.status?.toUpperCase() != _selectedStatus?.toUpperCase()) {
        return false;
      }

      // Filter by date range
      if (_startDate != null) {
        final requestDate = DateTime(
          request.overtimeDate.year,
          request.overtimeDate.month,
          request.overtimeDate.day,
        );
        final filterStartDate = DateTime(
          _startDate!.year,
          _startDate!.month,
          _startDate!.day,
        );
        if (requestDate.isBefore(filterStartDate)) {
          return false;
        }
      }

      if (_endDate != null) {
        final requestDate = DateTime(
          request.overtimeDate.year,
          request.overtimeDate.month,
          request.overtimeDate.day,
        );
        final filterEndDate = DateTime(
          _endDate!.year,
          _endDate!.month,
          _endDate!.day,
        );
        if (requestDate.isAfter(filterEndDate)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _showFilterBottomSheet(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final overtime = l10n.overtime;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
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
                        'Filter',
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
                            overtime.status,
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
                              'CANCELED'
                            ].map((status) {
                              final isSelected = _selectedStatus == status;
                              return ChoiceChip(
                                label: Text(_getStatusText(status)),
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

                          // Date Range Filter
                          Text(
                            'Date Range',
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
                                          : 'From Date',
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
                                          : 'To Date',
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
                            'Reset',
                            style: TextStyle(color: theme.primaryColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // Update local state to reflect changes
                            this.setState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Apply',
                            style: TextStyle(color: Colors.white),
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
      dynamic overtime, dynamic overtimeState) {
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
                  overtime.status,
                  style: theme.bodyText2.override(
                    color: theme.secondaryText,
                    fontSize: 13,
                  ),
                ),
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(
                      overtime.status,
                      style: theme.bodyText2.override(fontSize: 13),
                    ),
                  ),
                  ...['PENDING', 'APPROVED', 'REJECTED', 'CANCELED'].map(
                    (status) => DropdownMenuItem<String>(
                      value: status,
                      child: Text(
                        _getStatusText(status),
                        style: theme.bodyText2.override(fontSize: 13),
                      ),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
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
            tooltip: 'More Filters',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters(BuildContext context, FlutterFlowTheme theme,
      dynamic overtime) {
    if (_selectedStatus == null &&
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
                    '${overtime.status}: ${_getStatusText(_selectedStatus)}'),
                backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                labelStyle: theme.bodyText2.override(color: theme.primaryColor),
                onDeleted: () {
                  setState(() {
                    _selectedStatus = null;
                  });
                },
                deleteIconColor: theme.primaryColor,
              ),
            ),
          if (_startDate != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(
                    'From: ${DateFormat('dd/MM/yyyy').format(_startDate!)}'),
                backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                labelStyle: theme.bodyText2.override(color: theme.primaryColor),
                onDeleted: () {
                  setState(() {
                    _startDate = null;
                  });
                },
                deleteIconColor: theme.primaryColor,
              ),
            ),
          if (_endDate != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(
                    'To: ${DateFormat('dd/MM/yyyy').format(_endDate!)}'),
                backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                labelStyle: theme.bodyText2.override(color: theme.primaryColor),
                onDeleted: () {
                  setState(() {
                    _endDate = null;
                  });
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
                      _startDate = null;
                      _endDate = null;
                    });
                  },
                  child: Chip(
                    label: const Text('Reset'),
                    backgroundColor: theme.secondaryBackground,
                    labelStyle: theme.bodyText2,
                  )))
        ],
      ),
    );
  }
}
