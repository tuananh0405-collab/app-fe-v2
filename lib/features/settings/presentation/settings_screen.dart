import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/push_notification_providers.dart';
import '../../../flutter_flow/flutter_flow.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = FlutterFlowTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final home = l10n.home;
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
                    'Language / Ngôn ngữ',
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
                  flag: '🇬🇧',
                  languageName: 'English',
                  locale: const Locale('en'),
                  isSelected: currentLocale.languageCode == 'en',
                ),
                Divider(height: 1, color: theme.secondaryText.withValues(alpha: 0.2)),
                _buildLanguageOption(
                  context: context,
                  ref: ref,
                  theme: theme,
                  flag: '🇻🇳',
                  languageName: 'Tiếng Việt',
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
                    'Notifications / Thông báo',
                    style: theme.subtitle2.override(
                      color: theme.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SwitchListTile(
                  title: Text(
                    'Push Notifications / Thông báo đẩy',
                    style: theme.bodyText1,
                  ),
                  subtitle: Text(
                    'Receive push notifications for updates / Nhận thông báo đẩy cho các cập nhật',
                    style: theme.bodyText2.override(color: theme.secondaryText),
                  ),
                  value: ref.watch(pushNotificationEnabledProvider),
                  onChanged: (value) {
                    ref.read(pushNotificationEnabledProvider.notifier).setEnabled(value);
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
                    'General / Chung',
                    style: theme.subtitle2.override(
                      color: theme.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildSettingItem(
                  theme: theme,
                  icon: Icons.notifications_outlined,
                  title: 'Notifications / Thông báo',
                  onTap: () {
                    // TODO: Navigate to notifications settings
                  },
                ),
                Divider(height: 1, color: theme.secondaryText.withValues(alpha: 0.2)),
                _buildSettingItem(
                  theme: theme,
                  icon: Icons.security_outlined,
                  title: 'Privacy / Quyền riêng tư',
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
                    'About / Thông tin',
                    style: theme.subtitle2.override(
                      color: theme.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildSettingItem(
                  theme: theme,
                  icon: Icons.info_outline,
                  title: 'App Version / Phiên bản',
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
    required String flag,
    required String languageName,
    required Locale locale,
    required bool isSelected,
  }) {
    return ListTile(
      leading: Text(
        flag,
        style: const TextStyle(fontSize: 28),
      ),
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
            content: Text('Language changed to $languageName'),
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
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: theme.primaryText),
      title: Text(
        title,
        style: theme.subtitle1.override(color: theme.primaryText),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
      enabled: onTap != null,
    );
  }
}
