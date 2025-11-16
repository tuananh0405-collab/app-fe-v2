# Push Notification - Quick Start Guide

## 📋 Tổng quan
Tính năng push notification đã được implement sẵn. App sẽ:
1. Tự động lấy FCM token khi khởi động
2. Tự động đăng ký token với Backend API
3. Nhận và hiển thị push notifications từ Backend

## 🚀 Setup nhanh

### Bước 1: Setup Firebase Project

#### 1.1. Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

#### 1.2. Chạy lệnh cấu hình (quan trọng!)
```bash
flutterfire configure
```

Lệnh này sẽ:
- Yêu cầu bạn login vào Google account
- Cho phép chọn hoặc tạo Firebase project
- Tự động tạo file `lib/firebase_options.dart` với config đúng
- Download và add `google-services.json` (Android) và `GoogleService-Info.plist` (iOS)

#### 1.3. Chọn platforms
Khi chạy `flutterfire configure`, chọn:
- ✅ android
- ✅ ios (nếu cần)

### Bước 2: Run app
```bash
flutter pub get
flutter run
```

**Xong!** App sẽ tự động:
- Khởi tạo Firebase
- Request notification permission
- Lấy FCM token
- Gọi API đăng ký token với Backend

## 📱 Testing

### 1. Xem FCM Token trong console
Khi app chạy, xem debug console sẽ thấy:
```
FCM Token: <your-fcm-token>
Device ID: <device-id>
Push token registered successfully: <id>
```

### 2. Test từ Firebase Console
1. Vào [Firebase Console](https://console.firebase.google.com/)
2. Chọn project của bạn
3. Cloud Messaging → Send your first message
4. Nhập title, body
5. Send test message → paste FCM token từ console
6. Gửi!

### 3. Test từ Backend
Backend có thể gửi notification qua FCM Admin SDK với token đã đăng ký.

## 🔧 Backend Integration

### API Endpoints đã được integrate:

#### 1. Register Push Token (tự động gọi khi app start)
```
POST http://3.27.15.166:32527/api/v1/notification/push-tokens/register
Headers: Authorization: Bearer <token>
Body:
{
  "deviceId": "unique-device-id",
  "token": "fcm-token",
  "platform": "android" // hoặc "ios"
}
```

#### 2. Unregister Push Token (gọi khi logout)
```dart
// Trong logout logic
final pushManager = di.sl<PushNotificationManager>();
await pushManager.unregisterPushToken();
```

## 📂 Files đã được tạo

```
lib/
├── core/
│   ├── models/
│   │   └── push_token_model.dart          # Data models + generated files
│   ├── network/
│   │   └── push_notification_api.dart     # API calls
│   ├── services/
│   │   ├── push_notification_service.dart  # FCM service
│   │   └── push_notification_manager.dart  # Manager
│   └── di/
│       └── injection_container.dart        # Updated với push services
├── firebase_options.dart                   # PLACEHOLDER - sẽ được generate
└── main.dart                               # Updated để init push notifications
```

## ⚠️ Lưu ý quan trọng

### File `firebase_options.dart`
File hiện tại là **PLACEHOLDER**. Bạn **PHẢI chạy** `flutterfire configure` để generate file thật với config đúng của Firebase project.

### Android Permissions
Đã được thêm vào `AndroidManifest.xml`:
- `POST_NOTIFICATIONS` - Để hiển thị notifications
- `WAKE_LOCK` - Để wake device khi nhận notification
- Firebase Messaging Service

### iOS Setup (nếu cần)
Cần thêm trong `ios/Runner/AppDelegate.swift`:
```swift
import FirebaseCore
import FirebaseMessaging

// Trong didFinishLaunchingWithOptions
FirebaseApp.configure()
application.registerForRemoteNotifications()
```

## 🎯 Sử dụng trong code

### 1. Subscribe to topics (optional)
```dart
final pushManager = di.sl<PushNotificationManager>();
await pushManager.subscribeToTopic('all_employees');
await pushManager.subscribeToTopic('important_updates');
```

### 2. Handle notification tap
Đã được setup trong `main.dart`:
```dart
onNotificationTapped: (message) {
  // Navigate dựa vào data
  final type = message.data['type'];
  final id = message.data['id'];
  
  if (type == 'leave_request') {
    GoRouter.of(context).go('/leave-requests/$id');
  }
}
```

### 3. Handle foreground notifications
```dart
onForegroundMessage: (message) {
  // Show snackbar, update UI, etc.
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message.notification?.title ?? '')),
  );
}
```

### 4. Unregister khi logout
```dart
// Trong logout function
await di.sl<PushNotificationManager>().unregisterPushToken();
```

## 🐛 Troubleshooting

### "Firebase not configured" error
➡️ Chạy `flutterfire configure`

### Không nhận được notifications
1. Check permission đã được grant chưa
2. Check FCM token đã được log ra console chưa
3. Check Backend có gửi notification đúng token không
4. Check app có đang chạy foreground/background

### Build error với Google Services
```bash
flutter clean
flutter pub get
flutter run
```

## 📖 Backend Requirements

Backend cần implement logic gửi FCM notifications. Ví dụ với Firebase Admin SDK (Node.js):

```javascript
import admin from 'firebase-admin';

// Send notification
await admin.messaging().send({
  token: userPushToken.token, // từ DB
  notification: {
    title: 'Leave Request Approved',
    body: 'Your leave request has been approved'
  },
  data: {
    type: 'leave_request',
    id: '123',
    action: 'approved'
  },
  android: {
    priority: 'high',
  },
  apns: {
    headers: {
      'apns-priority': '10',
    },
  },
});
```

## ✅ Checklist

- [ ] Chạy `flutterfire configure` để setup Firebase
- [ ] File `firebase_options.dart` đã được generate (không còn placeholder)
- [ ] File `google-services.json` có trong `android/app/`
- [ ] Chạy `flutter pub get`
- [ ] Chạy app và check console có FCM token
- [ ] Test gửi notification từ Firebase Console
- [ ] Thêm unregister vào logout logic

---

**Cần hỗ trợ thêm?** Xem file `PUSH_NOTIFICATION_SETUP.md` cho chi tiết đầy đủ hơn.
