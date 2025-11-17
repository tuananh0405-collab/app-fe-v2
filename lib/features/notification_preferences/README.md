# Notification Preferences Feature

## 📋 Overview

This feature allows users to manage their notification preferences across different notification types and channels (Email, Push, SMS, In-App).

## 🏗️ Architecture

This feature follows Clean Architecture with the following layers:

```
lib/features/notification_preferences/
├── domain/                              # Business Logic Layer
│   ├── models/
│   │   ├── notification_type.dart       # Notification type enum
│   │   └── notification_preference.dart # Notification preference entity
│   ├── repositories/
│   │   └── notification_preference_repository.dart
│   └── usecases/
│       ├── get_notification_preferences_usecase.dart
│       └── update_notification_preference_usecase.dart
├── data/                                # Data Layer
│   ├── models/
│   │   ├── notification_preference_model.dart
│   │   └── update_notification_preference_dto.dart
│   ├── datasources/
│   │   └── notification_preference_remote_datasource.dart
│   └── repositories/
│       └── notification_preference_repository_impl.dart
├── presentation/                        # Presentation Layer
│   ├── state/
│   │   └── notification_preference_state.dart
│   ├── controllers/
│   │   └── notification_preference_controller.dart
│   └── pages/
│       └── notification_preferences_screen.dart
├── providers/
│   └── notification_preference_providers.dart
└── notification_preferences.dart        # Barrel export file
```

## 🔌 Backend API

### Get Notification Preferences
```
GET /api/v1/notification/notification-preferences?employeeId={employeeId}

Response:
[
  {
    "id": 1,
    "employeeId": 123,
    "notificationType": "LEAVE_APPROVAL",
    "emailEnabled": true,
    "pushEnabled": true,
    "smsEnabled": false,
    "inAppEnabled": true,
    "doNotDisturbStart": null,
    "doNotDisturbEnd": null,
    "createdAt": "2025-11-17T10:00:00Z",
    "updatedAt": "2025-11-17T10:00:00Z"
  }
]
```

### Update Notification Preference
```
PUT /api/v1/notification/notification-preferences
Content-Type: application/json

{
  "employeeId": 123,
  "notificationType": "LEAVE_APPROVAL",
  "emailEnabled": true,
  "pushEnabled": false,
  "smsEnabled": false,
  "inAppEnabled": true,
  "doNotDisturbStart": "22:00",
  "doNotDisturbEnd": "07:00"
}

Response:
{
  "id": 1,
  "employeeId": 123,
  "notificationType": "LEAVE_APPROVAL",
  "emailEnabled": true,
  "pushEnabled": false,
  "smsEnabled": false,
  "inAppEnabled": true,
  "doNotDisturbStart": "22:00",
  "doNotDisturbEnd": "07:00",
  "createdAt": "2025-11-17T10:00:00Z",
  "updatedAt": "2025-11-17T11:00:00Z"
}
```

## 📊 Notification Types

The following notification types are supported:

- `LEAVE_APPROVAL` - When a leave request is approved
- `LEAVE_REJECTION` - When a leave request is rejected
- `LEAVE_REQUEST` - When someone submits a leave request
- `LEAVE_MODIFIED` - When a leave request is modified
- `LEAVE_CANCELLED` - When a leave is cancelled
- `ATTENDANCE_REMINDER` - Reminders for attendance
- `SCHEDULE_UPDATED` - When schedule is updated
- `SYSTEM_ANNOUNCEMENT` - Important system announcements
- `ALL` - Global settings for all notifications

## 🎨 UI Features

### Notification Preferences Screen
- List of all notification types with expandable cards
- Toggle switches for each notification channel (Email, Push, SMS, In-App)
- Do Not Disturb time period picker
- Pull to refresh
- Error handling with retry
- Success/error snackbar messages

### Per-Notification Type Settings
Each notification type can be configured independently with:
- Email notifications (on/off)
- Push notifications (on/off)
- SMS notifications (on/off)
- In-App notifications (on/off)

### Global Settings
- Do Not Disturb period (start time - end time)
- Applies to ALL notification type

## 🚀 Usage

### 1. Import the feature
```dart
import 'package:flutter_application_1/features/notification_preferences/notification_preferences.dart';
```

### 2. Navigate to preferences screen
```dart
// Pass the employee ID
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => NotificationPreferencesScreen(
      employeeId: currentEmployeeId,
    ),
  ),
);
```

### 3. Access controller directly (optional)
```dart
final controller = ref.read(notificationPreferenceControllerProvider.notifier);

// Load preferences
await controller.loadPreferences(employeeId);

// Toggle specific channel
await controller.toggleEmail(employeeId, NotificationType.leaveApproval, true);
await controller.togglePush(employeeId, NotificationType.leaveApproval, false);

// Set Do Not Disturb
await controller.setDoNotDisturb(employeeId, NotificationType.all, "22:00", "07:00");
```

### 4. Watch state changes
```dart
final state = ref.watch(notificationPreferenceControllerProvider);

if (state.status == NotificationPreferenceStatus.loading) {
  // Show loading
}

if (state.status == NotificationPreferenceStatus.error) {
  // Show error: state.errorMessage
}

// Access preferences
for (var pref in state.preferences) {
  print('${pref.notificationType}: Email=${pref.emailEnabled}');
}
```

## 🔧 Controller Methods

### `loadPreferences(int employeeId)`
Loads all notification preferences for an employee.

### `updatePreference({...})`
Updates a specific notification preference with the provided parameters.

### `toggleEmail(int employeeId, NotificationType type, bool enabled)`
Toggles email notifications for a specific notification type.

### `togglePush(int employeeId, NotificationType type, bool enabled)`
Toggles push notifications for a specific notification type.

### `toggleSms(int employeeId, NotificationType type, bool enabled)`
Toggles SMS notifications for a specific notification type.

### `toggleInApp(int employeeId, NotificationType type, bool enabled)`
Toggles in-app notifications for a specific notification type.

### `setDoNotDisturb(int employeeId, NotificationType type, String? start, String? end)`
Sets the Do Not Disturb period for a notification type. Use `NotificationType.all` for global DND.

## 📝 State Management

The feature uses Riverpod for state management with the following state:

```dart
class NotificationPreferenceState {
  final NotificationPreferenceStatus status;  // initial, loading, success, error
  final List<NotificationPreference> preferences;
  final String? errorMessage;
  final bool isUpdating;
}
```

## 🐛 Error Handling

- Network errors are caught and displayed in the UI
- Failed updates show error snackbars
- Retry button available on error state
- Pull to refresh for manual retry

## 🔐 Authentication

All API calls require authentication. Make sure the user is logged in and the JWT token is included in the Dio instance headers.

## ⚙️ Integration Example

Add navigation from settings screen:

```dart
ListTile(
  leading: Icon(Icons.notifications_active),
  title: Text('Notification Preferences'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationPreferencesScreen(
          employeeId: currentUser.employeeId,
        ),
      ),
    );
  },
),
```

## 📚 Dependencies

This feature uses:
- `flutter_riverpod` - State management
- `dio` - HTTP client
- Material Design widgets

## 🔄 Future Enhancements

Potential improvements:
- Batch update multiple preferences
- Preview notification samples
- Notification history/logs
- Advanced scheduling (weekdays, weekends)
- Notification sound/vibration settings
- Priority-based filtering
