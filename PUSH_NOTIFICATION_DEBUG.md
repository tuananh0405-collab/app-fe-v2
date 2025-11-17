# Push Notification Debug Guide

## ✅ Đã Fix

1. **Added Push Notification Initialization trong main.dart**
   - Push notification manager giờ được initialize khi app start
   - Callbacks đã được setup để handle notifications
   - Token tự động register khi app khởi động (nếu notifications enabled)

2. **Added Detailed Logging**
   - Logs rõ ràng với emoji để dễ trace
   - Background messages: 🌙
   - Foreground messages: 🔔
   - Notification taps: 👆
   - Initialization: 🚀

## 🔍 Cách Debug

### Bước 1: Kiểm tra Initialization
Khi app start, bạn sẽ thấy logs như sau:
```
🚀 ===== INITIALIZING PUSH NOTIFICATIONS =====
📋 Notification permission status: AuthorizationStatus.authorized
✅ User granted notification permission
✅ Local notifications initialized
📱 Device ID: <device_id>
🔑 FCM Token: <fcm_token>
👂 Listening for foreground messages
👂 Listening for notification taps
🎉 ===== PUSH NOTIFICATIONS INITIALIZED SUCCESSFULLY =====
Push token registered successfully: <token_id>
```

### Bước 2: Test Push Notification từ Backend

**Format notification từ BE phải đúng:**

```json
{
  "to": "<fcm_token>",
  "notification": {
    "title": "Test Notification",
    "body": "This is a test message"
  },
  "data": {
    "type": "test",
    "id": "123",
    "custom_field": "value"
  }
}
```

**⚠️ Quan trọng:**
- Phải có cả `notification` object (để hiện notification tự động)
- `data` object là optional nhưng cần thiết nếu muốn handle navigation
- Nếu chỉ gửi `data` mà không có `notification`, phải tự handle việc hiển thị

### Bước 3: Kiểm tra Logs khi nhận Notification

#### Khi App đang chạy (Foreground):
```
🔔 ===== FOREGROUND MESSAGE RECEIVED =====
🔔 Message ID: <message_id>
🔔 Notification Title: Test Notification
🔔 Notification Body: This is a test message
🔔 Data: {type: test, id: 123}
🔔 =======================================
📢 Showing local notification: Test Notification
📬 Foreground message received: <message_id>
📬 Title: Test Notification
📬 Body: This is a test message
📬 Data: {type: test, id: 123}
```

#### Khi App đang ở background:
```
🌙 ===== BACKGROUND MESSAGE RECEIVED =====
🌙 Message ID: <message_id>
🌙 Notification Title: Test Notification
🌙 Notification Body: This is a test message
🌙 Data: {type: test, id: 123}
🌙 ========================================
```

#### Khi tap vào notification:
```
👆 ===== NOTIFICATION TAPPED =====
👆 Message ID: <message_id>
👆 Data: {type: test, id: 123}
👆 ================================
📱 Notification tapped: <message_id>
📱 Title: Test Notification
📱 Body: This is a test message
📱 Data: {type: test, id: 123}
```

## 🐛 Troubleshooting

### Vấn đề 1: Không thấy logs initialization
**Nguyên nhân:** App chưa được rebuild sau khi update code
**Giải pháp:** 
```bash
flutter clean
flutter pub get
flutter run
```

### Vấn đề 2: Token đã register nhưng không nhận notification
**Kiểm tra:**
1. ✅ Notification permission đã granted chưa?
2. ✅ FCM token có đúng không? (check logs)
3. ✅ BE có gửi đúng format không?
4. ✅ App có đang chạy không? (background/foreground/killed)

**Test bằng Firebase Console:**
1. Vào Firebase Console → Cloud Messaging
2. Send test message
3. Paste FCM token từ logs
4. Send

### Vấn đề 3: Notification không hiện khi app foreground
**Nguyên nhân:** Local notification không hoạt động
**Kiểm tra:**
1. Android channel đã được tạo chưa?
2. Permission đã granted chưa?
3. Check logs xem có "📢 Showing local notification" không?

### Vấn đề 4: Notification payload không có data
**Nguyên nhân:** BE chỉ gửi notification object, không có data
**Giải pháp:** Yêu cầu BE thêm data object vào payload

## 📱 Test Cases

### Test 1: App Foreground
1. Mở app
2. Để app ở foreground
3. BE gửi notification
4. **Expected:** 
   - Thấy logs 🔔 trong console
   - Notification hiện ở notification tray
   - Không navigate (chỉ show notification)

### Test 2: App Background
1. Mở app rồi press Home (app vẫn chạy background)
2. BE gửi notification
3. **Expected:**
   - Thấy logs 🌙 trong console (nếu đang debug)
   - Notification hiện ở notification tray
   - Tap notification → app mở lên và thấy logs 👆

### Test 3: App Killed
1. Kill app hoàn toàn (swipe away)
2. BE gửi notification
3. **Expected:**
   - Notification hiện ở notification tray
   - Tap notification → app mở và thấy logs 🎯 "App opened from notification"

### Test 4: Token Registration
1. Mở app lần đầu
2. **Expected:**
   - Thấy logs 🚀 initialization
   - Thấy logs "Push token registered successfully"
3. Check backend database xem token đã được lưu chưa

## 🔧 Backend Requirements

Backend phải gửi notification theo format:

```typescript
// Đúng ✅
{
  "to": "fcm_token_here",
  "notification": {
    "title": "Leave Request Approved",
    "body": "Your leave request has been approved"
  },
  "data": {
    "type": "leave_request",
    "id": "123",
    "status": "approved"
  }
}

// Sai ❌ - Thiếu notification object
{
  "to": "fcm_token_here",
  "data": {
    "type": "leave_request",
    "id": "123"
  }
}
```

## 📝 Next Steps (Optional)

1. **Add Navigation Handling:**
   - Update `onNotificationTapped` callback trong main.dart
   - Parse data và navigate đến màn hình tương ứng

2. **Add Custom Notification Sounds:**
   - Add sound files vào project
   - Update `AndroidNotificationDetails` và `DarwinNotificationDetails`

3. **Add Notification Actions:**
   - Add action buttons (Accept, Reject, etc.)
   - Handle actions trong notification tap callback

4. **Add Analytics:**
   - Track notification received
   - Track notification opened
   - Track notification actions
