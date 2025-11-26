import 'package:flutter/material.dart';

class OvertimeLocalizations {
  final Locale locale;

  OvertimeLocalizations(this.locale);

  static final Map<String, Map<String, String>> _translations = {
    'en': {
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
      'error_creating_overtime': 'Error creating overtime request',
      'error_updating_overtime': 'Error updating overtime request',
      'creating_request': 'Creating request...',
      'create_request': 'Create Overtime Request',
      'hours': 'hours',
      'shift_1': 'Shift 1',
      'shift_2': 'Shift 2',
      'shift_3': 'Shift 3',
    },
    'vi': {
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
      'error_creating_overtime': 'Lỗi khi tạo đơn làm thêm giờ',
      'error_updating_overtime': 'Lỗi khi cập nhật đơn làm thêm giờ',
      'creating_request': 'Đang tạo đơn...',
      'create_request': 'Tạo đơn làm thêm',
      'hours': 'giờ',
      'shift_1': 'Ca 1',
      'shift_2': 'Ca 2',
      'shift_3': 'Ca 3',
    },
  };

  String translate(String key) {
    return _translations[locale.languageCode]?[key] ?? key;
  }

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
  String get errorCreatingOvertime => translate('error_creating_overtime');
  String get errorUpdatingOvertime => translate('error_updating_overtime');
  String get creatingRequest => translate('creating_request');
  String get createRequest => translate('create_request');
  String get hours => translate('hours');
  String get shift1 => translate('shift_1');
  String get shift2 => translate('shift_2');
  String get shift3 => translate('shift_3');
}
