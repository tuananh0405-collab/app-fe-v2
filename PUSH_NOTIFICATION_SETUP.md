# Push Notification Setup Guide

## Tổng quan
Tính năng push notification cho phép app nhận thông báo ngay cả khi người dùng không mở app. Backend cung cấp 2 API để đăng ký và hủy đăng ký push token.

## Yêu cầu
- Firebase project (cho FCM - Firebase Cloud Messaging)
- FlutterFire CLI
- Android: minSdkVersion 21+
- iOS: iOS 10.0+

## Cài đặt

### 1. Setup Firebase Project

#### Bước 1: Tạo Firebase Project
1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Tạo project mới hoặc sử dụng project có sẵn
3. Thêm Android app và/hoặc iOS app vào project

#### Bước 2: Cài đặt FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

#### Bước 3: Cấu hình Firebase cho Flutter project
```bash
flutterfire configure
```

Lệnh này sẽ:
- Tự động tạo file `lib/firebase_options.dart`
- Cấu hình Firebase cho các platforms
- Download các file cấu hình cần thiết (google-services.json, GoogleService-Info.plist)

### 2. Cấu hình Android

#### File: `android/app/build.gradle.kts`
Thêm plugin Google Services vào cuối file:

```kotlin
plugins {
    // ... existing plugins
    id("com.google.gms.google-services")
}
```

#### File: `android/build.gradle.kts`
Thêm classpath vào dependencies:

```kotlin
buildscript {
    dependencies {
        // ... existing dependencies
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

#### File: `android/app/src/main/AndroidManifest.xml`
Thêm các permission và services:

```xml
<manifest>
    <!-- Permissions for push notifications -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    <uses-permission android:name="android.permission.WAKE_LOCK"/>

    <application>
        <!-- Firebase Messaging Service -->
        <service
            android:name="com.google.firebase.messaging.FirebaseMessagingService"
            android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT" />
            </intent-filter>
        </service>

        <!-- Notification metadata -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_icon"
            android:resource="@mipmap/ic_launcher" />
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_color"
            android:resource="@color/notification_color" />
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="high_importance_channel" />
    </application>
</manifest>
```

### 3. Cấu hình iOS

#### File: `ios/Runner/AppDelegate.swift`
Thêm import và cấu hình:

```swift
import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { _, _ in }
      )
    } else {
      let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }

    application.registerForRemoteNotifications()

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
  }
}
```

#### File: `ios/Runner/Info.plist`
Thêm permission cho notifications:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

### 4. Install Dependencies

```bash
flutter pub get
```

### 5. Generate Code (cho Freezed models)

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Cách sử dụng

### 1. Khởi tạo (đã tự động trong main.dart)
Push notification đã được tự động khởi tạo trong `main.dart`:

```dart
// Initialize push notifications
final pushNotificationManager = di.sl<PushNotificationManager>();
await pushNotificationManager.initialize(
  onNotificationTapped: (message) {
    // Handle notification tap
    debugPrint('Notification tapped: ${message.data}');
  },
  onForegroundMessage: (message) {
    // Handle foreground message
    debugPrint('Foreground message received: ${message.notification?.title}');
  },
);
```

### 2. Đăng ký Push Token (tự động)
Khi app khởi động, push token sẽ tự động được đăng ký với backend thông qua API:
```
POST http://3.27.15.166:32527/api/v1/notification/push-tokens/register
```

### 3. Hủy đăng ký Push Token (khi logout)
Trong màn hình logout hoặc settings, gọi:

```dart
final pushManager = di.sl<PushNotificationManager>();
await pushManager.unregisterPushToken();
```

### 4. Subscribe/Unsubscribe Topics
Bạn có thể subscribe vào các topics để nhận notifications theo nhóm:

```dart
final pushManager = di.sl<PushNotificationManager>();

// Subscribe to topic
await pushManager.subscribeToTopic('employees');
await pushManager.subscribeToTopic('announcements');

