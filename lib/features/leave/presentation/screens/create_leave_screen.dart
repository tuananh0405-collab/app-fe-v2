import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../flutter_flow/flutter_flow.dart';
import '../../providers/leave_providers.dart';
import '../../../auth/providers/auth_providers.dart';
import '../widgets/compact_leave_balance_card.dart';

class CreateLeaveScreen extends ConsumerStatefulWidget {
  const CreateLeaveScreen({super.key});

  @override
  ConsumerState<CreateLeaveScreen> createState() => _CreateLeaveScreenState();
}

class _CreateLeaveScreenState extends ConsumerState<CreateLeaveScreen>
    with TickerProviderStateMixin, AnimationControllerMixin {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _supportingDocUrlController = TextEditingController();

  int? _leaveTypeId;

  DateTime? _startDate;
  DateTime? _endDate;
  final bool _isHalfDayStart = false;
  final bool _isHalfDayEnd = false;

  @override
  void initState() {
    super.initState();

    // Fetch leave types when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(leaveControllerProvider.notifier).getLeaveTypes();
      ref.read(leaveControllerProvider.notifier).getLeaveBalance();
    });

    // Setup animations
    setupAnimations({
      'headerAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effects: FFAnimations.fadeInSlideUp(
          delay: const Duration(milliseconds: 0),
          duration: const Duration(milliseconds: 600),
        ),
      ),
      'formAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effects: FFAnimations.fadeIn(
          delay: const Duration(milliseconds: 100),
          duration: const Duration(milliseconds: 400),
        ),
      ),
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _supportingDocUrlController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _handleSubmit() {
    final l10n = AppLocalizations.of(context);
    final leave = l10n.leave;

    // Get logged-in user data
    final authState = ref.read(loginControllerProvider);
    final user = authState.user;

    // Validate user is logged in
    if (user == null) {
      showSnackbar(context, 'Please login first');
      return;
    }

    // Validate employee ID exists
    if (user.employeeId == null || user.employeeId!.isEmpty) {
      showSnackbar(context, 'Employee ID not found. Please contact administrator.');
      return;
    }

    final employeeId = int.tryParse(user.employeeId!);
    if (employeeId == null) {
      showSnackbar(context, 'Invalid employee ID format.');
      return;
    }

    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        showSnackbar(context, leave.pleaseSelectDates);
        return;
      }

      if (_leaveTypeId == null) {
        showSnackbar(context, leave.pleaseSelectLeaveType);
        return;
      }

      // Additional validation based on selected leave type attributes
      final leaveState = ref.read(leaveControllerProvider);
      final selectedList = leaveState.leaveTypes
          .where((lt) => lt.id == _leaveTypeId)
          .toList();
      if (selectedList.isNotEmpty) {
        final selected = selectedList.first;

        // helper to calculate requested days (inclusive). If excludeWeekends is true,
        // weekend days (Sat, Sun) are not counted.
        int _calculateRequestedDays(DateTime start, DateTime end, bool excludeWeekends) {
          var days = 0;
          var current = DateTime(start.year, start.month, start.day);
          final last = DateTime(end.year, end.month, end.day);
          while (!current.isAfter(last)) {
            if (excludeWeekends) {
              if (current.weekday != DateTime.saturday && current.weekday != DateTime.sunday) {
                days++;
              }
            } else {
              days++;
            }
            current = current.add(const Duration(days: 1));
          }
          return days;
        }

        final requestedDays = _calculateRequestedDays(_startDate!, _endDate!, selected.excludeWeekends);

        // Check max consecutive days
        if (selected.maxConsecutiveDays != null && requestedDays > selected.maxConsecutiveDays!) {
          showSnackbar(context,
              leave.validationMaxConsecutiveDays(requestedDays, selected.maxConsecutiveDays!));
          return;
        }

        // Check max days per year (basic check using requested days only)
        if (selected.maxDaysPerYear != null && requestedDays > selected.maxDaysPerYear!) {
          showSnackbar(context,
              leave.validationMaxDaysPerYear(requestedDays, selected.maxDaysPerYear!));
          return;
        }

        // Check minimum notice days
        final nowDate = DateTime.now();
        final daysUntilStart = _startDate!.difference(DateTime(nowDate.year, nowDate.month, nowDate.day)).inDays;
        if (selected.minNoticeDays > 0 && daysUntilStart < selected.minNoticeDays) {
          showSnackbar(context,
              leave.validationMinNoticeDays(selected.minNoticeDays));
          return;
        }

        // Check requires document
        if (selected.requiresDocument && _supportingDocUrlController.text.trim().isEmpty) {
          showSnackbar(context, leave.validationDocumentRequired);
          return;
        }
      }

      ref
          .read(leaveControllerProvider.notifier)
          .createLeaveRequest(
            employeeId: employeeId,
            employeeCode: user.employeeId!, // Using employeeId as employeeCode for now
            departmentId: 1, // TODO: Get from user profile when available
            leaveTypeId: _leaveTypeId!,
            startDate: _startDate!,
            endDate: _endDate!,
            isHalfDayStart: _isHalfDayStart,
            isHalfDayEnd: _isHalfDayEnd,
            reason: _reasonController.text.trim(),
            supportingDocumentUrl:
                _supportingDocUrlController.text.trim().isEmpty
                ? null
                : _supportingDocUrlController.text.trim(),
            metadata: {},
          );
    }
  }

  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
      return const Color(0xFF3B82F6); // Default blue
    } catch (e) {
      return const Color(0xFF3B82F6); // Default blue
    }
  }

  void _showBalanceDetailDialog(
    BuildContext context,
    FlutterFlowTheme theme,
    dynamic leave,
    dynamic balance,
    String leaveTypeName,
    Color color,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      leaveTypeName,
                      style: theme.title2.override(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Divider(color: Colors.grey.withValues(alpha: 0.2)),
              const SizedBox(height: 16),
              
              // Balance Details
              _buildDetailRow(
                theme,
                'Year',
                '${balance.year}',
                Icons.calendar_today,
                color,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                theme,
                'Total Days',
                '${balance.totalDays}',
                Icons.format_list_numbered,
                color,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                theme,
                'Used Days',
                '${balance.usedDays}',
                Icons.check_circle_outline,
                color,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                theme,
                'Pending Days',
                '${balance.pendingDays}',
                Icons.hourglass_empty,
                color,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                theme,
                'Remaining Days',
                '${balance.remainingDays}',
                Icons.event_available,
                color,
              ),
              const SizedBox(height: 20),
              
              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: theme.subtitle1.override(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    FlutterFlowTheme theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.bodyText2.override(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.bodyText1.override(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final common = l10n.common;
    final leave = l10n.leave;

    final leaveState = ref.watch(leaveControllerProvider);
    final dateFormat = DateFormat('dd/MM/yyyy');

    // Listen for success or error
    ref.listen(leaveControllerProvider, (previous, next) {
      if (next.successMessage != null &&
          next.successMessage != previous?.successMessage) {
        showSnackbar(context, leave.translate(next.successMessage!));
        // Refresh all leave-related data immediately before navigating back
        Future.microtask(() async {
          try {
            // Refresh leave records, balance, and types in parallel for better performance
            await Future.wait([
              ref.read(leaveControllerProvider.notifier).getLeaveRecords(),
              ref.read(leaveControllerProvider.notifier).getLeaveBalance(),
              ref.read(leaveControllerProvider.notifier).getLeaveTypes(),
            ]);
          } catch (_) {
            // ignore errors from refresh - user already saw success
          }

          // Navigate back after data is refreshed
          if (mounted) {
            context.pop();
          }
        });
      } else if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        showSnackbar(context, next.errorMessage!);
      }
    });

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        title: Text(
          leave.createLeaveRequest,
          style: theme.title2.override(color: Colors.white),
        ),
        elevation: 2,
        backgroundColor: theme.primaryColor,
        leading: FFIconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
          buttonSize: 48,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              // Container(
              //   padding: const EdgeInsets.all(20),
              //   decoration: BoxDecoration(
              //     gradient: LinearGradient(
              //       colors: [
              //         theme.primaryColor,
              //         Color.lerp(theme.primaryColor, Colors.black, 0.2)!,
              //       ],
              //       begin: Alignment.topLeft,
              //       end: Alignment.bottomRight,
              //     ),
              //     borderRadius: BorderRadius.circular(16),
              //     boxShadow: [
              //       BoxShadow(
              //         color: theme.primaryColor.withValues(alpha: 0.3),
              //         blurRadius: 10,
              //         offset: const Offset(0, 4),
              //       ),
              //     ],
              //   ),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text(
              //         leave.newLeaveRequest,
              //         style: theme.title2.override(
              //           color: Colors.white,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //       const SizedBox(height: 4),
              //       Text(
              //         leave.fillDetailsBelow,
              //         style: theme.bodyText2.override(color: Colors.white70),
              //       ),
              //     ],
              //   ),
              // ).animateOnPageLoad(animationsMap['headerAnimation']!),

              
              // Compact Leave Balance Display
              if (leaveState.leaveBalances.isNotEmpty) ...[ 
                CompactLeaveBalanceCard(
                  theme: theme,
                  leaveBalances: leaveState.leaveBalances,
                  leaveTypes: leaveState.leaveTypes,
                  title: leave.leaveBalance,
                ).animateOnPageLoad(animationsMap['formAnimation']!),
              ],
              const SizedBox(height: 10),


              // Leave Type Dropdown
              Container(
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryText.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: leaveState.leaveTypes.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              leave.loadingLeaveTypes,
                              style: theme.bodyText2.override(
                                color: theme.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      )
                    : DropdownButtonFormField<int>(
                        value: _leaveTypeId,
                        decoration: InputDecoration(
                          labelText: leave.leaveType,
                          labelStyle: theme.bodyText2.override(
                            color: theme.secondaryText,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: theme.secondaryBackground,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        items: leaveState.leaveTypes
                            .where((leaveType) {
                              // Filter out inactive leave types
                              if (leaveType.status.toLowerCase() != 'active') {
                                return false;
                              }
                              // TODO: Uncomment if needed to filter by remaining days
                              // final balances = leaveState.leaveBalances
                              //     .where((b) => b.leaveTypeId == leaveType.id);
                              // if (balances.isNotEmpty) {
                              //   return balances.first.remainingDays > 0;
                              // }
                              return true;
                            })
                            .map((leaveType) => DropdownMenuItem(
                                  value: leaveType.id,
                                  child: Text(leaveType.leaveTypeName),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _leaveTypeId = value;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null) {
                            return leave.pleaseSelectLeaveType;
                          }
                          return null;
                        },
                      ),
              ).animateOnPageLoad(animationsMap['formAnimation']!),
              
              const SizedBox(height: 10),

              // Date Selection Card
              Container(
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryText.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Start Date
                    InkWell(
                      onTap: () => _selectDate(context, true),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    leave.startDate,
                                    style: theme.bodyText2.override(
                                      color: theme.secondaryText,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _startDate == null
                                        ? leave.selectDate
                                        : dateFormat.format(_startDate!),
                                    style: theme.subtitle1.override(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: _startDate == null
                                          ? theme.secondaryText
                                          : theme.primaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: theme.secondaryText,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // if (_startDate != null)
                    // Container(
                    //   margin: const EdgeInsets.symmetric(horizontal: 16),
                    //   child: CheckboxListTile(
                    //     title: const Text('Nghỉ nửa ngày đầu',
                    //       style: TextStyle(fontSize: 14)),
                    //     value: _isHalfDayStart,
                    //     onChanged: (value) {
                    //       setState(() {
                    //         _isHalfDayStart = value ?? false;
                    //       });
                    //     },
                    //     controlAffinity: ListTileControlAffinity.leading,
                    //     activeColor: Colors.purple[400],
                    //     contentPadding: EdgeInsets.zero,
                    //   ),
                    // ),
                    Divider(
                      height: 1,
                      color: theme.secondaryText.withValues(alpha: 0.2),
                    ),
                    // End Date
                    InkWell(
                      onTap: () => _selectDate(context, false),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(12),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    leave.endDate,
                                    style: theme.bodyText2.override(
                                      color: theme.secondaryText,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _endDate == null
                                        ? leave.selectDate
                                        : dateFormat.format(_endDate!),
                                    style: theme.subtitle1.override(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: _endDate == null
                                          ? theme.secondaryText
                                          : theme.primaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: theme.secondaryText,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // if (_endDate != null)
                    //   Container(
                    //     margin: const EdgeInsets.symmetric(horizontal: 16),
                    //     child: CheckboxListTile(
                    //       title: const Text('Nghỉ nửa ngày cuối',
                    //         style: TextStyle(fontSize: 14)),
                    //       value: _isHalfDayEnd,
                    //       onChanged: (value) {
                    //         setState(() {
                    //           _isHalfDayEnd = value ?? false;
                    //         });
                    //       },
                    //       controlAffinity: ListTileControlAffinity.leading,
                    //       activeColor: Colors.purple[400],
                    //       contentPadding: EdgeInsets.zero,
                    //     ),
                    //   ),
                  ],
                ),
              ).animateOnPageLoad(animationsMap['formAnimation']!),
              const SizedBox(height: 20),

              // Reason
              Container(
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryText.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _reasonController,
                  decoration: InputDecoration(
                    labelText: leave.reason,
                    labelStyle: theme.bodyText2.override(
                      color: theme.secondaryText,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: theme.secondaryBackground,
                    hintText: leave.reasonPlaceholder,
                    hintStyle: theme.bodyText2.override(
                      color: theme.secondaryText,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return leave.enterReason;
                    }
                    return null;
                  },
                ),
              ).animateOnPageLoad(animationsMap['formAnimation']!),
              const SizedBox(height: 20),

              // Supporting Document URL (optional)
              Container(
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryText.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _supportingDocUrlController,
                  decoration: InputDecoration(
                    labelText:
                        '${leave.supportingDocument} (${common.optional})',
                    labelStyle: theme.bodyText2.override(
                      color: theme.secondaryText,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: theme.secondaryBackground,
                    hintText: 'https://example.com/document.pdf',
                    hintStyle: theme.bodyText2.override(
                      color: theme.secondaryText,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  keyboardType: TextInputType.url,
                ),
              ).animateOnPageLoad(animationsMap['formAnimation']!),
              const SizedBox(height: 32),

              // Submit Button
              FFButton(
                onPressed: leaveState.isSubmitting ? null : _handleSubmit,
                text: common.submit,
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 56,
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                  iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                  color: leaveState.isSubmitting
                      ? theme.secondaryText
                      : theme.primaryColor,
                  textStyle: theme.title3.override(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  elevation: leaveState.isSubmitting ? 0 : 6,
                  borderSide: BorderSide(color: Colors.transparent, width: 1),
                  borderRadius: BorderRadius.circular(12),
                  disabledColor: theme.secondaryText,
                  disabledTextColor: Colors.white,
                ),
              ).animateOnPageLoad(animationsMap['formAnimation']!),
              if (leaveState.isSubmitting) ...[
                const SizedBox(height: 16),
                Center(child: FFLoadingIndicator(color: theme.primaryColor)),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
