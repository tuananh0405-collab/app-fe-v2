# Notifications Feature

## 📋 Tổng quan

Feature notification list với các chức năng:
- ✅ Hiển thị danh sách thông báo (phân trang với limit/offset)
- ✅ Pull to refresh
- ✅ Load more khi scroll
- ✅ Đánh dấu đã đọc (mark as read)
- ✅ Đánh dấu tất cả đã đọc (mark all as read)
- ✅ Hiển thị số lượng chưa đọc
- ✅ Phân loại theo loại thông báo và độ ưu tiên
- ✅ Hiển thị thời gian tương đối (vừa xong, 5 phút trước, v.v.)

## 🏗️ Cấu trúc

```
lib/features/notifications/
├── domain/
│   ├── models/
│   │   ├── notification_model.dart          # Entity với đầy đủ fields từ DB
│   │   └── paginated_notifications.dart     # Model cho pagination
│   ├── repositories/
│   │   └── notification_repository.dart     # Abstract repository
│   └── usecases/
│       ├── get_notifications_usecase.dart   # Get notifications với limit/offset
│       ├── mark_as_read_usecase.dart        # Mark single notification
│       └── mark_all_as_read_usecase.dart    # Mark all as read
├── data/
│   ├── models/
│   │   ├── notification_model.dart          # Model với fromJson/toJson
│   │   └── paginated_notifications_model.dart
│   ├── datasources/
│   │   └── notification_remote_datasource.dart
│   └── repositories/
│       └── notification_repository_impl.dart
├── presentation/
│   ├── state/
│   │   └── notification_list_state.dart     # State management
│   ├── controllers/
│   │   └── notification_list_controller.dart # Riverpod controller
│   └── pages/
│       └── notifications_list_screen.dart    # UI screen
└── providers/
    └── notification_providers.dart           # All Riverpod providers
```

## 🔌 Backend API Endpoints

### 1. Get Notifications
```
GET /api/v1/notification
Query Parameters:
  - limit: number (default: 20)
  - offset: number (default: 0)
  - unreadOnly: boolean (default: false)

Response:
{
  "success": true,
  "data": {
    "notifications": [
      {
        "id": 1,
        "recipient_id": 123,
        "recipient_email": "user@example.com",
        "recipient_name": "Nguyen Van A",
        "title": "Thông báo nghỉ phép",
        "message": "Đơn nghỉ phép của bạn đã được phê duyệt",
        "notification_type": "LEAVE_APPROVAL",
        "priority": "NORMAL",
        "related_entity_type": "LEAVE_REQUEST",
        "related_entity_id": 456,
        "related_data": {},
        "channels": ["IN_APP", "EMAIL"],
        "is_read": false,
        "read_at": null,
        "email_sent": true,
        "email_sent_at": "2025-11-06T10:00:00Z",
        "push_sent": false,
        "push_sent_at": null,
        "sms_sent": false,
        "sms_sent_at": null,
        "metadata": {},
        "created_at": "2025-11-06T09:00:00Z",
        "expires_at": null
      }
    ],
    "total": 100,
    "unread_count": 15,
    "limit": 20,
    "offset": 0
  },
  "message": "User notifications retrieved successfully"
}
```

### 2. Mark as Read
```
PUT /api/v1/notifications/:id/read

Response:
{
  "success": true,
  "data": null,
  "message": "Notification marked as read"
}
```

### 3. Mark All as Read
```
PUT /api/v1/notifications/read-all

Response:
{
  "success": true,
  "data": null,
  "message": "All notifications marked as read"
}
```

## 📊 Database Schema

Đã map đầy đủ với bảng `notifications`:
- ✅ Tất cả fields từ DB
- ✅ Denormalized recipient info
- ✅ Related entity tracking
- ✅ Multi-channel delivery status
- ✅ Metadata và expires_at

## 🎨 UI Features

