# 🔔 Push Notification Implementation Summary

## ✅ Đã hoàn thành

### 1. **Dependencies** (pubspec.yaml)
- ✅ `firebase_core: ^3.8.1` - Firebase core
- ✅ `firebase_messaging: ^15.1.5` - FCM cho push notifications
- ✅ `flutter_local_notifications: ^18.0.1` - Local notifications

### 2. **Core Models** 
- ✅ `lib/core/models/push_token_model.dart` - Data models với Freezed
  - `RegisterPushTokenDto` - DTO để đăng ký token
  - `UnregisterPushTokenDto` - DTO để hủy đăng ký token
  - `PushTokenResponse` - Response từ API
  - `Platform` enum (ios, android, web)

### 3. **Services**
- ✅ `lib/core/services/push_notification_service.dart` - FCM service
  - Lấy FCM token
  - Handle foreground/background notifications
  - Subscribe/unsubscribe topics
  - Request permissions

- ✅ `lib/core/services/push_notification_manager.dart` - Manager
  - Kết nối service với API
  - Auto đăng ký token với backend
  - Unregister token khi cần

### 4. **Network Layer**
- ✅ `lib/core/network/push_notification_api.dart` - API calls
  - `registerPushToken()` - POST /notification/push-tokens/register
  - `unregisterPushToken()` - POST /notification/push-tokens/unregister

### 5. **Dependency Injection**
- ✅ Updated `lib/core/di/injection_container.dart`
  - Registered `PushNotificationService`
  - Registered `PushNotificationApi`
  - Registered `PushNotificationManager`

### 6. **Main App**
- ✅ Updated `lib/main.dart`
  - Initialize Firebase
  - Initialize push notifications
  - Setup callbacks cho notification tap và foreground messages

### 7. **Android Configuration**
- ✅ `android/app/build.gradle.kts` - Added Google Services plugin
- ✅ `android/build.gradle.kts` - Added classpath
- ✅ `android/app/src/main/AndroidManifest.xml`
  - Added permissions (POST_NOTIFICATIONS, WAKE_LOCK)
  - Added FCM service
  - Added notification metadata

### 8. **Documentation**
- ✅ `PUSH_NOTIFICATION_QUICK_START.md` - Quick start guide
- ✅ `PUSH_NOTIFICATION_SETUP.md` - Detailed setup guide
- ✅ `lib/core/examples/logout_example.dart` - Code examples

## 📋 Những gì bạn cần làm

### 🔴 BẮT BUỘC

#### 1. Setup Firebase (5 phút)
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase (chọn project và platforms)
flutterfire configure
```

Lệnh này sẽ:
- Generate `lib/firebase_options.dart` với config thật (thay thế placeholder)
- Tạo/download `android/app/google-services.json`
- Tạo/download `ios/Runner/GoogleService-Info.plist` (nếu chọn iOS)

#### 2. Run app
```bash
flutter pub get
flutter run
```

#### 3. Verify
Check console log phải thấy:
```
FCM Token: <token>
Device ID: <device-id>
Push token registered successfully: <id>
```

### 🟡 RECOMMENDED

#### 4. Thêm unregister vào logout
Xem file `lib/core/examples/logout_example.dart` để biết cách implement.

Cơ bản:
```dart
// Trong logout function
final pushManager = di.sl<PushNotificationManager>();
await pushManager.unregisterPushToken();
```

#### 5. Customize notification handling
Trong `main.dart`, bạn có thể customize callbacks:

```dart
onNotificationTapped: (message) {
  // Navigate based on notification data
  final type = message.data['type'];
  if (type == 'leave') {
    context.go('/leave/${message.data['id']}');
  } else if (type == 'announcement') {
    context.go('/announcements/${message.data['id']}');
  }
},
```

## 🧪 Testing

### Test 1: Từ Firebase Console
1. Firebase Console → Cloud Messaging
2. "Send your first message"
3. Copy FCM token từ debug console
4. Send test message

### Test 2: Từ Backend
Backend gửi notification qua FCM Admin SDK:
```javascript
admin.messaging().send({
  token: 'user-fcm-token',
  notification: {
    title: 'Test',
    body: 'Hello from backend'
  },
  data: {
    type: 'test',
    id: '123'
  }
});
```

## 📁 File Structure

```
lib/
├── core/
│   ├── models/
│   │   ├── push_token_model.dart
│   │   ├── push_token_model.freezed.dart    [generated]
│   │   └── push_token_model.g.dart          [generated]
│   ├── network/
│   │   └── push_notification_api.dart
│   ├── services/
│   │   ├── push_notification_service.dart
│   │   └── push_notification_manager.dart
│   ├── di/
│   │   └── injection_container.dart         [updated]
│   └── examples/
│       └── logout_example.dart
├── firebase_options.dart                     [MUST generate with flutterfire]
└── main.dart                                 [updated]

