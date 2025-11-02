# Login Feature Implementation

## 📁 Cấu trúc dự án (Clean Architecture)

```
lib/
├── core/
│   ├── constants/
│   │   └── api_constants.dart          # Cấu hình API endpoints và base URL
│   ├── di/
│   │   └── injection_container.dart    # Dependency Injection setup
│   ├── error/
│   │   ├── exceptions.dart             # Custom exceptions
│   │   └── failures.dart               # Failure classes cho error handling
│   ├── network/
│   │   └── network_info.dart           # Network connectivity check
│   └── usecases/
│       └── usecase.dart                # Base use case interface
│
└── features/
    └── auth/
        ├── data/
        │   ├── datasources/
        │   │   └── auth_remote_datasource.dart    # API calls
        │   ├── models/
        │   │   ├── api_response_model.dart        # Generic API response
        │   │   ├── login_response_model.dart      # Login response model
        │   │   └── user_model.dart                # User model
        │   └── repositories/
        │       └── auth_repository_impl.dart      # Repository implementation
        │
        ├── domain/
        │   ├── entities/
        │   │   ├── login_response_entity.dart     # Login response entity
        │   │   └── user_entity.dart               # User entity
        │   ├── repositories/
        │   │   └── auth_repository.dart           # Repository interface
        │   └── usecases/
        │       └── login_usecase.dart             # Login use case
        │
        ├── presentation/
        │   ├── controllers/
        │   │   └── login_controller.dart          # Login state management
        │   ├── state/
        │   │   └── login_state.dart               # Login state model
        │   └── sign_in_screen.dart                # Login UI
        │
        ├── application/
        │   └── auth_controller.dart               # Global auth state
        │
        └── providers/
            └── auth_providers.dart                # Riverpod providers
```

## 🔧 Cấu hình

### 1. Cập nhật API Base URL

Mở file `lib/core/constants/api_constants.dart` và thay đổi `baseUrl`:

```dart
class ApiConstants {
  static const String baseUrl = 'http://your-backend-url.com/api';
  // ...
}
```

### 2. Backend API Format

API backend cần trả về response theo format:

```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
      "id": "123",
      "email": "user@example.com",
      "full_name": "John Doe",
      "role": "employee"
    }
  }
}
```

### 3. Error Handling

API backend xử lý các trường hợp lỗi:

#### Unauthorized (401):
```json
{
  "success": false,
  "message": "Invalid credentials"
}
```

#### Temporary Password:
```json
{
  "success": false,
  "message": "Temporary password must change",
  "error_code": "TEMPORARY_PASSWORD_MUST_CHANGE"
}
```

## 🚀 Sử dụng

### Login Flow

1. User nhập email và password
2. Nhấn nút "Đăng nhập"
3. System gọi API `/auth/login`
4. Xử lý response:
   - ✅ Success → Navigate to Home screen
   - ❌ Invalid credentials → Show error message
   - ⚠️  Temporary password → Show warning và redirect đến change password
   - 🌐 No internet → Show network error

### Code Example

```dart
// Gọi login từ UI
ref.read(loginControllerProvider.notifier).login(
  email,
  password,
);

// Listen cho authentication state
ref.listen(loginControllerProvider, (previous, next) {
  if (next.isAuthenticated) {
    // Navigate to home
    context.go(AppRoutePath.home);
  } else if (next.isTemporaryPassword) {
    // Show temporary password warning
  } else if (next.errorMessage != null) {
    // Show error message
  }
});
```

## 📦 Dependencies

```yaml
dependencies:
  flutter_riverpod: ^3.0.3    # State management
  go_router: ^16.3.0          # Routing
  dio: ^5.9.0                 # HTTP client
  dartz: ^0.10.1              # Functional programming (Either)
  get_it: ^7.6.4              # Dependency injection
  internet_connection_checker: ^1.0.0+1  # Network status
```

## 🔐 Security Features

1. **Password Obscure**: Mật khẩu được ẩn khi nhập
2. **Network Check**: Kiểm tra kết nối internet trước khi gọi API
3. **Temporary Password Detection**: Phát hiện và yêu cầu đổi mật khẩu tạm
4. **Account Lock Detection**: Xử lý trường hợp tài khoản bị khóa

## 🎯 Clean Architecture Benefits

1. **Separation of Concerns**: Mỗi layer có trách nhiệm riêng
2. **Testability**: Dễ dàng test từng layer độc lập
3. **Maintainability**: Dễ bảo trì và mở rộng
4. **Dependency Rule**: Dependencies chỉ đi từ ngoài vào trong (UI → Domain)
5. **Scalability**: Dễ dàng thêm features mới

## 🧪 Testing

Có thể test từng layer:

- **Domain Layer**: Test use cases và entities (pure Dart, không phụ thuộc Flutter)
- **Data Layer**: Test repository và data source (mock API)
- **Presentation Layer**: Test controllers và UI (widget tests)

## 📝 Notes

- Token được lưu trong `LoginState` (có thể extend để lưu vào local storage)
- Router tự động redirect dựa trên authentication state
- Error messages được hiển thị qua `SnackBar`
- Form validation cho email và password

## 🔄 Next Steps

1. Implement token storage (SharedPreferences/Hive)
2. Add auto token refresh
3. Implement change password feature
4. Add biometric authentication
5. Implement logout functionality
