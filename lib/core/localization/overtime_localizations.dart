import 'package:flutter/material.dart';

class OvertimeLocalizations {
  final Locale locale;

  OvertimeLocalizations(this.locale);

  static final Map<String, Map<String, String>> _translations = {
    'en': {
      'manage_overtime': 'Manage Overtime',
      'no_overtime_requests': 'No overtime requests yet',
      'create_overtime': 'Create Overtime',
      'overtime_request_number': 'Overtime Request #',
      'status_pending': 'Pending',
      'status_approved': 'Approved',
      'status_rejected': 'Rejected',
      'status_canceled': 'Canceled',
      'status_unknown': 'Unknown',
      'create_overtime_request': 'Create Overtime Request',
      'update_overtime_request': 'Update Overtime Request',
      'shift': 'Shift',
      'overtime_date': 'Overtime Date',
      'start_time': 'Start Time',
      'end_time': 'End Time',
      'estimated_hours': 'Estimated Hours',
      'reason': 'Reason for Overtime',
      'select_date': 'Select Date',
      'select_time': 'Select Time',
      'select_shift': 'Select Shift',
      'enter_reason': 'Enter reason for overtime',
      'reason_placeholder': 'Please provide a detailed reason for your overtime request',
      'new_overtime_request': 'New Overtime Request',
      'fill_details_below': 'Fill in the details below',
      'please_select_date': 'Please select overtime date',
      'please_select_times': 'Please select start and end times',
      'please_select_shift': 'Please select shift',
      'overtime_request_created': 'Overtime request created successfully',
      'overtime_request_updated': 'Overtime request updated successfully',
  'overtime_request_canceled': 'Overtime request canceled successfully',
      'error_creating_overtime': 'Error creating overtime request',
      'error_updating_overtime': 'Error updating overtime request',
      'creating_request': 'Creating request...',
      'create_request': 'Create Overtime Request',
      'hours': 'hours',
      'shift_1': 'Shift 1',
      'shift_2': 'Shift 2',
      'shift_3': 'Shift 3',
      // Update screen
      'update_request_number': 'Update Request #',
      'edit_details_below': 'Edit the details below',
      'cannot_edit': '(Cannot edit)',
      'start': 'Start',
      'end': 'End',
      'enter_reason_placeholder': 'Enter reason for overtime...',
      'please_enter_reason': 'Please enter a reason',
      'reason_min_length': 'Reason must be at least 10 characters',
      'updating_request': 'Updating...',
      'update_request': 'Update Request',
      // Detail screen
      'overtime_detail': 'Overtime Detail',
      'general_info': 'General Information',
      'overtime_time_info': 'Overtime Time',
      'request_code': 'Request Code',
      'work_shift': 'Work Shift',
      'status': 'Status',
      'actual_hours': 'Actual Hours',
      'cancel_request': 'Cancel Request',
      'edit': 'Edit',
      'cancel_overtime': 'Cancel Overtime',
      'confirm_cancel': 'Confirm Cancel',
      'close': 'Close',
      'rejection_reason': 'Rejection Reason',
      'not_found': 'Overtime request not found',
      'edit_cancel_hint': 'You can only edit or cancel when status is "Pending"',
    },
    'vi': {
      'manage_overtime': 'Quản lý làm thêm giờ',
      'no_overtime_requests': 'Chưa có đơn làm thêm giờ nào',
      'create_overtime': 'Tạo đơn làm thêm',
      'overtime_request_number': 'Đơn làm thêm #',
      'status_pending': 'Chờ duyệt',
      'status_approved': 'Đã duyệt',
      'status_rejected': 'Từ chối',
      'status_canceled': 'Đã hủy',
      'status_unknown': 'Không xác định',
      'create_overtime_request': 'Tạo đơn làm thêm giờ',
      'update_overtime_request': 'Cập nhật đơn làm thêm giờ',
      'shift': 'Ca làm việc',
      'overtime_date': 'Ngày làm thêm',
      'start_time': 'Giờ bắt đầu',
      'end_time': 'Giờ kết thúc',
      'estimated_hours': 'Số giờ dự kiến',
      'reason': 'Lý do làm thêm',
      'select_date': 'Chọn ngày',
      'select_time': 'Chọn giờ',
      'select_shift': 'Chọn ca làm việc',
      'enter_reason': 'Nhập lý do làm thêm',
      'reason_placeholder': 'Vui lòng cung cấp lý do chi tiết cho đơn làm thêm giờ của bạn',
      'new_overtime_request': 'Đơn làm thêm giờ mới',
      'fill_details_below': 'Điền thông tin bên dưới',
      'please_select_date': 'Vui lòng chọn ngày làm thêm',
      'please_select_times': 'Vui lòng chọn thời gian bắt đầu và kết thúc',
      'please_select_shift': 'Vui lòng chọn ca làm việc',
      'overtime_request_created': 'Đơn làm thêm giờ đã được tạo thành công',
      'overtime_request_updated': 'Đơn làm thêm giờ đã được cập nhật thành công',
  'overtime_request_canceled': 'Hủy đơn làm thêm thành công',
      'error_creating_overtime': 'Lỗi khi tạo đơn làm thêm giờ',
      'error_updating_overtime': 'Lỗi khi cập nhật đơn làm thêm giờ',
      'creating_request': 'Đang tạo đơn...',
      'create_request': 'Tạo đơn làm thêm',
      'hours': 'giờ',
      'shift_1': 'Ca 1',
      'shift_2': 'Ca 2',
      'shift_3': 'Ca 3',
      // Update screen
      'update_request_number': 'Cập nhật đơn #',
      'edit_details_below': 'Chỉnh sửa thông tin bên dưới',
      'cannot_edit': '(Không thể sửa)',
      'start': 'Bắt đầu',
      'end': 'Kết thúc',
      'enter_reason_placeholder': 'Nhập lý do làm thêm giờ...',
      'please_enter_reason': 'Vui lòng nhập lý do',
      'reason_min_length': 'Lý do phải có ít nhất 10 ký tự',
      'updating_request': 'Đang cập nhật...',
      'update_request': 'Cập nhật đơn',
      // Detail screen
      'overtime_detail': 'Chi tiết đơn làm thêm',
      'general_info': 'Thông tin chung',
      'overtime_time_info': 'Thời gian làm thêm',
      'request_code': 'Mã đơn',
      'work_shift': 'Ca làm việc',
      'status': 'Trạng thái',
      'actual_hours': 'Số giờ thực tế',
      'cancel_request': 'Hủy đơn',
      'edit': 'Chỉnh sửa',
      'cancel_overtime': 'Hủy đơn nghỉ',
      'confirm_cancel': 'Xác nhận hủy',
      'close': 'Đóng',
      'rejection_reason': 'Lý do từ chối',
      'not_found': 'Không tìm thấy thông tin đơn làm thêm',
      'edit_cancel_hint': 'Chỉ có thể chỉnh sửa hoặc hủy khi trạng thái là "Chờ duyệt"',
    },
  };

