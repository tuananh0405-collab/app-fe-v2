import 'package:flutter/material.dart';

class NotificationPreferenceLocalizations {
  final Locale locale;

  NotificationPreferenceLocalizations(this.locale);

  static final Map<String, Map<String, String>> _translations = {
    'en': {
      // Screen Title
      'notification_settings': 'Notification Settings',
      
      // Section Headers
      'notification_types': 'Notification Types',
      'global_settings': 'Global Settings',
      
      // Notification Types
      'leave_approval': 'Leave Approval',
      'leave_approval_desc': 'When your leave request is approved',
      'leave_rejection': 'Leave Rejection',
      'leave_rejection_desc': 'When your leave request is rejected',
      'leave_request': 'Leave Request',
      'leave_request_desc': 'When someone submits a leave request',
      'leave_modified': 'Leave Modified',
      'leave_modified_desc': 'When a leave request is modified',
      'leave_cancelled': 'Leave Cancelled',
      'leave_cancelled_desc': 'When a leave is cancelled',
      'attendance_reminder': 'Attendance Reminder',
      'attendance_reminder_desc': 'Reminders for attendance',
      'schedule_updated': 'Schedule Updated',
      'schedule_updated_desc': 'When your schedule is updated',
      'system_announcement': 'System Announcement',
      'system_announcement_desc': 'Important system announcements',
      'all_notifications': 'All Notifications',
      'all_notifications_desc': 'Global notification settings',
      
      // Notification Channels
      'email_notifications': 'Email Notifications',
      'push_notifications': 'Push Notifications',
      'sms_notifications': 'SMS Notifications',
      'in_app_notifications': 'In-App Notifications',
      
      // Do Not Disturb
      'do_not_disturb': 'Do Not Disturb',
      'do_not_disturb_desc': 'Set a time period when you don\'t want to receive notifications',
      'start_time': 'Start',
      'end_time': 'End',
      'not_set': 'Not set',
      
      // Messages
      'preference_updated': 'Preference updated successfully',
      'failed_to_update': 'Failed to update',
      'dnd_updated': 'Do Not Disturb period updated',
      'failed_to_load': 'Failed to load preferences',
      'retry': 'Retry',
      'unknown_error': 'Unknown error',
    },
    'vi': {
      // Screen Title
      'notification_settings': 'Cài đặt thông báo',
      
      // Section Headers
      'notification_types': 'Loại thông báo',
      'global_settings': 'Cài đặt chung',
      
      // Notification Types
      'leave_approval': 'Phê duyệt nghỉ phép',
      'leave_approval_desc': 'Khi đơn nghỉ phép được phê duyệt',
      'leave_rejection': 'Từ chối nghỉ phép',
      'leave_rejection_desc': 'Khi đơn nghỉ phép bị từ chối',
      'leave_request': 'Yêu cầu nghỉ phép',
      'leave_request_desc': 'Khi có người gửi đơn nghỉ phép',
      'leave_modified': 'Sửa đổi nghỉ phép',
      'leave_modified_desc': 'Khi đơn nghỉ phép được sửa đổi',
      'leave_cancelled': 'Hủy nghỉ phép',
      'leave_cancelled_desc': 'Khi nghỉ phép bị hủy',
      'attendance_reminder': 'Nhắc chấm công',
      'attendance_reminder_desc': 'Nhắc nhở về chấm công',
      'schedule_updated': 'Cập nhật lịch làm',
      'schedule_updated_desc': 'Khi lịch làm việc được cập nhật',
      'system_announcement': 'Thông báo hệ thống',
      'system_announcement_desc': 'Thông báo quan trọng từ hệ thống',
      'all_notifications': 'Tất cả thông báo',
      'all_notifications_desc': 'Cài đặt thông báo chung',
      
      // Notification Channels
      'email_notifications': 'Thông báo Email',
      'push_notifications': 'Thông báo đẩy',
      'sms_notifications': 'Thông báo SMS',
      'in_app_notifications': 'Thông báo trong app',
      
      // Do Not Disturb
      'do_not_disturb': 'Không làm phiền',
      'do_not_disturb_desc': 'Đặt khoảng thời gian không muốn nhận thông báo',
      'start_time': 'Bắt đầu',
      'end_time': 'Kết thúc',
      'not_set': 'Chưa đặt',
      
      // Messages
      'preference_updated': 'Đã cập nhật tùy chọn thành công',
      'failed_to_update': 'Cập nhật thất bại',
      'dnd_updated': 'Đã cập nhật thời gian không làm phiền',
      'failed_to_load': 'Không thể tải tùy chọn',
      'retry': 'Thử lại',
      'unknown_error': 'Lỗi không xác định',
    },
  };

  String translate(String key) {
    return _translations[locale.languageCode]?[key] ?? key;
  }

  // Screen Title
  String get notificationSettings => translate('notification_settings');
  
  // Section Headers
  String get notificationTypes => translate('notification_types');
  String get globalSettings => translate('global_settings');
  
  // Notification Types
  String get leaveApproval => translate('leave_approval');
  String get leaveApprovalDesc => translate('leave_approval_desc');
  String get leaveRejection => translate('leave_rejection');
  String get leaveRejectionDesc => translate('leave_rejection_desc');
  String get leaveRequest => translate('leave_request');
  String get leaveRequestDesc => translate('leave_request_desc');
  String get leaveModified => translate('leave_modified');
  String get leaveModifiedDesc => translate('leave_modified_desc');
  String get leaveCancelled => translate('leave_cancelled');
  String get leaveCancelledDesc => translate('leave_cancelled_desc');
  String get attendanceReminder => translate('attendance_reminder');
  String get attendanceReminderDesc => translate('attendance_reminder_desc');
  String get scheduleUpdated => translate('schedule_updated');
  String get scheduleUpdatedDesc => translate('schedule_updated_desc');
  String get systemAnnouncement => translate('system_announcement');
  String get systemAnnouncementDesc => translate('system_announcement_desc');
  String get allNotifications => translate('all_notifications');
  String get allNotificationsDesc => translate('all_notifications_desc');
  
  // Notification Channels
  String get emailNotifications => translate('email_notifications');
  String get pushNotifications => translate('push_notifications');
  String get smsNotifications => translate('sms_notifications');
  String get inAppNotifications => translate('in_app_notifications');
  
  // Do Not Disturb
  String get doNotDisturb => translate('do_not_disturb');
  String get doNotDisturbDesc => translate('do_not_disturb_desc');
  String get startTime => translate('start_time');
  String get endTime => translate('end_time');
  String get notSet => translate('not_set');
  
  // Messages
  String get preferenceUpdated => translate('preference_updated');
  String get failedToUpdate => translate('failed_to_update');
  String get dndUpdated => translate('dnd_updated');
  String get failedToLoad => translate('failed_to_load');
  String get retry => translate('retry');
  String get unknownError => translate('unknown_error');
}