android/
├── build.gradle.kts                          [updated]
└── app/
    ├── build.gradle.kts                      [updated]
    ├── google-services.json                  [MUST generate with flutterfire]
    └── src/main/AndroidManifest.xml          [updated]
```

## 🔄 Flow Diagram

```
App Start
   ↓
Initialize Firebase
   ↓
Initialize PushNotificationManager
   ↓
PushNotificationService.initialize()
   ↓
Request Permission → Get FCM Token → Get Device ID
   ↓
onTokenReceived callback
   ↓
Call Backend API: POST /notification/push-tokens/register
   {
     deviceId: "xxx",
     token: "fcm-token",
     platform: "android"
   }
   ↓
Backend saves token to database
   ↓
Backend can now send push notifications to this device!
```

## 🎯 Backend API Integration

### Register Token (Auto-called on app start)
```http
POST http://3.27.15.166:32527/api/v1/notification/push-tokens/register
Authorization: Bearer <user-token>
Content-Type: application/json

{
  "deviceId": "android_id or ios_vendor_id",
  "token": "fcm_token_from_firebase",
  "platform": "android"
}

Response: 200 OK
{
  "id": 1,
  "employeeId": 123,
  "deviceId": "xxx",
  "token": "yyy",
  "platform": "android",
  "isActive": true,
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

### Unregister Token (Call on logout)
```http
POST http://3.27.15.166:32527/api/v1/notification/push-tokens/unregister
Authorization: Bearer <user-token>
Content-Type: application/json

{
  "deviceId": "xxx",
  "token": "yyy"
}

Response: 204 No Content
```

## ⚠️ Important Notes

1. **Firebase Options**: File `lib/firebase_options.dart` hiện tại là placeholder. PHẢI chạy `flutterfire configure` để generate file thật.

2. **Auto-register**: Token tự động được đăng ký với backend khi:
   - App khởi động lần đầu
   - User đã login
   - FCM token được refresh

3. **Manual register**: Nếu cần đăng ký lại manually:
   ```dart
   await di.sl<PushNotificationManager>().registerPushToken();
   ```

4. **Logout**: PHẢI unregister token khi logout để tránh gửi notification đến user đã logout:
   ```dart
   await di.sl<PushNotificationManager>().unregisterPushToken();
   ```

5. **Platform Detection**: Platform được tự động detect (android, ios, web) dựa vào `Platform.isXXX`.

6. **Device ID**: 
   - Android: Android ID
   - iOS: identifierForVendor

## 🚨 Troubleshooting

| Problem | Solution |
|---------|----------|
| Firebase not initialized | Run `flutterfire configure` |
| google-services.json not found | Run `flutterfire configure` |
| Permission denied | Check AndroidManifest.xml has POST_NOTIFICATIONS |
| Token not received | Check Firebase project settings, check internet |
| Build error | `flutter clean && flutter pub get && flutter run` |

## 📚 References

- [Firebase Console](https://console.firebase.google.com/)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [FCM Documentation](https://firebase.google.com/docs/cloud-messaging)

---

**Status**: ✅ Implementation complete - Ready for Firebase configuration

**Next Step**: Run `flutterfire configure` để bắt đầu!
