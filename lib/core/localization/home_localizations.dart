import 'package:flutter/material.dart';

class HomeLocalizations {
  final Locale locale;

  HomeLocalizations(this.locale);

  static final Map<String, Map<String, String>> _translations = {
    'en': {
      'home': 'Home',
      'profile': 'Profile',
      'settings': 'Settings',
      'logout': 'Logout',
    },
    'vi': {
      'home': 'Trang chủ',
      'profile': 'Hồ sơ',
      'settings': 'Cài đặt',
      'logout': 'Đăng xuất',
    },
  };

  String translate(String key) {
    return _translations[locale.languageCode]?[key] ?? key;
  }

  String get home => translate('home');
  String get profile => translate('profile');
  String get settings => translate('settings');
  String get logout => translate('logout');
}
