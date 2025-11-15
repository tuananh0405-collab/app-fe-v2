import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'common_localizations.dart';
import 'leave_localizations.dart';
import 'notification_localizations.dart';
import 'home_localizations.dart';

// Locale Provider - Simple state management without persistence
final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));

// Main App Localizations - Aggregates all feature localizations
class AppLocalizations {
  final Locale locale;
  
  late final CommonLocalizations common;
  late final LeaveLocalizations leave;
  late final NotificationLocalizations notification;
  late final HomeLocalizations home;

  AppLocalizations(this.locale) {
    common = CommonLocalizations(locale);
    leave = LeaveLocalizations(locale);
    notification = NotificationLocalizations(locale);
    home = HomeLocalizations(locale);
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'vi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
