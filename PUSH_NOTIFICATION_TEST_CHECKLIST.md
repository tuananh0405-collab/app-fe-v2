# Quick Test Checklist ✅

## Sau khi rebuild app, kiểm tra các bước sau:

### 1. ✅ App Start & Initialization
- [ ] Chạy `flutter run`
- [ ] Xem console logs, tìm: `🚀 ===== INITIALIZING PUSH NOTIFICATIONS =====`
- [ ] Confirm thấy: `🎉 ===== PUSH NOTIFICATIONS INITIALIZED SUCCESSFULLY =====`
- [ ] Copy FCM Token từ log: `🔑 FCM Token: ...`
- [ ] Copy Device ID từ log: `📱 Device ID: ...`
- [ ] Confirm thấy: `Push token registered successfully: ...`

### 2. ✅ Test Notification từ Firebase Console
Để test nhanh mà không cần BE:

1. Vào: https://console.firebase.google.com
2. Chọn project của bạn
3. Cloud Messaging → Send your first message
4. Nhập:
   - **Notification title:** Test Title
   - **Notification text:** Test Body
5. Click "Send test message"
6. Paste FCM Token (từ bước 1)
7. Click Test

**Expected Results:**
- **App Foreground:** Thấy notification ở notification tray + logs 🔔
- **App Background:** Thấy notification ở notification tray + logs 🌙 (nếu debug)
- **App Killed:** Thấy notification ở notification tray

### 3. ✅ Test từ Backend (Production)

**Gửi request từ BE với format:**
```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "FCM_TOKEN_HERE",
    "notification": {
      "title": "Test from Backend",
      "body": "This is a test notification"
    },
    "data": {
      "type": "test",
      "id": "123"
    }
  }'
```

**⚠️ Lưu ý cho BE Team:**
- Phải include cả `notification` object (không chỉ `data`)
- `notification.title` và `notification.body` là required
- `data` là optional nhưng recommended để handle navigation

### 4. ✅ Verify Logs

#### Foreground (App đang mở):
```
🔔 ===== FOREGROUND MESSAGE RECEIVED =====
🔔 Message ID: ...
🔔 Notification Title: ...
🔔 Notification Body: ...
📢 Showing local notification: ...
```

#### Background (App đang chạy ngầm):
```
🌙 ===== BACKGROUND MESSAGE RECEIVED =====
🌙 Message ID: ...
🌙 Notification Title: ...
```

#### Tap Notification:
```
👆 ===== NOTIFICATION TAPPED =====
👆 Message ID: ...
📱 Notification tapped: ...
```

## ❓ Nếu không nhận được notification

### Debug Steps:
1. **Check permission:**
   ```
   📋 Notification permission status: AuthorizationStatus.authorized
   ```
   Nếu không thấy `authorized` → vào Settings → App → Permissions → enable Notifications

2. **Check token registration:**
   ```
   Push token registered successfully: ...
   ```
   Nếu không thấy → check backend API có hoạt động không

3. **Check FCM token:**
   - Copy token từ logs
   - Test với Firebase Console trước
   - Nếu Firebase Console work → vấn đề ở BE
   - Nếu Firebase Console không work → vấn đề ở app config

4. **Check google-services.json:**
   - File `android/app/google-services.json` có đúng không?
   - Project ID có match với Firebase Console không?

5. **Check app state:**
   - Foreground: App đang hiển thị
   - Background: App vẫn chạy nhưng không hiển thị (press Home)
   - Killed: App đã bị đóng hoàn toàn (swipe away từ Recent Apps)

## 🎯 Common Issues

### Issue 1: "Token đã register nhưng không nhận được gì"
**Có thể do:**
- ✅ BE gửi sai format (thiếu `notification` object)
- ✅ FCM token sai hoặc expired
- ✅ App đã bị force stop bởi system
- ✅ Device không có internet

### Issue 2: "Thấy log 🔔 nhưng không thấy notification"
**Có thể do:**
- ✅ Notification permission chưa granted
- ✅ Android notification channel chưa được setup đúng
- ✅ Do Not Disturb mode đang bật

### Issue 3: "Background notification không hoạt động"
**Có thể do:**
- ✅ Battery optimization đang kill app
- ✅ Background message handler chưa được register đúng

## 📞 Cần giúp đỡ?

Copy và gửi logs sau:
1. Toàn bộ initialization logs (từ 🚀 đến 🎉)
2. FCM Token
3. Device ID
4. Logs khi BE gửi notification
5. Format notification mà BE đang gửi
