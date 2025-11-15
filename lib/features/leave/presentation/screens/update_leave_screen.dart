import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
          _supportingDocUrlController.text =
              leave.supportingDocumentUrl ?? '';
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng chọn ngày bắt đầu và kết thúc'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_employeeId == null ||
          _employeeCode == null ||
          _departmentId == null ||
          _leaveTypeId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thông tin đơn nghỉ không hợp lệ'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      ref.read(leaveControllerProvider.notifier).updateLeaveRequest(
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
            supportingDocumentUrl: _supportingDocUrlController.text.trim().isEmpty
                ? null
                : _supportingDocUrlController.text.trim(),
            metadata: {},
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final leaveState = ref.watch(leaveControllerProvider);
    final dateFormat = DateFormat('dd/MM/yyyy');

    // Listen for success or error
    ref.listen(leaveControllerProvider, (previous, next) {
      if (next.successMessage != null &&
          next.successMessage != previous?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate back after successful update
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.pop();
          }
        });
      } else if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    if (_employeeId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cập nhật đơn nghỉ')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Cập nhật đơn xin nghỉ',
          style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Leave Type Dropdown
              DropdownButtonFormField<int>(
                value: _leaveTypeId,
                decoration: const InputDecoration(
                  labelText: 'Loại nghỉ phép',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Nghỉ phép năm')),
                  DropdownMenuItem(value: 2, child: Text('Nghỉ ốm')),
                  DropdownMenuItem(value: 3, child: Text('Nghỉ việc riêng')),
                  DropdownMenuItem(value: 4, child: Text('Nghỉ không lương')),
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
                    return 'Vui lòng chọn loại nghỉ phép';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Start Date
              InkWell(
                onTap: () => _selectDate(context, true),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Ngày bắt đầu',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _startDate == null
                        ? 'Chọn ngày bắt đầu'
                        : dateFormat.format(_startDate!),
                    style: TextStyle(
                      color: _startDate == null ? Colors.grey : Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Half day start checkbox
              // CheckboxListTile(
              //   title: const Text('Nghỉ nửa ngày đầu'),
              //   value: _isHalfDayStart,
              //   onChanged: (value) {
              //     setState(() {
              //       _isHalfDayStart = value ?? false;
              //     });
              //   },
              //   controlAffinity: ListTileControlAffinity.leading,
              // ),
              // const SizedBox(height: 8),

              // End Date
              InkWell(
                onTap: () => _selectDate(context, false),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Ngày kết thúc',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _endDate == null
                        ? 'Chọn ngày kết thúc'
                        : dateFormat.format(_endDate!),
                    style: TextStyle(
                      color: _endDate == null ? Colors.grey : Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Half day end checkbox
              // CheckboxListTile(
              //   title: const Text('Nghỉ nửa ngày cuối'),
              //   value: _isHalfDayEnd,
              //   onChanged: (value) {
              //     setState(() {
              //       _isHalfDayEnd = value ?? false;
              //     });
              //   },
              //   controlAffinity: ListTileControlAffinity.leading,
              // ),
              // const SizedBox(height: 16),

              // Reason
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Lý do',
                  border: OutlineInputBorder(),
                  hintText: 'Nhập lý do xin nghỉ',
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập lý do';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Supporting Document URL (optional)
              TextFormField(
                controller: _supportingDocUrlController,
                decoration: const InputDecoration(
                  labelText: 'Link tài liệu hỗ trợ (không bắt buộc)',
                  border: OutlineInputBorder(),
                  hintText: 'https://example.com/document.pdf',
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: leaveState.isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: leaveState.isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Cập nhật đơn xin nghỉ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
