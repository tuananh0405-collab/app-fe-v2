import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/models/notification_type.dart';
import '../../providers/notification_preference_providers.dart';
import '../state/notification_preference_state.dart';

class NotificationPreferencesScreen extends ConsumerStatefulWidget {
  final int employeeId;

  const NotificationPreferencesScreen({
    Key? key,
    required this.employeeId,
  }) : super(key: key);

  @override
  ConsumerState<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends ConsumerState<NotificationPreferencesScreen> {
  @override
  void initState() {
    super.initState();
    // Load preferences when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(notificationPreferenceControllerProvider.notifier)
          .loadPreferences(widget.employeeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationPreferenceControllerProvider);
    final l10n = AppLocalizations.of(context).notificationPreference;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationSettings),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(state, l10n),
    );
  }

  Widget _buildBody(NotificationPreferenceState state, dynamic l10n) {
    if (state.status == NotificationPreferenceStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == NotificationPreferenceStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              l10n.failedToLoad,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(state.errorMessage ?? l10n.unknownError),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(notificationPreferenceControllerProvider.notifier)
                    .loadPreferences(widget.employeeId);
              },
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(notificationPreferenceControllerProvider.notifier)
            .loadPreferences(widget.employeeId);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(l10n.notificationTypes),
          const SizedBox(height: 8),
          ..._buildNotificationTypeCards(state, l10n),
          const SizedBox(height: 24),
          _buildSectionHeader(l10n.globalSettings),
          const SizedBox(height: 8),
          _buildGlobalSettingsCard(state, l10n),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  List<Widget> _buildNotificationTypeCards(NotificationPreferenceState state, dynamic l10n) {
    final notificationTypes = [
      // Leave related
      NotificationType.leaveRequestSubmitted,
      NotificationType.leaveRequestApproved,
      NotificationType.leaveRequestRejected,
      NotificationType.leaveRequestUpdated,
      NotificationType.leaveBalanceLow,
      
      // Attendance related
      NotificationType.attendanceReminder,
      NotificationType.attendanceLateWarning,
      NotificationType.attendanceAbsenceWarning,
      NotificationType.attendanceReport,
      
      // Face recognition
      NotificationType.faceVerificationRequest,
      NotificationType.faceVerificationSuccess,
      NotificationType.faceVerificationFailed,
      
      // System
      NotificationType.systemAnnouncement,
      NotificationType.systemMaintenance,
      NotificationType.passwordReset,
      NotificationType.accountLocked,
      
      // Employee
      NotificationType.employeeBirthday,
      NotificationType.employeeAnniversary,
      NotificationType.payrollAvailable,
    ];

    return notificationTypes.map((type) {
      final preference = state.preferences
          .where((p) => p.notificationType == type)
          .firstOrNull;

      return _buildNotificationTypeCard(type, preference, l10n);
    }).toList();
  }

  Widget _buildNotificationTypeCard(
    NotificationType type,
    dynamic preference,
    dynamic l10n,
  ) {
    final emailEnabled = preference?.emailEnabled ?? true;
    final pushEnabled = preference?.pushEnabled ?? true;
    final smsEnabled = preference?.smsEnabled ?? false;
    final inAppEnabled = preference?.inAppEnabled ?? true;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(
          _getIconForType(type),
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(_getTitleForType(type, l10n)),
        subtitle: Text(_getSubtitleForType(type, l10n)),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                _buildChannelSwitch(
                  l10n.emailNotifications,
                  Icons.email,
                  emailEnabled,
                  (value) => ref
                      .read(notificationPreferenceControllerProvider.notifier)
                      .toggleEmail(widget.employeeId, type, value),
                  l10n,
                ),
                _buildChannelSwitch(
                  l10n.pushNotifications,
                  Icons.notifications,
                  pushEnabled,
                  (value) => ref
                      .read(notificationPreferenceControllerProvider.notifier)
                      .togglePush(widget.employeeId, type, value),
                  l10n,
                ),
                _buildChannelSwitch(
                  l10n.smsNotifications,
                  Icons.sms,
                  smsEnabled,
                  (value) => ref
                      .read(notificationPreferenceControllerProvider.notifier)
                      .toggleSms(widget.employeeId, type, value),
                  l10n,
                ),
                _buildChannelSwitch(
                  l10n.inAppNotifications,
                  Icons.app_settings_alt,
                  inAppEnabled,
                  (value) => ref
                      .read(notificationPreferenceControllerProvider.notifier)
                      .toggleInApp(widget.employeeId, type, value),
                  l10n,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelSwitch(
    String title,
    IconData icon,
    bool value,
    Future<void> Function(bool) onChanged,
    dynamic l10n,
  ) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: Icon(icon, size: 20),
      title: Text(title),
      value: value,
      onChanged: (newValue) async {
        try {
          await onChanged(newValue);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.preferenceUpdated),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${l10n.failedToUpdate}: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
    );
  }

  Widget _buildGlobalSettingsCard(NotificationPreferenceState state, dynamic l10n) {
    final allPreference = state.preferences
        .where((p) => p.notificationType == NotificationType.all)
        .firstOrNull;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.do_not_disturb),
                const SizedBox(width: 12),
                Text(
                  l10n.doNotDisturb,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.doNotDisturbDesc,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTimeField(
                    l10n.startTime,
                    allPreference?.doNotDisturbStart,
                    (time) => _updateDoNotDisturb(
                      time,
                      allPreference?.doNotDisturbEnd,
                      l10n,
                    ),
                    l10n,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimeField(
                    l10n.endTime,
                    allPreference?.doNotDisturbEnd,
                    (time) => _updateDoNotDisturb(
                      allPreference?.doNotDisturbStart,
                      time,
                      l10n,
                    ),
                    l10n,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField(
    String label,
    String? currentValue,
    Function(String?) onChanged,
    dynamic l10n,
  ) {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: _parseTimeOfDay(currentValue),
        );
        if (time != null) {
          final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
          onChanged(timeString);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: currentValue != null
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => onChanged(null),
                )
              : null,
        ),
        child: Text(
          currentValue ?? l10n.notSet,
          style: TextStyle(
            color: currentValue != null ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  TimeOfDay _parseTimeOfDay(String? timeString) {
    if (timeString == null) return TimeOfDay.now();
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      // Leave related
      case NotificationType.leaveRequestSubmitted:
        return Icons.request_page;
      case NotificationType.leaveRequestApproved:
        return Icons.check_circle;
      case NotificationType.leaveRequestRejected:
        return Icons.cancel;
      case NotificationType.leaveRequestUpdated:
        return Icons.edit;
      case NotificationType.leaveBalanceLow:
        return Icons.warning;
      
      // Attendance related
      case NotificationType.attendanceReminder:
        return Icons.alarm;
      case NotificationType.attendanceLateWarning:
        return Icons.access_time;
      case NotificationType.attendanceAbsenceWarning:
        return Icons.event_busy;
      case NotificationType.attendanceReport:
        return Icons.assessment;
      
      // Face recognition
      case NotificationType.faceVerificationRequest:
        return Icons.face;
      case NotificationType.faceVerificationSuccess:
        return Icons.verified_user;
      case NotificationType.faceVerificationFailed:
        return Icons.error;
      
      // System
      case NotificationType.systemAnnouncement:
        return Icons.announcement;
      case NotificationType.systemMaintenance:
        return Icons.build;
      case NotificationType.passwordReset:
        return Icons.lock_reset;
      case NotificationType.accountLocked:
        return Icons.lock;
      
      // Employee
      case NotificationType.employeeBirthday:
        return Icons.cake;
      case NotificationType.employeeAnniversary:
        return Icons.celebration;
      case NotificationType.payrollAvailable:
        return Icons.attach_money;
      
      case NotificationType.all:
        return Icons.notifications_active;
    }
  }

  String _getTitleForType(NotificationType type, dynamic l10n) {
    switch (type) {
      // Leave related
      case NotificationType.leaveRequestSubmitted:
        return 'Leave Request Submitted';
      case NotificationType.leaveRequestApproved:
        return 'Leave Request Approved';
      case NotificationType.leaveRequestRejected:
        return 'Leave Request Rejected';
      case NotificationType.leaveRequestUpdated:
        return 'Leave Request Updated';
      case NotificationType.leaveBalanceLow:
        return 'Leave Balance Low';
      
      // Attendance related
      case NotificationType.attendanceReminder:
        return 'Attendance Reminder';
      case NotificationType.attendanceLateWarning:
        return 'Late Warning';
      case NotificationType.attendanceAbsenceWarning:
        return 'Absence Warning';
      case NotificationType.attendanceReport:
        return 'Attendance Report';
      
      // Face recognition
      case NotificationType.faceVerificationRequest:
        return 'Face Verification Request';
      case NotificationType.faceVerificationSuccess:
        return 'Face Verification Success';
      case NotificationType.faceVerificationFailed:
        return 'Face Verification Failed';
      
      // System
      case NotificationType.systemAnnouncement:
        return 'System Announcement';
      case NotificationType.systemMaintenance:
        return 'System Maintenance';
      case NotificationType.passwordReset:
        return 'Password Reset';
      case NotificationType.accountLocked:
        return 'Account Locked';
      
      // Employee
      case NotificationType.employeeBirthday:
        return 'Employee Birthday';
      case NotificationType.employeeAnniversary:
        return 'Employee Anniversary';
      case NotificationType.payrollAvailable:
        return 'Payroll Available';
      
      case NotificationType.all:
        return l10n.allNotifications;
    }
  }

  String _getSubtitleForType(NotificationType type, dynamic l10n) {
    switch (type) {
      // Leave related
      case NotificationType.leaveRequestSubmitted:
        return 'When a leave request is submitted';
      case NotificationType.leaveRequestApproved:
        return 'When your leave request is approved';
      case NotificationType.leaveRequestRejected:
        return 'When your leave request is rejected';
      case NotificationType.leaveRequestUpdated:
        return 'When a leave request is updated';
      case NotificationType.leaveBalanceLow:
        return 'When your leave balance is running low';
      
      // Attendance related
      case NotificationType.attendanceReminder:
        return 'Reminders for attendance check-in/out';
      case NotificationType.attendanceLateWarning:
        return 'When you are late for work';
      case NotificationType.attendanceAbsenceWarning:
        return 'When you have an unexcused absence';
      case NotificationType.attendanceReport:
        return 'Monthly attendance reports';
      
      // Face recognition
      case NotificationType.faceVerificationRequest:
        return 'When face verification is requested';
      case NotificationType.faceVerificationSuccess:
        return 'When face verification succeeds';
      case NotificationType.faceVerificationFailed:
        return 'When face verification fails';
      
      // System
      case NotificationType.systemAnnouncement:
        return 'Important system announcements';
      case NotificationType.systemMaintenance:
        return 'Scheduled system maintenance notices';
      case NotificationType.passwordReset:
        return 'Password reset confirmations';
      case NotificationType.accountLocked:
        return 'When your account is locked';
      
      // Employee
      case NotificationType.employeeBirthday:
        return 'Birthday wishes and greetings';
      case NotificationType.employeeAnniversary:
        return 'Work anniversary celebrations';
      case NotificationType.payrollAvailable:
        return 'When payroll is ready';
      
      case NotificationType.all:
        return l10n.allNotificationsDesc;
    }
  }

  Future<void> _updateDoNotDisturb(String? start, String? end, dynamic l10n) async {
    try {
      await ref
          .read(notificationPreferenceControllerProvider.notifier)
          .setDoNotDisturb(
            widget.employeeId,
            NotificationType.all,
            start,
            end,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.dndUpdated),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.failedToUpdate}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
