import 'package:flutter/material.dart';

class LeaveLocalizations {
  final Locale locale;

  LeaveLocalizations(this.locale);

  static final Map<String, Map<String, String>> _translations = {
    'en': {
      'create_leave_request': 'Create Leave Request',
      'update_leave_request': 'Update Leave Request',
      'leave_type': 'Leave Type',
      'start_date': 'Start Date',
      'end_date': 'End Date',
      'reason': 'Reason',
      'supporting_document': 'Supporting Document',
      'half_day_start': 'Half Day (Start)',
      'half_day_end': 'Half Day (End)',
      'annual_leave': 'Annual Leave',
      'sick_leave': 'Sick Leave',
      'personal_leave': 'Personal Leave',
      'unpaid_leave': 'Unpaid Leave',
      'select_date': 'Select Date',
      'select_leave_type': 'Select Leave Type',
      'enter_reason': 'Enter reason for leave',
      'reason_placeholder': 'Please provide a detailed reason for your leave request',
      'new_leave_request': 'New Leave Request',
      'fill_details_below': 'Fill in the details below',
      'please_select_dates': 'Please select start and end dates',
      'please_select_leave_type': 'Please select leave type',
      'leave_request_created': 'Leave request created successfully',
      'leave_request_updated': 'Leave request updated successfully',
      'error_creating_leave': 'Error creating leave request',
      'error_updating_leave': 'Error updating leave request',
      // Detail screen
      'leave_details': 'Leave Details',
      'leave_not_found': 'Leave not found',
      'status': 'Status',
      'leave_information': 'Leave Information',
      'leave_id': 'Leave ID',
      'employee_code': 'Employee Code',
      'half_day_leave_start': 'Half-day leave (morning)',
      'half_day_leave_end': 'Half-day leave (afternoon)',
      'total_leave_days': 'Leave Days',
      'total_working_days': 'Working Days',
      'submitted_at': 'Submitted At',
      'days': 'days',
      'reason_label': 'Reason for leave:',
      'supporting_document_label': 'Supporting Document',
      'approval_information': 'Approval Information',
      'approval_level': 'Approval Level',
      'approved_at': 'Approved At',
      'rejection_reason': 'Rejection Reason',
      'no_reason_provided': 'No reason provided',
      'edit': 'Edit',
      'cancel_request': 'Cancel Request',
      'edit_cancel_note': 'You can only edit or cancel when status is "Pending"',
      'cancel_dialog_title': 'Cancel Leave Request',
      'cancel_dialog_message': 'Please provide a reason for cancellation:',
      'cancel_reason_placeholder': 'Enter cancellation reason...',
      'close': 'Close',
      'confirm_cancel': 'Confirm Cancel',
      'please_enter_cancel_reason': 'Please enter a cancellation reason',
      // Status texts
      'status_pending': 'Pending',
      'status_approved': 'Approved',
      'status_rejected': 'Rejected',
      'status_cancelled': 'Cancelled',
      'status_unknown': 'Unknown',
    },
    'vi': {
      'create_leave_request': 'Tạo đơn xin nghỉ',
      'update_leave_request': 'Cập nhật đơn xin nghỉ',
      'leave_type': 'Loại nghỉ phép',
      'start_date': 'Ngày bắt đầu',
      'end_date': 'Ngày kết thúc',
      'reason': 'Lý do',
      'supporting_document': 'Tài liệu hỗ trợ',
      'half_day_start': 'Nửa ngày (Đầu)',
      'half_day_end': 'Nửa ngày (Cuối)',
      'annual_leave': 'Nghỉ phép năm',
      'sick_leave': 'Nghỉ ốm',
      'personal_leave': 'Nghỉ việc riêng',
      'unpaid_leave': 'Nghỉ không lương',
      'select_date': 'Chọn ngày',
      'select_leave_type': 'Chọn loại nghỉ phép',
      'enter_reason': 'Nhập lý do nghỉ',
      'reason_placeholder': 'Vui lòng cung cấp lý do chi tiết cho đơn xin nghỉ của bạn',
      'new_leave_request': 'Đơn xin nghỉ mới',
      'fill_details_below': 'Điền thông tin chi tiết bên dưới',
      'please_select_dates': 'Vui lòng chọn ngày bắt đầu và kết thúc',
      'please_select_leave_type': 'Vui lòng chọn loại nghỉ phép',
      'leave_request_created': 'Đơn xin nghỉ đã được tạo thành công',
      'leave_request_updated': 'Đơn xin nghỉ đã được cập nhật thành công',
      'error_creating_leave': 'Lỗi khi tạo đơn xin nghỉ',
      'error_updating_leave': 'Lỗi khi cập nhật đơn xin nghỉ',
      // Detail screen
      'leave_details': 'Chi tiết đơn nghỉ',
      'leave_not_found': 'Không tìm thấy đơn nghỉ',
      'status': 'Trạng thái',
      'leave_information': 'Thông tin đơn nghỉ',
      'leave_id': 'Mã đơn',
      'employee_code': 'Mã nhân viên',
      'half_day_leave_start': 'Nghỉ nửa ngày (sáng)',
      'half_day_leave_end': 'Nghỉ nửa ngày (chiều)',
      'total_leave_days': 'Tổng số ngày nghỉ',
      'total_working_days': 'Tổng số ngày làm việc',
      'submitted_at': 'Ngày gửi đơn',
      'days': 'ngày',
      'reason_label': 'Lý do nghỉ:',
      'supporting_document_label': 'Tài liệu đính kèm',
      'approval_information': 'Thông tin phê duyệt',
      'approval_level': 'Cấp phê duyệt',
      'approved_at': 'Ngày phê duyệt',
      'rejection_reason': 'Lý do từ chối',
      'no_reason_provided': 'Không có lý do',
      'edit': 'Chỉnh sửa',
      'cancel_request': 'Hủy đơn',
      'edit_cancel_note': 'Chỉ có thể chỉnh sửa hoặc hủy khi trạng thái là "Chờ duyệt"',
      'cancel_dialog_title': 'Hủy đơn nghỉ',
      'cancel_dialog_message': 'Vui lòng cung cấp lý do hủy đơn:',
      'cancel_reason_placeholder': 'Nhập lý do hủy đơn...',
      'close': 'Đóng',
      'confirm_cancel': 'Xác nhận hủy',
      'please_enter_cancel_reason': 'Vui lòng nhập lý do hủy',
      // Status texts
      'status_pending': 'Chờ duyệt',
      'status_approved': 'Đã duyệt',
      'status_rejected': 'Từ chối',
      'status_cancelled': 'Đã hủy',
      'status_unknown': 'Không xác định',
    },
  };

