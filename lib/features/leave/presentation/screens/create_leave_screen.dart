import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../flutter_flow/flutter_flow.dart';
import '../../providers/leave_providers.dart';

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

  // Mock data - will be replaced with actual data later
  int _employeeId = 7;
  String _employeeCode = 'EMP001';
  int _departmentId = 1;
  int _leaveTypeId = 1;

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isHalfDayStart = false;
  bool _isHalfDayEnd = false;

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

    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        showSnackbar(context, leave.pleaseSelectDates);
        return;
      }

      ref
          .read(leaveControllerProvider.notifier)
          .createLeaveRequest(
            employeeId: _employeeId,
            employeeCode: _employeeCode,
            departmentId: _departmentId,
            leaveTypeId: _leaveTypeId,
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
    final common = l10n.common;
    final leave = l10n.leave;

    final leaveState = ref.watch(leaveControllerProvider);
    final dateFormat = DateFormat('dd/MM/yyyy');

    // Listen for success or error
    ref.listen(leaveControllerProvider, (previous, next) {
      if (next.successMessage != null &&
          next.successMessage != previous?.successMessage) {
        showSnackbar(context, next.successMessage!);
        // Navigate back after successful creation
        Future.delayed(const Duration(milliseconds: 500), () {
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor,
                      Color.lerp(theme.primaryColor, Colors.black, 0.2)!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leave.newLeaveRequest,
                      style: theme.title2.override(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      leave.fillDetailsBelow,
                      style: theme.bodyText2.override(color: Colors.white70),
                    ),
                  ],
                ),
              ).animateOnPageLoad(animationsMap['headerAnimation']!),
              const SizedBox(height: 24),

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
                child: DropdownButtonFormField<int>(
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
                  items: [
                    DropdownMenuItem(value: 1, child: Text(leave.annualLeave)),
                    DropdownMenuItem(value: 2, child: Text(leave.sickLeave)),
                    DropdownMenuItem(
                      value: 3,
                      child: Text(leave.personalLeave),
                    ),
                    DropdownMenuItem(value: 4, child: Text(leave.unpaidLeave)),
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
                      return leave.pleaseSelectLeaveType;
                    }
                    return null;
                  },
                ),
              ).animateOnPageLoad(animationsMap['formAnimation']!),
              const SizedBox(height: 20),

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
