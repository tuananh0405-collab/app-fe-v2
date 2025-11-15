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
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        showSnackbar(
          context,
          AppLocalizations.of(context).leave.pleaseSelectDates,
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
        showSnackbar(context, next.successMessage!, duration: 3);
        // Navigate back after successful update
        Future.delayed(const Duration(milliseconds: 500), () {
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor.withValues(alpha: 0.1),
                      theme.primaryColor.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.primaryColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.edit_document,
                        color: theme.primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.leave.updateLeaveRequest,
                            style: theme.title3.override(
                              color: theme.primaryText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.leave.fillDetailsBelow,
                            style: theme.bodyText2.override(
                              color: theme.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
                child: DropdownButtonFormField<int>(
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
                  items: [
                    DropdownMenuItem(
                      value: 1,
                      child: Text(l10n.leave.annualLeave),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Text(l10n.leave.sickLeave),
                    ),
                    DropdownMenuItem(
                      value: 3,
                      child: Text(l10n.leave.personalLeave),
                    ),
                    DropdownMenuItem(
                      value: 4,
                      child: Text(l10n.leave.unpaidLeave),
                    ),
                  ],
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
            ],
          ),
        ),
      ),
    );
  }
}
