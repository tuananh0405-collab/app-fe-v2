# Leave Management Feature (Quản lý nghỉ phép)

## Tổng quan
Feature quản lý đơn xin nghỉ cho nhân viên, được xây dựng theo Clean Architecture với Riverpod state management.

## Cấu trúc

```
lib/features/leave/
├── domain/                          # Business Logic Layer
│   ├── entities/                    # Domain entities
│   │   ├── leave_entity.dart       # Leave request entity
│   │   └── leave_balance_entity.dart # Leave balance entity
│   ├── repositories/                # Repository interfaces
│   │   └── leave_repository.dart
│   └── usecases/                    # Use cases
│       ├── create_leave_request_usecase.dart
│       ├── get_leave_balance_usecase.dart
│       ├── get_leave_records_usecase.dart
│       └── update_leave_request_usecase.dart
│
├── data/                            # Data Layer
│   ├── models/                      # Data models
│   │   ├── leave_model.dart
│   │   ├── leave_balance_model.dart
│   │   └── leave_api_response_model.dart
│   ├── datasources/                 # Remote data sources
│   │   └── leave_remote_datasource.dart
│   └── repositories/                # Repository implementations
│       └── leave_repository_impl.dart
│
├── presentation/                    # Presentation Layer
│   ├── screens/                     # UI Screens
│   │   ├── leave_list_screen.dart  # Danh sách đơn nghỉ
│   │   ├── create_leave_screen.dart # Tạo đơn mới
│   │   ├── leave_detail_screen.dart # Chi tiết đơn nghỉ
│   │   └── update_leave_screen.dart # Cập nhật đơn nghỉ
│   ├── controllers/                 # State controllers
│   │   └── leave_controller.dart
│   └── state/                       # State classes
│       └── leave_state.dart
│
├── providers/                       # Riverpod providers
│   └── leave_providers.dart
│
└── leave.dart                       # Barrel export file
```

## Tính năng chính

### 1. Danh sách đơn nghỉ (Leave List)
- Hiển thị tất cả đơn xin nghỉ của nhân viên
- Hiển thị số ngày nghỉ còn lại
- Refresh để cập nhật dữ liệu
- Màu sắc theo trạng thái: Pending (Cam), Approved (Xanh lá), Rejected (Đỏ), Cancelled (Xám)

### 2. Tạo đơn xin nghỉ (Create Leave Request)
- Chọn loại nghỉ phép (Nghỉ phép năm, Nghỉ ốm, Nghỉ việc riêng, Nghỉ không lương)
- Chọn ngày bắt đầu và kết thúc
- Tùy chọn nghỉ nửa ngày đầu/cuối
- Nhập lý do xin nghỉ
- Link tài liệu hỗ trợ (không bắt buộc)

### 3. Chi tiết đơn nghỉ (Leave Detail)
- Hiển thị đầy đủ thông tin đơn nghỉ
- Trạng thái phê duyệt
- Thông tin phê duyệt (nếu đã duyệt)
- Lý do từ chối (nếu bị từ chối)
- Nút chỉnh sửa (chỉ hiển thị khi status = PENDING)

### 4. Cập nhật đơn nghỉ (Update Leave Request)
- Chỉnh sửa thông tin đơn nghỉ đang chờ duyệt
- Validation giống form tạo mới

## API Endpoints

### 1. Tạo đơn xin nghỉ
```
POST /api/v1/leave/leave-records
```

**Request Body:**
```json
{
  "employee_id": 2,
  "employee_code": "EMP001",
  "department_id": 1,
  "leave_type_id": 1,
  "start_date": "2025-01-20",
  "end_date": "2025-01-22",
  "is_half_day_start": false,
  "is_half_day_end": false,
  "reason": "Family emergency",
  "supporting_document_url": "https://example.com/document.pdf",
  "metadata": {}
}
```

**Response:**
```json
{
  "status": "SUCCESS",
  "statusCode": 201,
  "message": "Leave request created successfully",
  "data": {
    "id": 1,
    "employee_id": 2,
    "status": "PENDING",
    ...
  }
}
```

### 2. Xem lịch sử đơn nghỉ
```
GET /api/v1/leave/leave-records
```

### 3. Cập nhật đơn nghỉ
```
PUT /api/v1/leave/leave-records/{id}
```

### 4. Xem số ngày nghỉ còn lại
```
GET /api/v1/leave/leave-balances/employee/{employeeId}
```

## State Management

### LeaveState
```dart
class LeaveState {
  final bool isLoading;              // Loading state for data fetching
  final bool isSubmitting;           // Loading state for form submission
  final String? errorMessage;        // Error message
  final String? successMessage;      // Success message
  final List<LeaveEntity> leaveRecords;     // List of leave requests
  final List<LeaveBalanceEntity> leaveBalances; // Leave balances
  final LeaveEntity? selectedLeave;  // Currently selected leave
}
```

### LeaveController Methods
- `createLeaveRequest()` - Tạo đơn xin nghỉ mới
- `getLeaveRecords()` - Lấy danh sách đơn nghỉ
- `getLeaveBalance()` - Lấy số ngày nghỉ còn lại
- `updateLeaveRequest()` - Cập nhật đơn nghỉ
- `selectLeave()` - Chọn đơn nghỉ để xem chi tiết
- `clearMessages()` - Xóa thông báo lỗi/thành công

## Routes

```dart
'/leaves'              -> LeaveListScreen
'/leaves/create'       -> CreateLeaveScreen  
'/leaves/:id'          -> LeaveDetailScreen
'/leaves/:id/edit'     -> UpdateLeaveScreen
```

## Sử dụng

### Navigation từ Home Screen
```dart
// Quick Actions có 2 nút:
// 1. "Leave Request" -> Tạo đơn mới
context.push(AppRoutePath.leavesCreate);

// 2. "My Leaves" -> Xem danh sách
context.push(AppRoutePath.leaves);
```

### Access Leave Controller
```dart
// Read controller
final leaveState = ref.watch(leaveControllerProvider);

// Call methods
ref.read(leaveControllerProvider.notifier).getLeaveRecords();
ref.read(leaveControllerProvider.notifier).createLeaveRequest(...);
```

## Dependencies

- `flutter_riverpod` - State management
- `go_router` - Navigation
- `dio` - HTTP client
- `dartz` - Functional programming (Either type)
- `intl` - Date formatting

## Mock Data

Hiện tại sử dụng mock data:
- `employeeId = 7` (hardcoded trong LeaveListScreen và CreateLeaveScreen)
- `employeeCode = "EMP001"`
- `departmentId = 1`

**TODO:** Lấy thông tin thật từ user authentication

## Error Handling

- Network errors
- Server errors
- Validation errors
- Unauthorized errors

Tất cả errors được xử lý trong repository layer và trả về `Either<Failure, Success>`.

## Clean Architecture Layers

1. **Domain Layer** - Business logic, entities, use cases (không phụ thuộc vào bất kỳ framework nào)
2. **Data Layer** - API calls, data models, repository implementations
3. **Presentation Layer** - UI, state management, user interactions

## Testing

TODO: Thêm unit tests và widget tests cho:
- Use cases
- Repository
- Controllers
- UI screens