### Màn hình chính
- AppBar với tiêu đề và số lượng chưa đọc
- Button "Đọc tất cả" khi có thông báo chưa đọc
- Pull to refresh
- Infinite scroll (load more)
- Empty state khi không có thông báo
- Error state với retry button

### Notification Card
- Icon theo loại thông báo (LEAVE_APPROVAL = check, LEAVE_REJECTION = cancel, v.v.)
- Badge hiển thị độ ưu tiên (URGENT, HIGH)
- Dot màu xanh cho thông báo chưa đọc
- Border đậm hơn cho thông báo chưa đọc
- Thời gian tương đối (5 phút trước, 2 giờ trước, v.v.)
- Chevron icon nếu có liên kết (related_entity)

### Loại thông báo (NotificationType)
- `ATTENDANCE_REMINDER` - Nhắc chấm công
- `CHECK_IN_REMINDER` - Nhắc check in
- `CHECK_OUT_REMINDER` - Nhắc check out
- `LEAVE_REQUEST` - Yêu cầu nghỉ phép
- `LEAVE_APPROVAL` - Phê duyệt nghỉ phép
- `LEAVE_REJECTION` - Từ chối nghỉ phép
- `SYSTEM_ANNOUNCEMENT` - Thông báo hệ thống
- `OTHER` - Khác

### Độ ưu tiên (NotificationPriority)
- `LOW` - Thấp
- `NORMAL` - Bình thường (default)
- `HIGH` - Cao
- `URGENT` - Khẩn cấp

## 🚀 Sử dụng

### 1. Import
```dart
import 'package:flutter_application_1/features/notifications/notifications.dart';
```

### 2. Navigation
```dart
// Trong router đã được config
context.push(AppRoutePath.notifications);
// hoặc
context.go(AppRoutePath.notifications);
```

### 3. Access Controller
```dart
final controller = ref.read(notificationListControllerProvider.notifier);

// Load notifications
await controller.loadNotifications(refresh: true);

// Load more
await controller.loadMore();

// Mark as read
await controller.markAsRead(notificationId);

// Mark all as read
await controller.markAllAsRead();
```

### 4. Watch State
```dart
final state = ref.watch(notificationListControllerProvider);

print('Total: ${state.total}');
print('Unread: ${state.unreadCount}');
print('Has more: ${state.hasMore}');
print('Status: ${state.status}');
```

## 🔧 Customization

### Thay đổi số items per page
```dart
// In notification_list_controller.dart
const GetNotificationsParams(limit: 30, offset: 0) // Thay vì 20
```

### Thêm navigation cho related entities
```dart
// In notifications_list_screen.dart -> _handleNotificationTap
if (notification.relatedEntityType == 'LEAVE_REQUEST') {
  context.push('/leaves/${notification.relatedEntityId}');
}
```

### Custom notification card colors
```dart
// In _NotificationCard widget
// Thay đổi màu sắc theo ý muốn
```

## 📝 Notes

1. **Pagination**: Sử dụng `limit/offset` thay vì `page/pageSize`
2. **Response Format**: Backend trả về `ApiResponseDto` với structure:
   ```
   {
     "success": boolean,
     "data": {...},
     "message": string
   }
   ```
3. **Authentication**: Tất cả API calls đều yêu cầu JWT token
4. **Network Error Handling**: Đầy đủ với NetworkInfo check
5. **Local State Update**: Mark as read cập nhật local state ngay lập tức để UX mượt mà

## 🐛 Troubleshooting

### Không load được notifications
- Kiểm tra JWT token còn hợp lệ không
- Check network connection
- Verify API endpoint URL trong `ApiConstants.baseUrl`

### Pagination không hoạt động
- Kiểm tra `hasMore` flag
- Verify scroll listener đã được setup
- Check backend response có đúng format không

### Mark as read không hoạt động
- Verify notification ID đúng
- Check backend log xem có lỗi không
- Ensure user ID từ JWT token đúng