  String translate(String key) {
    return _translations[locale.languageCode]?[key] ?? key;
  }

  String get manageOvertime => translate('manage_overtime');
  String get noOvertimeRequests => translate('no_overtime_requests');
  String get createOvertime => translate('create_overtime');
  String get overtimeRequestNumber => translate('overtime_request_number');
  String get statusPending => translate('status_pending');
  String get statusApproved => translate('status_approved');
  String get statusRejected => translate('status_rejected');
  String get statusCanceled => translate('status_canceled');
  String get statusUnknown => translate('status_unknown');
  String get createOvertimeRequest => translate('create_overtime_request');
  String get updateOvertimeRequest => translate('update_overtime_request');
  String get shift => translate('shift');
  String get overtimeDate => translate('overtime_date');
  String get startTime => translate('start_time');
  String get endTime => translate('end_time');
  String get estimatedHours => translate('estimated_hours');
  String get reason => translate('reason');
  String get selectDate => translate('select_date');
  String get selectTime => translate('select_time');
  String get selectShift => translate('select_shift');
  String get enterReason => translate('enter_reason');
  String get reasonPlaceholder => translate('reason_placeholder');
  String get newOvertimeRequest => translate('new_overtime_request');
  String get fillDetailsBelow => translate('fill_details_below');
  String get pleaseSelectDate => translate('please_select_date');
  String get pleaseSelectTimes => translate('please_select_times');
  String get pleaseSelectShift => translate('please_select_shift');
  String get overtimeRequestCreated => translate('overtime_request_created');
  String get overtimeRequestUpdated => translate('overtime_request_updated');
  String get overtimeRequestCanceled => translate('overtime_request_canceled');
  String get errorCreatingOvertime => translate('error_creating_overtime');
  String get errorUpdatingOvertime => translate('error_updating_overtime');
  String get creatingRequest => translate('creating_request');
  String get createRequest => translate('create_request');
  String get hours => translate('hours');
  String get shift1 => translate('shift_1');
  String get shift2 => translate('shift_2');
  String get shift3 => translate('shift_3');
  // Update screen getters
  String get updateRequestNumber => translate('update_request_number');
  String get editDetailsBelow => translate('edit_details_below');
  String get cannotEdit => translate('cannot_edit');
  String get start => translate('start');
  String get end => translate('end');
  String get enterReasonPlaceholder => translate('enter_reason_placeholder');
  String get pleaseEnterReason => translate('please_enter_reason');
  String get reasonMinLength => translate('reason_min_length');
  String get updatingRequest => translate('updating_request');
  String get updateRequest => translate('update_request');
  // Detail screen getters
  String get overtimeDetail => translate('overtime_detail');
  String get generalInfo => translate('general_info');
  String get overtimeTimeInfo => translate('overtime_time_info');
  String get requestCode => translate('request_code');
  String get workShift => translate('work_shift');
  String get status => translate('status');
  String get actualHours => translate('actual_hours');
  String get cancelRequest => translate('cancel_request');
  String get edit => translate('edit');
  String get cancelOvertime => translate('cancel_overtime');
  String get confirmCancel => translate('confirm_cancel');
  String get close => translate('close');
  String get rejectionReason => translate('rejection_reason');
  String get notFound => translate('not_found');
  String get editCancelHint => translate('edit_cancel_hint');
}
