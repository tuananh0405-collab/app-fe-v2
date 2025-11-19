import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/settings_localizations.dart';
import '../../../core/routing/routes.dart';
import '../../../core/services/push_notification_providers.dart';
import '../../../flutter_flow/flutter_flow.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = FlutterFlowTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final home = l10n.home;
    final settings = l10n.settings;
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        title: Text(
          home.settings,
          style: theme.title2.override(color: Colors.white),
        ),
        elevation: 2,
        backgroundColor: theme.primaryColor,
        leading: FFIconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [
          // Language Section
          Container(
            color: theme.secondaryBackground,
            margin: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    settings.language,
                    style: theme.subtitle2.override(
                      color: theme.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildLanguageOption(
                  context: context,
                  ref: ref,
                  theme: theme,
                  settings: settings,
                  flag: '🇬🇧',
                  languageName: settings.english,
                  locale: const Locale('en'),
                  isSelected: currentLocale.languageCode == 'en',
                ),
                Divider(
                  height: 1,
                  color: theme.secondaryText.withValues(alpha: 0.2),
                ),
                _buildLanguageOption(
                  context: context,
                  ref: ref,
                  theme: theme,
                  settings: settings,
                  flag: '🇻🇳',
                  languageName: settings.vietnamese,
                  locale: const Locale('vi'),
                  isSelected: currentLocale.languageCode == 'vi',
                ),
              ],
            ),
          ),

          // Notifications Section
          const SizedBox(height: 8),
          Container(
            color: theme.secondaryBackground,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    settings.notifications,
                    style: theme.subtitle2.override(
                      color: theme.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildSettingItem(
                  theme: theme,
                  icon: Icons.tune,
                  title: settings.notificationPreferences,
                  subtitle: settings.notificationPreferencesSubtitle,
                  onTap: () {
                    context.push(AppRoutePath.notificationPreferences);
                  },
                ),
                Divider(
                  height: 1,
                  color: theme.secondaryText.withValues(alpha: 0.2),
                ),
                SwitchListTile(
                  title: Text(
                    settings.pushNotifications,
                    style: theme.bodyText1,
                  ),
                  subtitle: Text(
                    settings.pushNotificationsSubtitle,
                    style: theme.bodyText2.override(color: theme.secondaryText),
                  ),
                  value: ref.watch(pushNotificationEnabledProvider),
                  onChanged: (value) {
                    ref
                        .read(pushNotificationEnabledProvider.notifier)
                        .setEnabled(value);
                  },
                  activeColor: theme.primaryColor,
                ),
              ],
            ),
          ),

          // Other Settings Sections
          const SizedBox(height: 8),
          Container(
            color: theme.secondaryBackground,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    settings.general,
                    style: theme.subtitle2.override(
                      color: theme.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildSettingItem(
                  theme: theme,
                  icon: Icons.devices_other,
                  title: settings.devices,
                  subtitle: settings.devicesSubtitle,
                  onTap: () {
                    context.push(AppRoutePath.devices);
                  },
                ),
                Divider(
                  height: 1,
                  color: theme.secondaryText.withValues(alpha: 0.2),
                ),
                _buildSettingItem(
                  theme: theme,
                  icon: Icons.notifications_outlined,
                  title: settings.notifications,
                  onTap: () {
                    // TODO: Navigate to notifications settings
                  },
                ),
                Divider(
                  height: 1,
                  color: theme.secondaryText.withValues(alpha: 0.2),
                ),
                _buildSettingItem(
                  theme: theme,
                  icon: Icons.security_outlined,
                  title: settings.privacy,
                  onTap: () {
                    // TODO: Navigate to privacy settings
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Container(
            color: theme.secondaryBackground,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    settings.about,
                    style: theme.subtitle2.override(
                      color: theme.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildSettingItem(
                  theme: theme,
                  icon: Icons.info_outline,
                  title: settings.appVersion,
                  trailing: Text(
                    '1.0.0',
                    style: theme.bodyText2.override(color: theme.secondaryText),
                  ),
                  onTap: null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required WidgetRef ref,
    required FlutterFlowTheme theme,
    required SettingsLocalizations settings,
    required String flag,
    required String languageName,
    required Locale locale,
    required bool isSelected,
  }) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 28)),
      title: Text(
        languageName,
        style: theme.subtitle1.override(
          color: theme.primaryText,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: theme.primaryColor)
          : null,
      onTap: () {
        ref.read(localeProvider.notifier).state = locale;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${settings.languageChanged} $languageName'),
            duration: const Duration(seconds: 2),
            backgroundColor: theme.success,
          ),
        );
      },
    );
  }

  Widget _buildSettingItem({
    required FlutterFlowTheme theme,
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: theme.primaryText),
      title: Text(
        title,
        style: theme.subtitle1.override(color: theme.primaryText),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: theme.bodyText2.override(color: theme.secondaryText),
            )
          : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
      enabled: onTap != null,
    );
  }
}
