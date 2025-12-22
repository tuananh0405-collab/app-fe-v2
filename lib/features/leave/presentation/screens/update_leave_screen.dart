import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../flutter_flow/flutter_flow.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../providers/leave_providers.dart';

class UpdateLeaveScreen extends ConsumerStatefulWidget {
  final String leaveId;

  const UpdateLeaveScreen({super.key, required this.leaveId});

  @override
  ConsumerState<UpdateLeaveScreen> createState() => _UpdateLeaveScreenState();
}

class _UpdateLeaveScreenState extends ConsumerState<UpdateLeaveScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _supportingDocUrlController = TextEditingController();

  int? _employeeId;
  String? _employeeCode;
  int? _departmentId;
  int? _leaveTypeId;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isHalfDayStart = false;
  bool _isHalfDayEnd = false;

  @override
  void initState() {
    super.initState();
    
    // Fetch leave types when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(leaveControllerProvider.notifier).getLeaveTypes();
      ref.read(leaveControllerProvider.notifier).getLeaveBalance();
    });
    
    // Initialize form with existing leave data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final leave = ref.read(leaveControllerProvider).selectedLeave;
      if (leave != null) {
        setState(() {
          _employeeId = leave.employeeId;
          _employeeCode = leave.employeeCode;
          _departmentId = leave.departmentId;
          _leaveTypeId = leave.leaveTypeId;
          _startDate = leave.startDate;
          _endDate = leave.endDate;
          _isHalfDayStart = leave.isHalfDayStart;
          _isHalfDayEnd = leave.isHalfDayEnd;
          _reasonController.text = leave.reason;
          _supportingDocUrlController.text = leave.supportingDocumentUrl ?? '';
        });
      }
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

    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        showSnackbar(
          context,
          leave.pleaseSelectDates,
          duration: 3,
        );
        return;
      }

      if (_employeeId == null ||
          _employeeCode == null ||
          _departmentId == null ||
          _leaveTypeId == null) {
        showSnackbar(context, 'Thông tin đơn nghỉ không hợp lệ', duration: 3);
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
              leave.validationMaxConsecutiveDays(requestedDays, selected.maxConsecutiveDays!),
              duration: 3);
          return;
        }

        // Check max days per year (basic check using requested days only)
        if (selected.maxDaysPerYear != null && requestedDays > selected.maxDaysPerYear!) {
          showSnackbar(context,
              leave.validationMaxDaysPerYear(requestedDays, selected.maxDaysPerYear!),
              duration: 3);
          return;
        }

        // Check minimum notice days
        final nowDate = DateTime.now();
        final daysUntilStart = _startDate!.difference(DateTime(nowDate.year, nowDate.month, nowDate.day)).inDays;
        if (selected.minNoticeDays > 0 && daysUntilStart < selected.minNoticeDays) {
          showSnackbar(context,
              leave.validationMinNoticeDays(selected.minNoticeDays),
              duration: 3);
          return;
        }

        // Check requires document
        if (selected.requiresDocument && _supportingDocUrlController.text.trim().isEmpty) {
          showSnackbar(context, leave.validationDocumentRequired, duration: 3);
          return;
        }
      }

      ref
          .read(leaveControllerProvider.notifier)
          .updateLeaveRequest(
            leaveId: int.parse(widget.leaveId),
            employeeId: _employeeId!,
            employeeCode: _employeeCode!,
            departmentId: _departmentId!,
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

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final leaveState = ref.watch(leaveControllerProvider);
    final dateFormat = DateFormat('dd/MM/yyyy');

    // Listen for success or error
    ref.listen(leaveControllerProvider, (previous, next) {
      if (next.successMessage != null &&
          next.successMessage != previous?.successMessage) {
        showSnackbar(context, l10n.leave.translate(next.successMessage!), duration: 3);
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
        showSnackbar(context, next.errorMessage!, duration: 4);
      }
    });

    if (_employeeId == null) {
      return Scaffold(
        backgroundColor: theme.primaryBackground,
        appBar: AppBar(
          title: Text(
            l10n.leave.updateLeaveRequest,
            style: theme.title2.override(color: Colors.white),
          ),
          backgroundColor: theme.primaryColor,
        ),
        body: Center(child: FFLoadingIndicator(color: theme.primaryColor)),
      );
    }

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        title: Text(
          l10n.leave.updateLeaveRequest,
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
              //         theme.primaryColor.withValues(alpha: 0.1),
              //         theme.primaryColor.withValues(alpha: 0.05),
              //       ],
              //       begin: Alignment.topLeft,
              //       end: Alignment.bottomRight,
              //     ),
              //     borderRadius: BorderRadius.circular(16),
              //     border: Border.all(
              //       color: theme.primaryColor.withValues(alpha: 0.2),
              //       width: 1,
              //     ),
              //   ),
              //   child: Row(
              //     children: [
              //       Container(
              //         padding: const EdgeInsets.all(12),
              //         decoration: BoxDecoration(
              //           color: theme.primaryColor.withValues(alpha: 0.1),
              //           borderRadius: BorderRadius.circular(12),
              //         ),
              //         child: Icon(
              //           Icons.edit_document,
              //           color: theme.primaryColor,
              //           size: 28,
              //         ),
              //       ),
              //       const SizedBox(width: 16),
              //       Expanded(
              //         child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Text(
              //               l10n.leave.updateLeaveRequest,
              //               style: theme.title3.override(
              //                 color: theme.primaryText,
              //                 fontWeight: FontWeight.bold,
              //               ),
              //             ),
              //             const SizedBox(height: 4),
              //             Text(
              //               l10n.leave.fillDetailsBelow,
              //               style: theme.bodyText2.override(
              //                 color: theme.secondaryText,
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              const SizedBox(height: 24),

              // Leave Type Dropdown
              Container(
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryText.withValues(alpha: 0.05),
                      blurRadius: 8,
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
                              'Loading leave types...',
                              style: theme.bodyText1.override(
                                color: theme.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      )
                    : DropdownButtonFormField<int>(
                        value: _leaveTypeId,
                        decoration: InputDecoration(
                          labelText: l10n.leave.leaveType,
                          labelStyle: theme.bodyText1.override(
                            color: theme.secondaryText,
                          ),
                          prefixIcon: Icon(
                            Icons.category_outlined,
                            color: theme.primaryColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.secondaryText.withValues(alpha: 0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.secondaryText.withValues(alpha: 0.2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.primaryColor,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: theme.secondaryBackground,
                        ),
                        items: leaveState.leaveTypes
                            .where((leaveType) {
                              // Always show the currently selected leave type (for editing)
                              if (_leaveTypeId == leaveType.id) return true;
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
                            return l10n.leave.pleaseSelectLeaveType;
                          }
                          return null;
                        },
                      ),
              ),
              const SizedBox(height: 20),

              // Start Date
              Container(
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryText.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () => _selectDate(context, true),
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.leave.startDate,
                      labelStyle: theme.bodyText1.override(
                        color: theme.secondaryText,
                      ),
                      prefixIcon: Icon(
                        Icons.calendar_today,
                        color: theme.primaryColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.secondaryText.withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.secondaryText.withValues(alpha: 0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.primaryColor,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: theme.secondaryBackground,
                    ),
                    child: Text(
                      _startDate == null
                          ? l10n.leave.selectDate
                          : dateFormat.format(_startDate!),
                      style: theme.bodyText1.override(
                        color: _startDate == null
                            ? theme.secondaryText
                            : theme.primaryText,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // End Date
              Container(
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryText.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () => _selectDate(context, false),
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.leave.endDate,
                      labelStyle: theme.bodyText1.override(
                        color: theme.secondaryText,
                      ),
                      prefixIcon: Icon(Icons.event, color: theme.primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.secondaryText.withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.secondaryText.withValues(alpha: 0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.primaryColor,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: theme.secondaryBackground,
                    ),
                    child: Text(
                      _endDate == null
                          ? l10n.leave.selectDate
                          : dateFormat.format(_endDate!),
                      style: theme.bodyText1.override(
                        color: _endDate == null
                            ? theme.secondaryText
                            : theme.primaryText,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Reason
              Container(
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryText.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _reasonController,
                  decoration: InputDecoration(
                    labelText: l10n.leave.reason,
                    labelStyle: theme.bodyText1.override(
                      color: theme.secondaryText,
                    ),
                    hintText: l10n.leave.reasonPlaceholder,
                    hintStyle: theme.bodyText2.override(
                      color: theme.secondaryText.withValues(alpha: 0.6),
                    ),
                    prefixIcon: Icon(
                      Icons.note_outlined,
                      color: theme.primaryColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.secondaryText.withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.secondaryText.withValues(alpha: 0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.primaryColor,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: theme.secondaryBackground,
                  ),
                  style: theme.bodyText1.override(color: theme.primaryText),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.leave.enterReason;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Supporting Document URL (optional)
              Container(
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryText.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _supportingDocUrlController,
                  decoration: InputDecoration(
                    labelText: l10n.leave.supportingDocument,
                    labelStyle: theme.bodyText1.override(
                      color: theme.secondaryText,
                    ),
                    hintText: 'https://example.com/document.pdf',
                    hintStyle: theme.bodyText2.override(
                      color: theme.secondaryText.withValues(alpha: 0.6),
                    ),
                    prefixIcon: Icon(
                      Icons.attach_file,
                      color: theme.primaryColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.secondaryText.withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.secondaryText.withValues(alpha: 0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.primaryColor,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: theme.secondaryBackground,
                  ),
                  style: theme.bodyText1.override(color: theme.primaryText),
                  keyboardType: TextInputType.url,
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              FFButton(
                onPressed: leaveState.isSubmitting ? null : _handleSubmit,
                text: l10n.leave.updateLeaveRequest,
                icon: Icon(
                  leaveState.isSubmitting
                      ? Icons.hourglass_empty
                      : Icons.check_circle_outline,
                  size: 20,
                  color: Colors.white,
                ),
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  color: theme.primaryColor,
                  textStyle: theme.subtitle1.override(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  disabledColor: theme.secondaryText,
                  disabledTextColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Cancel Button
              // FFButton(
              //   onPressed: () {
              //     _showCancelDialog(context, ref);
              //   },
              //   text: l10n.leave.cancelRequest,
              //   icon: const Icon(
              //     Icons.cancel_outlined,
              //     size: 20,
              //     color: Colors.white,
              //   ),
              //   options: FFButtonOptions(
              //     width: double.infinity,
              //     height: 56,
              //     padding: const EdgeInsets.symmetric(horizontal: 24),
              //     color: theme.error,
              //     textStyle: theme.subtitle1.override(
              //       color: Colors.white,
              //       fontWeight: FontWeight.bold,
              //     ),
              //     elevation: 4,
              //     borderRadius: BorderRadius.circular(12),
              //   ),
              // ),
              // const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref) {
    final theme = FlutterFlowTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.secondaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.leave.cancelDialogTitle,
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
              l10n.leave.cancelDialogMessage,
              style: theme.bodyText2.override(color: theme.secondaryText),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              style: theme.bodyText1.override(color: theme.primaryText),
              decoration: InputDecoration(
                hintText: l10n.leave.cancelReasonPlaceholder,
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
            text: l10n.leave.close,
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
                      l10n.leave.pleaseEnterCancelReason,
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
                        l10n.leave.translate(leaveState.successMessage!),
                        style: theme.bodyText1.override(color: Colors.white),
                      ),
                      backgroundColor: theme.success,
                    ),
                  );
                  // Navigate back after successful cancellation
                  context.pop();
                }
              }
            },
            text: l10n.leave.confirmCancel,
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
