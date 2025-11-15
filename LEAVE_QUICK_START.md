# Leave Management - Quick Start Guide

## ✅ Đã hoàn thành

Feature quản lý đơn xin nghỉ (Leave Management) đã được tích hợp hoàn toàn theo Clean Architecture.

## 🚀 Cách sử dụng

### 1. Truy cập từ Home Screen

Sau khi đăng nhập, bạn có thể truy cập leave management qua 2 cách:

**Cách 1: Quick Actions trên Home Screen**
- Tap vào **"Leave Request"** để tạo đơn nghỉ mới
- Tap vào **"My Leaves"** để xem danh sách đơn nghỉ

**Cách 2: Navigation trực tiếp**
```dart
// Xem danh sách đơn nghỉ
context.push('/leaves');

// Tạo đơn mới
context.push('/leaves/create');

// Xem chi tiết (id = 1)
context.push('/leaves/1');

// Chỉnh sửa đơn nghỉ (id = 1)
context.push('/leaves/1/edit');
```

### 2. Danh sách màn hình

#### 📋 Leave List Screen (`/leaves`)
- Hiển thị tất cả đơn xin nghỉ
- Hiển thị số ngày nghỉ còn lại (Leave Balance)
- Pull-to-refresh để cập nhật
- Tap vào đơn để xem chi tiết
- FAB "Tạo đơn nghỉ" để tạo mới

#### ➕ Create Leave Screen (`/leaves/create`)
- Chọn loại nghỉ phép
- Chọn ngày bắt đầu & kết thúc
- Checkbox nghỉ nửa ngày
- Nhập lý do
- Link tài liệu (optional)

#### 👁️ Leave Detail Screen (`/leaves/:id`)
- Xem đầy đủ thông tin đơn nghỉ
- Trạng thái: Pending/Approved/Rejected/Cancelled
- Thông tin phê duyệt (nếu có)
- Nút Edit (chỉ với status = PENDING)

#### ✏️ Update Leave Screen (`/leaves/:id/edit`)
- Chỉnh sửa đơn nghỉ đang chờ duyệt
- Form giống Create screen

## 📁 File structure

```
lib/features/leave/
├── domain/              # Business logic
├── data/                # API & Data handling  
├── presentation/        # UI Screens & Controllers
├── providers/           # Riverpod providers
└── leave.dart          # Barrel export
```

## 🔗 API Endpoints

1. **Tạo đơn**: `POST /api/v1/leave/leave-records`
2. **Xem danh sách**: `GET /api/v1/leave/leave-records`
3. **Cập nhật đơn**: `PUT /api/v1/leave/leave-records/{id}`
4. **Xem số ngày còn lại**: `GET /api/v1/leave/leave-balances/employee/{employeeId}`

## ⚙️ Configuration

### Mock Employee Data
Hiện tại đang dùng mock data (cần cập nhật sau):

```dart
// Trong CreateLeaveScreen & LeaveListScreen
int _employeeId = 7;
String _employeeCode = 'EMP001';
int _departmentId = 1;
```

**TODO:** Thay thế bằng thông tin user thật từ authentication

### API Base URL
```dart
// lib/core/constants/api_constants.dart
static const String baseUrl = 'http://3.27.15.166:32527/api/v1';
```

## 🎨 UI Features

### Màu trạng thái
- 🟠 **PENDING** - Chờ duyệt (Orange)
- 🟢 **APPROVED** - Đã duyệt (Green)
- 🔴 **REJECTED** - Từ chối (Red)
- ⚪ **CANCELLED** - Đã hủy (Grey)

### Leave Balance Card
Hiển thị số ngày nghỉ còn lại cho từng loại nghỉ phép:
- Nghỉ phép năm
- Nghỉ ốm
- Nghỉ việc riêng
- Nghỉ không lương

## 🔐 Authentication

Feature tự động gửi kèm token trong header (qua `AuthInterceptor` trong DioClient).

Không cần xử lý token thủ công.

## 🐛 Debugging

### Bật Dio Logger
Pretty Dio Logger đã được enabled trong `DioClient`:
```dart
PrettyDioLogger(
  requestHeader: true,
  requestBody: true,
  responseBody: true,
  ...
)
```

### Check state
```dart
// Watch controller state
final leaveState = ref.watch(leaveControllerProvider);

// Check loading
print(leaveState.isLoading);
print(leaveState.isSubmitting);

// Check data
print(leaveState.leaveRecords.length);
print(leaveState.leaveBalances);

// Check errors
print(leaveState.errorMessage);
print(leaveState.successMessage);
```

## 📝 Validation Rules

### Create/Update Leave Form
1. ✅ Loại nghỉ phép: Required
2. ✅ Ngày bắt đầu: Required
3. ✅ Ngày kết thúc: Required (>= ngày bắt đầu)
4. ✅ Lý do: Required, không rỗng
5. ⭕ Link tài liệu: Optional

## 🚦 Status Flow

```
CREATE → PENDING → APPROVED/REJECTED
                 ↓
              CANCELLED
```

- **PENDING**: Vừa tạo, chưa duyệt
- **APPROVED**: Admin đã duyệt
- **REJECTED**: Admin từ chối
- **CANCELLED**: User hoặc Admin hủy

## 📱 Responsive Design

- Sử dụng `SingleChildScrollView` cho tất cả screens
- Pull-to-refresh trên Leave List
- Loading indicators khi submit form
- Error/Success SnackBar

## 🎯 Next Steps

1. ✅ Đã tích hợp UI và API
2. 🔄 TODO: Lấy employee info thật từ auth
3. 🔄 TODO: Thêm pagination cho danh sách
4. 🔄 TODO: Thêm filter theo trạng thái
5. 🔄 TODO: Thêm unit tests
6. 🔄 TODO: Thêm khả năng hủy đơn (CANCEL)

## 📚 Documentation

Chi tiết đầy đủ xem tại: `LEAVE_MANAGEMENT_FEATURE.md`

---

**Created:** November 15, 2025  
**Architecture:** Clean Architecture + Riverpod  
**Status:** ✅ Production Ready (với mock employee data)