  String translate(String key) {
    return _translations[locale.languageCode]?[key] ?? key;
  }

  String get createLeaveRequest => translate('create_leave_request');
  String get updateLeaveRequest => translate('update_leave_request');
  String get leaveType => translate('leave_type');
  String get startDate => translate('start_date');
  String get endDate => translate('end_date');
  String get reason => translate('reason');
  String get supportingDocument => translate('supporting_document');
  String get halfDayStart => translate('half_day_start');
  String get halfDayEnd => translate('half_day_end');
  String get annualLeave => translate('annual_leave');
  String get sickLeave => translate('sick_leave');
  String get personalLeave => translate('personal_leave');
  String get unpaidLeave => translate('unpaid_leave');
  String get selectDate => translate('select_date');
  String get selectLeaveType => translate('select_leave_type');
  String get enterReason => translate('enter_reason');
  String get reasonPlaceholder => translate('reason_placeholder');
  String get newLeaveRequest => translate('new_leave_request');
  String get fillDetailsBelow => translate('fill_details_below');
  String get pleaseSelectDates => translate('please_select_dates');
  String get pleaseSelectLeaveType => translate('please_select_leave_type');
  String get leaveRequestCreated => translate('leave_request_created');
  String get leaveRequestUpdated => translate('leave_request_updated');
  String get errorCreatingLeave => translate('error_creating_leave');
  String get errorUpdatingLeave => translate('error_updating_leave');
  
  // Detail screen
  String get leaveDetails => translate('leave_details');
  String get leaveNotFound => translate('leave_not_found');
  String get status => translate('status');
  String get leaveInformation => translate('leave_information');
  String get leaveId => translate('leave_id');
  String get employeeCode => translate('employee_code');
  String get halfDayLeaveStart => translate('half_day_leave_start');
  String get halfDayLeaveEnd => translate('half_day_leave_end');
  String get totalLeaveDays => translate('total_leave_days');
  String get totalWorkingDays => translate('total_working_days');
  String get submittedAt => translate('submitted_at');
  String get days => translate('days');
  String get reasonLabel => translate('reason_label');
  String get supportingDocumentLabel => translate('supporting_document_label');
  String get approvalInformation => translate('approval_information');
  String get approvalLevel => translate('approval_level');
  String get approvedAt => translate('approved_at');
  String get rejectionReason => translate('rejection_reason');
  String get noReasonProvided => translate('no_reason_provided');
  String get edit => translate('edit');
  String get cancelRequest => translate('cancel_request');
  String get editCancelNote => translate('edit_cancel_note');
  String get cancelDialogTitle => translate('cancel_dialog_title');
  String get cancelDialogMessage => translate('cancel_dialog_message');
  String get cancelReasonPlaceholder => translate('cancel_reason_placeholder');
  String get close => translate('close');
  String get confirmCancel => translate('confirm_cancel');
  String get pleaseEnterCancelReason => translate('please_enter_cancel_reason');
  
  // Status texts
  String get statusPending => translate('status_pending');
  String get statusApproved => translate('status_approved');
  String get statusRejected => translate('status_rejected');
  String get statusCancelled => translate('status_cancelled');
  String get statusUnknown => translate('status_unknown');
}
