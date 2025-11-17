# Notification Preferences - Quick Start Guide

## 🚀 Quick Setup

The notification preferences feature is ready to use! Follow these simple steps to integrate it into your app.

## 📋 Step 1: Add to Navigation

Add a route to your settings screen or menu:

```dart
import 'package:flutter_application_1/features/notification_preferences/notification_preferences.dart';

// In your settings screen or menu
ListTile(
  leading: Icon(Icons.notifications_active),
  title: Text('Notification Preferences'),
  subtitle: Text('Manage your notification settings'),
  trailing: Icon(Icons.chevron_right),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationPreferencesScreen(
          employeeId: currentUser.employeeId, // Replace with actual employee ID
        ),
      ),
    );
  },
)
```

## 📋 Step 2: Get Employee ID

Make sure you have access to the current user's employee ID. This is typically available from:

```dart
// From auth state
final authState = ref.watch(authStateProvider);
final employeeId = authState.user?.employeeId;

// Or from stored user data
final currentUser = await UserPreferences.getCurrentUser();
final employeeId = currentUser.employeeId;
```

## 📋 Step 3: That's It!

The feature is fully self-contained and ready to use. The screen will:
- ✅ Automatically load preferences on open
- ✅ Display all notification types
- ✅ Allow toggling each channel (Email, Push, SMS, In-App)
- ✅ Support Do Not Disturb scheduling
- ✅ Show loading, error, and success states
- ✅ Support pull-to-refresh

## 🎨 Usage Examples

### Basic Navigation
```dart
// Simple navigation
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => NotificationPreferencesScreen(
      employeeId: 123,
    ),
  ),
);
```

### With GoRouter
```dart
context.push('/notification-preferences', extra: employeeId);
```

### Programmatic Updates
```dart
// Access the controller
final controller = ref.read(notificationPreferenceControllerProvider.notifier);

// Load preferences
await controller.loadPreferences(employeeId);

// Toggle email for leave approvals
await controller.toggleEmail(
  employeeId, 
  NotificationType.leaveApproval, 
  true,
);

// Set Do Not Disturb (10 PM to 7 AM)
await controller.setDoNotDisturb(
  employeeId,
  NotificationType.all,
  "22:00",
  "07:00",
);
```

## 🔌 Backend Requirements

Ensure your backend implements:

### 1. GET Preferences Endpoint
```
GET /api/v1/notification/notification-preferences?employeeId={id}
```

### 2. PUT Update Preference Endpoint
```
PUT /api/v1/notification/notification-preferences
Content-Type: application/json

{
  "employeeId": 123,
  "notificationType": "LEAVE_APPROVAL",
  "emailEnabled": true,
  "pushEnabled": false
}
```

## 🎯 Notification Types

The following types are available:
- `LEAVE_APPROVAL` - Leave approved
- `LEAVE_REJECTION` - Leave rejected
- `LEAVE_REQUEST` - New leave request
- `LEAVE_MODIFIED` - Leave modified
- `LEAVE_CANCELLED` - Leave cancelled
- `ATTENDANCE_REMINDER` - Attendance reminders
- `SCHEDULE_UPDATED` - Schedule changes
- `SYSTEM_ANNOUNCEMENT` - System messages
- `ALL` - Global settings

## 📱 UI Features

### Per-Type Settings
Each notification type has expandable settings for:
- 📧 Email notifications
- 📲 Push notifications
- 💬 SMS notifications
- 📱 In-app notifications

### Global Settings
- 🌙 Do Not Disturb period
- 🔄 Pull to refresh
- ⚠️ Error handling with retry

## 🎨 Customization

### Change Colors
Edit the theme in the screen widget or use your app's theme:

```dart
AppBar(
  backgroundColor: Theme.of(context).colorScheme.primary,
  // ...
)
```

### Add Custom Icons
Modify `_getIconForType()` method in the screen:

```dart
IconData _getIconForType(NotificationType type) {
  switch (type) {
    case NotificationType.leaveApproval:
      return Icons.check_circle; // Change icon here
    // ...
  }
}
```

### Localization
Replace hardcoded strings with localized versions:

```dart
Text('Notification Settings') 
// Replace with:
Text(AppLocalizations.of(context)!.notificationSettings)
```

## 🐛 Troubleshooting

### Issue: Preferences not loading
**Solution:** Check:
1. Employee ID is correct
2. User is authenticated
3. Backend API is accessible
4. Network connection is available

### Issue: Updates not saving
**Solution:** Check:
1. API endpoint returns 200/201
2. Request payload is correct
3. Employee ID matches logged-in user

### Issue: Do Not Disturb not working
**Solution:** 
- Time format must be "HH:mm" (e.g., "22:00", "07:00")
- Backend must validate and store the times correctly

## 📚 Learn More

See the full [README.md](README.md) for:
- Complete API documentation
- Architecture details
- Advanced usage
- State management
- Error handling

## ✨ Tips

1. **Cache preferences** - The controller keeps state, so preferences persist during the session
2. **Refresh on focus** - Consider refreshing when the screen gains focus
3. **Validate changes** - Backend should validate preference changes
4. **User feedback** - The UI shows snackbars for success/error

## 🎉 You're Done!

The notification preferences feature is now integrated into your app. Users can now customize their notification settings per type and channel!
