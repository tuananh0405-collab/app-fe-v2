import 'package:flutter/material.dart';

class SettingsLocalizations {
  final Locale locale;

  SettingsLocalizations(this.locale);

  static final Map<String, Map<String, String>> _translations = {
    'en': {
      'language': 'Language',
      'english': 'English',
      'vietnamese': 'Tiếng Việt',
      'languageChanged': 'Language changed to',
      'notifications': 'Notifications',
      'notificationPreferences': 'Notification Preferences',
      'notificationPreferencesSubtitle': 'Manage notification settings',
      'pushNotifications': 'Push Notifications',
      'pushNotificationsSubtitle': 'Receive push notifications for updates',
      'general': 'General',
      'devices': 'Devices & Sessions',
      'devicesSubtitle': 'View and manage signed-in devices',
      'privacy': 'Privacy',
      'about': 'About',
      'appVersion': 'App Version',
    },
    'vi': {
      'language': 'Ngôn ngữ',
      'english': 'English',
      'vietnamese': 'Tiếng Việt',
      'languageChanged': 'Ngôn ngữ đã được đổi thành',
      'notifications': 'Thông báo',
      'notificationPreferences': 'Tùy chọn thông báo',
      'notificationPreferencesSubtitle': 'Quản lý cài đặt thông báo',
      'pushNotifications': 'Thông báo đẩy',
      'pushNotificationsSubtitle': 'Nhận thông báo đẩy cho các cập nhật',
      'general': 'Chung',
      'devices': 'Thiết bị & Phiên đăng nhập',
      'devicesSubtitle': 'Xem và quản lý các thiết bị đã đăng nhập',
      'privacy': 'Quyền riêng tư',
      'about': 'Thông tin',
      'appVersion': 'Phiên bản',
    },
  };

  String translate(String key) {
    return _translations[locale.languageCode]?[key] ?? key;
  }

  String get language => translate('language');
  String get english => translate('english');
  String get vietnamese => translate('vietnamese');
  String get languageChanged => translate('languageChanged');
  String get notifications => translate('notifications');
  String get notificationPreferences => translate('notificationPreferences');
  String get notificationPreferencesSubtitle =>
      translate('notificationPreferencesSubtitle');
  String get pushNotifications => translate('pushNotifications');
  String get pushNotificationsSubtitle =>
      translate('pushNotificationsSubtitle');
  String get general => translate('general');
  String get devices => translate('devices');
  String get devicesSubtitle => translate('devicesSubtitle');
  String get privacy => translate('privacy');
  String get about => translate('about');
  String get appVersion => translate('appVersion');
}
