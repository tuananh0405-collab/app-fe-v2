import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../flutter_flow/flutter_flow.dart';
import '../../providers/overtime_providers.dart';

class CreateOvertimeScreen extends ConsumerStatefulWidget {
  const CreateOvertimeScreen({super.key});

  @override
  ConsumerState<CreateOvertimeScreen> createState() =>
      _CreateOvertimeScreenState();
}

class _CreateOvertimeScreenState extends ConsumerState<CreateOvertimeScreen>
    with TickerProviderStateMixin, AnimationControllerMixin {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  // Mock data - will be replaced with actual data later
  int _shiftId = 1;
  DateTime? _overtimeDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  double _estimatedHours = 0.0;

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
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _overtimeDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _overtimeDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (_startTime ?? TimeOfDay.now())
          : (_endTime ?? TimeOfDay.now()),
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
    if (_startTime != null && _endTime != null) {
      final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
      final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
      final diffMinutes = endMinutes - startMinutes;
      setState(() {
        _estimatedHours = (diffMinutes / 60).abs();
      });
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_overtimeDate == null) {
        showSnackbar(context, 'Vui lòng chọn ngày làm thêm');
        return;
      }
      if (_startTime == null || _endTime == null) {
        showSnackbar(context, 'Vui lòng chọn thời gian bắt đầu và kết thúc');
        return;
      }

      // Combine date with time
      final startDateTime = DateTime(
        _overtimeDate!.year,
        _overtimeDate!.month,
        _overtimeDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );

      final endDateTime = DateTime(
        _overtimeDate!.year,
        _overtimeDate!.month,
        _overtimeDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      ref.read(overtimeControllerProvider.notifier).createOvertimeRequest(
            shiftId: _shiftId,
            overtimeDate: _overtimeDate!,
            startTime: startDateTime,
            endTime: endDateTime,
            estimatedHours: _estimatedHours,
            reason: _reasonController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final overtimeState = ref.watch(overtimeControllerProvider);
    final dateFormat = DateFormat('dd/MM/yyyy');

    // Listen for success or error
    ref.listen(overtimeControllerProvider, (previous, next) {
      if (next.successMessage != null &&
          next.successMessage != previous?.successMessage) {
        showSnackbar(context, next.successMessage!);
        // Navigate back after successful creation
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pop();
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
          'Tạo đơn làm thêm giờ',
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
                      'Đơn làm thêm giờ mới',
                      style: theme.title2.override(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Điền thông tin bên dưới',
                      style: theme.bodyText2.override(color: Colors.white70),
                    ),
                  ],
                ),
              ).animateOnPageLoad(animationsMap['headerAnimation']!),
              const SizedBox(height: 24),

              // Shift ID Dropdown
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
                  value: _shiftId,
                  decoration: InputDecoration(
                    labelText: 'Ca làm việc',
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
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Ca 1')),
                    DropdownMenuItem(value: 2, child: Text('Ca 2')),
                    DropdownMenuItem(value: 3, child: Text('Ca 3')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _shiftId = value;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Vui lòng chọn ca làm việc';
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
                child: InkWell(
                  onTap: () => _selectDate(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ngày làm thêm',
                                style: theme.bodyText2.override(
                                  color: theme.secondaryText,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _overtimeDate != null
                                    ? dateFormat.format(_overtimeDate!)
                                    : 'Chọn ngày',
                                style: theme.subtitle1.override(
                                  color: _overtimeDate != null
                                      ? theme.primaryText
                                      : theme.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.calendar_today,
                          color: theme.primaryColor,
                        ),
                      ],
                    ),
                  ),
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
                              Text(
                                'Giờ bắt đầu',
                                style: theme.bodyText2.override(
                                  color: theme.secondaryText,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _startTime != null
                                        ? _startTime!.format(context)
                                        : 'Chọn giờ',
                                    style: theme.subtitle1.override(
                                      color: _startTime != null
                                          ? theme.primaryText
                                          : theme.secondaryText,
                                    ),
                                  ),
                                  Icon(
                                    Icons.access_time,
                                    color: theme.primaryColor,
                                    size: 20,
                                  ),
                                ],
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
                              Text(
                                'Giờ kết thúc',
                                style: theme.bodyText2.override(
                                  color: theme.secondaryText,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _endTime != null
                                        ? _endTime!.format(context)
                                        : 'Chọn giờ',
                                    style: theme.subtitle1.override(
                                      color: _endTime != null
                                          ? theme.primaryText
                                          : theme.secondaryText,
                                    ),
                                  ),
                                  Icon(
                                    Icons.access_time,
                                    color: theme.primaryColor,
                                    size: 20,
                                  ),
                                ],
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
              if (_estimatedHours > 0)
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
                          const SizedBox(width: 8),
                          Text(
                            'Số giờ dự kiến',
                            style: theme.bodyText1.override(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${_estimatedHours.toStringAsFixed(1)} giờ',
                        style: theme.subtitle1.override(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ).animateOnPageLoad(animationsMap['formAnimation']!),
              if (_estimatedHours > 0) const SizedBox(height: 20),

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
                  decoration: InputDecoration(
                    labelText: 'Lý do làm thêm',
                    labelStyle: theme.bodyText2.override(
                      color: theme.secondaryText,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: theme.secondaryBackground,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập lý do làm thêm';
                    }
                    return null;
                  },
                ),
              ).animateOnPageLoad(animationsMap['formAnimation']!),
              const SizedBox(height: 32),

              // Submit Button
              FFButton(
                onPressed: overtimeState.isSubmitting ? null : _handleSubmit,
                text: overtimeState.isSubmitting
                    ? 'Đang tạo đơn...'
                    : 'Tạo đơn làm thêm',
                options: FFButtonOptions(
                  height: 56,
                  color: theme.primaryColor,
                  textStyle: theme.subtitle1.override(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  elevation: 3,
                  borderRadius: BorderRadius.circular(12),
                ),
              ).animateOnPageLoad(animationsMap['formAnimation']!),
            ],
          ),
        ),
      ),
    );
  }
}
