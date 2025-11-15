# Localization Structure

## Overview
Localization system được tách thành các service riêng biệt theo từng feature để dễ quản lý và maintain.

## Structure

```
lib/core/localization/
├── app_localizations.dart          # Main aggregator
├── common_localizations.dart       # Common translations (buttons, actions)
├── leave_localizations.dart        # Leave management feature
├── notification_localizations.dart # Notification feature
└── home_localizations.dart         # Home/navigation feature
```

## Usage

### 1. Import AppLocalizations

```dart
import 'package:your_app/core/localization/app_localizations.dart';
```

### 2. Access translations in widget

```dart
@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  
  // Access feature-specific translations
  final common = l10n.common;    // Common translations
  final leave = l10n.leave;      // Leave feature translations
  final notification = l10n.notification;  // Notification translations
  final home = l10n.home;        // Home translations
  
  return Column(
    children: [
      // Common translations
      Text(common.save),      // Save / Lưu
      Text(common.cancel),    // Cancel / Hủy
      Text(common.submit),    // Submit / Gửi
      
      // Leave feature translations
      Text(leave.createLeaveRequest),  // Create Leave Request / Tạo đơn xin nghỉ
      Text(leave.annualLeave),         // Annual Leave / Nghỉ phép năm
      Text(leave.selectDate),          // Select Date / Chọn ngày
      
      // Notification translations
      Text(notification.notifications),  // Notifications / Thông báo
      Text(notification.markAllRead),    // Mark All as Read / Đọc tất cả
      
      // Home translations
      Text(home.profile),  // Profile / Hồ sơ
      Text(home.settings), // Settings / Cài đặt
    ],
  );
}
```

### 3. Language Switching

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_app/core/localization/app_localizations.dart';

// In your widget (using Riverpod)
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current locale
    final currentLocale = ref.watch(localeProvider);
    
    // Switch language
    void switchToVietnamese() {
      ref.read(localeProvider.notifier).state = const Locale('vi');
    }
    
    void switchToEnglish() {
      ref.read(localeProvider.notifier).state = const Locale('en');
    }
    
    return Column(
      children: [
        Text('Current: ${currentLocale.languageCode}'),
        ElevatedButton(
          onPressed: switchToEnglish,
          child: Text('English'),
        ),
        ElevatedButton(
          onPressed: switchToVietnamese,
          child: Text('Tiếng Việt'),
        ),
      ],
    );
  }
}
```

### 4. Using LanguageSwitcher Widget

```dart
import 'package:your_app/core/widgets/language_switcher.dart';

AppBar(
  title: Text('My App'),
  actions: [
    const LanguageSwitcher(), // Automatic language dropdown with flags
    const SizedBox(width: 8),
  ],
)
```

## Adding New Translations

### To Common Translations

Edit `lib/core/localization/common_localizations.dart`:

```dart
static final Map<String, Map<String, String>> _translations = {
  'en': {
    'new_key': 'English Translation',
  },
  'vi': {
    'new_key': 'Bản dịch tiếng Việt',
  },
};

// Add getter
String get newKey => translate('new_key');
```

### To Feature-Specific Translations

Edit the respective file (e.g., `leave_localizations.dart`):

```dart
static final Map<String, Map<String, String>> _translations = {
  'en': {
    'new_leave_feature': 'New Feature',
  },
  'vi': {
    'new_leave_feature': 'Tính năng mới',
  },
};

// Add getter
String get newLeaveFeature => translate('new_leave_feature');
```

### Creating New Feature Localization

1. Create new file: `lib/core/localization/your_feature_localizations.dart`

```dart
import 'package:flutter/material.dart';

class YourFeatureLocalizations {
  final Locale locale;

  YourFeatureLocalizations(this.locale);

  static final Map<String, Map<String, String>> _translations = {
    'en': {
      'feature_key': 'English',
    },
    'vi': {
      'feature_key': 'Tiếng Việt',
    },
  };

  String translate(String key) {
    return _translations[locale.languageCode]?[key] ?? key;
  }

  String get featureKey => translate('feature_key');
}
```

2. Add to `app_localizations.dart`:

```dart
import 'your_feature_localizations.dart';

class AppLocalizations {
  // ... existing code
  late final YourFeatureLocalizations yourFeature;

  AppLocalizations(this.locale) {
    // ... existing code
    yourFeature = YourFeatureLocalizations(locale);
  }
}
```

## Supported Languages

- 🇬🇧 English (`en`)
- 🇻🇳 Tiếng Việt (`vi`)

## Benefits of This Structure

1. **Separation of Concerns**: Each feature has its own translation file
2. **Easy to Maintain**: Find and update translations quickly
3. **Scalable**: Easy to add new features or languages
4. **Type Safe**: All translations are strongly typed with getters
5. **No Runtime Errors**: Missing translations fall back to the key
6. **Clean Code**: Clear organization by feature

## Example: Complete Screen

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/language_switcher.dart';

class MyScreen extends ConsumerWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final common = l10n.common;
    final leave = l10n.leave;

    return Scaffold(
      appBar: AppBar(
        title: Text(leave.createLeaveRequest),
        actions: const [
          LanguageSwitcher(),  // Language switcher with flags
          SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: leave.reason,
                hintText: leave.reasonPlaceholder,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text(common.cancel),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  child: Text(common.submit),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```
