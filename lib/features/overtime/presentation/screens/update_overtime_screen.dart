import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../flutter_flow/flutter_flow.dart';
import '../../domain/entities/overtime_entity.dart';
import '../../providers/overtime_providers.dart';

class UpdateOvertimeScreen extends ConsumerStatefulWidget {
  final OvertimeEntity overtime;

  const UpdateOvertimeScreen({
    super.key,
    required this.overtime,
  });

  @override
  ConsumerState<UpdateOvertimeScreen> createState() =>
      _UpdateOvertimeScreenState();
}

class _UpdateOvertimeScreenState extends ConsumerState<UpdateOvertimeScreen>
    with TickerProviderStateMixin, AnimationControllerMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reasonController;

  late int _shiftId;
  late DateTime _overtimeDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late double _estimatedHours;

  @override
  void initState() {
    super.initState();

    // Clear any previous messages when opening this screen
    Future.microtask(() {
      ref.read(overtimeControllerProvider.notifier).clearMessages();
    });

    // Initialize with existing data
    _shiftId = widget.overtime.shiftId ?? 1;
    _overtimeDate = widget.overtime.overtimeDate;
    _startTime = TimeOfDay.fromDateTime(widget.overtime.startTime);
    _endTime = TimeOfDay.fromDateTime(widget.overtime.endTime);
    _estimatedHours = widget.overtime.estimatedHours;
    _reasonController = TextEditingController(text: widget.overtime.reason);

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
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
        _calculateEstimatedHours();
      });
    }
  }

  void _calculateEstimatedHours() {
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;
    final diffMinutes = endMinutes - startMinutes;
    setState(() {
      _estimatedHours = (diffMinutes / 60).abs();
    });
  }

  void _handleSubmit() {
    debugPrint('_handleSubmit called');
    debugPrint('Form is valid: ${_formKey.currentState?.validate()}');
    
    if (_formKey.currentState!.validate()) {
      debugPrint('Validation passed, preparing to update overtime...');
      
      // Combine date with time
      final startDateTime = DateTime(
        _overtimeDate.year,
        _overtimeDate.month,
        _overtimeDate.day,
        _startTime.hour,
        _startTime.minute,
      );

      final endDateTime = DateTime(
        _overtimeDate.year,
        _overtimeDate.month,
        _overtimeDate.day,
        _endTime.hour,
        _endTime.minute,
      );

      debugPrint('Calling updateOvertimeRequest with ID: ${widget.overtime.id}');
      
      ref.read(overtimeControllerProvider.notifier).updateOvertimeRequest(
            overtimeId: widget.overtime.id!,
            shiftId: _shiftId,
            overtimeDate: _overtimeDate,
            startTime: startDateTime,
            endTime: endDateTime,
            estimatedHours: _estimatedHours,
            reason: _reasonController.text.trim(),
          );
    } else {
      debugPrint('Form validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final l10n = AppLocalizations.of(context).overtime;
    final overtimeState = ref.watch(overtimeControllerProvider);
    final dateFormat = DateFormat('dd/MM/yyyy');

    // Debug: Print state to check if isSubmitting is stuck
    debugPrint('OvertimeState - isSubmitting: ${overtimeState.isSubmitting}, isLoading: ${overtimeState.isLoading}');

    // Listen for success or error
    ref.listen(overtimeControllerProvider, (previous, next) {
      if (next.successMessage != null &&
          next.successMessage != previous?.successMessage) {
        showSnackbar(context, next.successMessage!);
        // Navigate back after successful update
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pop(true); // Return true to indicate success
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
          l10n.updateOvertimeRequest,
          style: theme.title2.override(color: Colors.white),
        ),
        elevation: 2,
        backgroundColor: theme.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
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
                      '${l10n.updateRequestNumber}${widget.overtime.id}',
                      style: theme.title2.override(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.editDetailsBelow,
                      style: theme.bodyText2.override(color: Colors.white70),
                    ),
                  ],
                ),
              ).animateOnPageLoad(animationsMap['headerAnimation']!),
              const SizedBox(height: 24),

              // Date Selection Card (Read-only for update)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.secondaryBackground.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.secondaryText.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: theme.secondaryText,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.overtimeDate,
                            style: theme.bodyText2.override(
                              color: theme.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dateFormat.format(_overtimeDate),
                            style: theme.bodyText1.override(
                              fontWeight: FontWeight.w600,
                              color: theme.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      l10n.cannotEdit,
                      style: theme.bodyText2.override(
                        color: theme.secondaryText,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ).animateOnPageLoad(animationsMap['formAnimation']!),
              const SizedBox(height: 20),

              // Time Selection
              Row(
                children: [
                  Expanded(
                    child: Container(
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
                      child: InkWell(
                        onTap: () => _selectTime(context, true),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: theme.primaryColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.start,
                                    style: theme.bodyText2.override(
                                      color: theme.secondaryText,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _startTime.format(context),
                                style: theme.subtitle1.override(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
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
                      child: InkWell(
                        onTap: () => _selectTime(context, false),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: theme.primaryColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.end,
                                    style: theme.bodyText2.override(
                                      color: theme.secondaryText,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _endTime.format(context),
                                style: theme.subtitle1.override(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ).animateOnPageLoad(animationsMap['formAnimation']!),
              const SizedBox(height: 20),

              // Estimated Hours Display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.primaryColor.withValues(alpha: 0.3),
                  ),
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
                        const SizedBox(width: 12),
                        Text(
                          l10n.estimatedHours,
                          style: theme.bodyText1.override(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${_estimatedHours.toStringAsFixed(1)} ${l10n.hours}',
                      style: theme.title3.override(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ).animateOnPageLoad(animationsMap['formAnimation']!),
              const SizedBox(height: 20),

              // Reason Text Field
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
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: l10n.reason,
                    hintText: l10n.enterReasonPlaceholder,
                    hintStyle: theme.bodyText2.override(
                      color: theme.secondaryText.withValues(alpha: 0.5),
                    ),
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
                    prefixIcon: Icon(
                      Icons.description_outlined,
                      color: theme.primaryColor,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.pleaseEnterReason;
                    }
                    if (value.trim().length < 10) {
                      return l10n.reasonMinLength;
                    }
                    return null;
                  },
                ),
              ).animateOnPageLoad(animationsMap['formAnimation']!),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: overtimeState.isSubmitting 
                    ? null 
                    : () {
                        debugPrint('Update button pressed!');
                        _handleSubmit();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  disabledBackgroundColor: Colors.grey,
                ),
                child: overtimeState.isSubmitting
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            l10n.updatingRequest,
                            style: theme.subtitle1.override(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        l10n.updateRequest,
                        style: theme.subtitle1.override(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ).animateOnPageLoad(animationsMap['formAnimation']!),
            ],
          ),
        ),
      ),
    );
  }
}