// Unsubscribe from topic
await pushManager.unsubscribeFromTopic('employees');
```

### 5. Handle Notification Tap
Xử lý khi user tap vào notification (đã cấu hình trong main.dart):

```dart
onNotificationTapped: (message) {
  // Navigate based on notification data
  final data = message.data;
  
  if (data['type'] == 'leave_request') {
    // Navigate to leave request detail
    GoRouter.of(context).go('/leave-requests/${data['id']}');
  } else if (data['type'] == 'announcement') {
    // Navigate to announcement
    GoRouter.of(context).go('/announcements/${data['id']}');
  }
}
```

## API Backend

### Register Push Token
**Endpoint:** `POST /api/v1/notification/push-tokens/register`

**Headers:**
- `Authorization: Bearer <token>`
- `Content-Type: application/json`

**Body:**
```json
{
  "deviceId": "unique-device-id",
  "token": "fcm-token-from-firebase",
  "platform": "android" // or "ios"
}
```

**Response:**
```json
{
  "id": 1,
  "employeeId": 123,
  "deviceId": "unique-device-id",
  "token": "fcm-token-from-firebase",
  "platform": "android",
  "isActive": true,
  "lastUsedAt": null,
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

### Unregister Push Token
**Endpoint:** `POST /api/v1/notification/push-tokens/unregister`

**Headers:**
- `Authorization: Bearer <token>`
- `Content-Type: application/json`

**Body:**
```json
{
  "deviceId": "unique-device-id",  // optional
  "token": "fcm-token-from-firebase"  // optional
}
```

**Response:** 204 No Content

## Testing

### Test Push Notification từ Firebase Console

1. Truy cập Firebase Console
2. Vào **Cloud Messaging** > **Send your first message**
3. Nhập title và message
4. Click **Send test message**
5. Nhập FCM token (có thể xem trong debug console khi app chạy)
6. Click **Test**

### Test Push Notification từ Backend

Backend có thể gửi notification bằng Firebase Admin SDK. Format của notification:

```json
{
  "notification": {
    "title": "Leave Request Approved",
    "body": "Your leave request has been approved"
  },
  "data": {
    "type": "leave_request",
    "id": "123",
    "action": "approved"
  },
  "token": "user-fcm-token"
}
```

## Troubleshooting

### Android

1. **Không nhận được notification:**
   - Kiểm tra `google-services.json` đã được thêm vào `android/app/`
   - Kiểm tra permissions trong AndroidManifest.xml
   - Kiểm tra thiết bị có bật notifications cho app

2. **Build error với Google Services:**
   - Chạy `flutter clean`
   - Xóa folder `android/app/build`
   - Chạy lại `flutter pub get`

### iOS

1. **Không nhận được notification:**
   - Kiểm tra `GoogleService-Info.plist` đã được thêm vào project
   - Kiểm tra APNs certificates trong Firebase Console
   - Kiểm tra Background Modes đã được bật trong Xcode

2. **Build error:**
   - Mở project iOS trong Xcode
   - Clean build folder (Cmd+Shift+K)
   - Rebuild project

## Architecture

```
lib/
├── core/
│   ├── models/
│   │   └── push_token_model.dart          # Data models
│   ├── network/
│   │   └── push_notification_api.dart     # API calls
│   ├── services/
│   │   ├── push_notification_service.dart  # Firebase FCM service
│   │   └── push_notification_manager.dart  # Manager (combines service + API)
│   └── di/
│       └── injection_container.dart        # Dependency injection
├── firebase_options.dart                   # Firebase configuration
└── main.dart                               # App entry point
```

## Notes

- Push token được tự động đăng ký khi app khởi động và user đã login
- Push token được tự động refresh khi Firebase generate token mới
- Nên gọi `unregisterPushToken()` khi user logout để tránh gửi notification đến user đã logout
- Device ID được lấy từ Android ID (Android) hoặc identifierForVendor (iOS)
- Platform được tự động detect (ios, android, web)
