import 'package:flutter/material.dart';

class NotificationLocalizations {
  final Locale locale;

  NotificationLocalizations(this.locale);

  static final Map<String, Map<String, String>> _translations = {
    'en': {
      'notifications': 'Notifications',
      'unread_count': 'unread',
      'mark_all_read': 'Mark All as Read',
      'mark_all_read_confirm': 'Are you sure you want to mark all notifications as read?',
      'no_notifications': 'No Notifications',
      'all_caught_up': 'You\'re all caught up!',
      'error_loading_notifications': 'Error loading notifications',
    },
    'vi': {
      'notifications': 'Thông báo',
      'unread_count': 'chưa đọc',
      'mark_all_read': 'Đọc tất cả',
      'mark_all_read_confirm': 'Bạn có chắc chắn muốn đánh dấu tất cả thông báo là đã đọc?',
      'no_notifications': 'Không có thông báo',
      'all_caught_up': 'Bạn đã xem hết tất cả!',
      'error_loading_notifications': 'Lỗi tải thông báo',
    },
  };

  String translate(String key) {
    return _translations[locale.languageCode]?[key] ?? key;
  }

  String get notifications => translate('notifications');
  String get unreadCount => translate('unread_count');
  String get markAllRead => translate('mark_all_read');
  String get markAllReadConfirm => translate('mark_all_read_confirm');
  String get noNotifications => translate('no_notifications');
  String get allCaughtUp => translate('all_caught_up');
  String get errorLoadingNotifications => translate('error_loading_notifications');
}
