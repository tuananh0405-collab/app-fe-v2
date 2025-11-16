# Change Password Feature

## 📋 Overview

This feature allows users to change their password from the profile settings. The implementation follows Clean Architecture principles and supports both temporary password changes (from login flow) and regular password changes (from profile settings).

## 🔧 Implementation Details

### API Endpoints

The feature uses two different endpoints:

1. **Regular Password Change** (from Profile Settings):
   - **Endpoint**: `PUT /auth/me/password`
   - **Request Body**:
     ```json
     {
       "current_password": "OldPassword123!",
       "new_password": "NewPassword456!"
     }
     ```

2. **Temporary Password Change** (from Login Flow):
   - **Endpoint**: `PUT /auth/me/change-temporary-password`
   - **Request Body**:
     ```json
     {
       "current_password": "TemporaryPassword123!",
       "new_password": "NewPassword456!",
       "confirm_password": "NewPassword456!"
     }
     ```

### Architecture

The implementation follows Clean Architecture with the following layers:

```
lib/features/auth/
├── domain/
│   ├── usecases/
│   │   ├── change_password_usecase.dart         # Regular password change use case
│   │   └── change_temporary_password_usecase.dart  # Temporary password change use case
│   └── repositories/
│       └── auth_repository.dart                  # Repository interface with both methods
│
├── data/
│   ├── datasources/
│   │   └── auth_remote_datasource.dart          # API implementation
│   └── repositories/
│       └── auth_repository_impl.dart            # Repository implementation
│
└── presentation/
    ├── controllers/
    │   └── change_password_controller.dart       # Controller with both methods
    ├── state/
    │   └── change_password_state.dart           # State management
    └── change_password_screen.dart              # UI that supports both modes
```

### Key Features

1. **Dual Mode Support**:
   - Temporary password change (required after first login)
   - Regular password change (from profile settings)

2. **Smart UI Adaptation**:
   - Shows appropriate header text based on mode
   - Displays confirm password field only for temporary password
   - Back button only shown for regular mode
   - Different success messages and navigation

3. **Password Validation**:
   - Minimum 8 characters
   - At least 1 uppercase letter
   - At least 1 lowercase letter
   - At least 1 number
   - At least 1 special character (!@#$%^&*...)

4. **Error Handling**:
   - Network connectivity check
   - Server error handling
   - User-friendly error messages

## 🚀 Usage

### From Profile Settings

Users can change their password by:
1. Going to Profile screen
2. Tapping "Change Password" menu item
3. Entering current password and new password
4. Submitting the form

```dart
// Navigation from Profile screen
context.push(AppRoutePath.changePassword);
```

### From Login Flow (Temporary Password)

When a user logs in with a temporary password:
1. System automatically redirects to change password screen
2. User must enter current temporary password
3. User enters new password and confirms it
4. After successful change, redirected to login screen

```dart
// Automatic redirect in router
if (loginState.mustChangePassword && !changingPassword) {
  return '${AppRoutePath.changePassword}?temporary=true';
}
```

## 📝 Code Examples

### Using the Controller

```dart
// Regular password change (from profile)
ref.read(changePasswordControllerProvider.notifier).changePassword(
  currentPassword: currentPassword,
  newPassword: newPassword,
);

// Temporary password change (from login flow)
ref.read(changePasswordControllerProvider.notifier).changeTemporaryPassword(
  currentPassword: currentPassword,
  newPassword: newPassword,
  confirmPassword: confirmPassword,
);
```

### Listening to State Changes

```dart
ref.listen(changePasswordControllerProvider, (previous, next) {
  if (next.isSuccess) {
    // Show success message
    showSnackbar(context, 'Password changed successfully!');
  } else if (next.errorMessage != null) {
    // Show error message
    showSnackbar(context, next.errorMessage!);
  }
});
```

## 🔐 Security

- Passwords are sent over HTTPS
- Current password is required for verification
- Password strength requirements enforced
- Token-based authentication for API calls

## 🎯 User Flow

### Regular Password Change Flow

```
Profile Screen → Change Password Screen → Enter Credentials → Submit
→ Success → Back to Profile Screen
```

### Temporary Password Change Flow

```
Login with Temporary Password → Auto Redirect to Change Password Screen
→ Enter Credentials → Submit → Success → Logout → Login Screen
```

## 📦 Dependencies

All required dependencies are already in the project:
- `flutter_riverpod`: State management
- `go_router`: Navigation
- `dio`: HTTP client
- `dartz`: Functional programming (Either)

## 🧪 Testing the Feature

1. **From Profile Settings**:
   ```
   1. Login with regular credentials
   2. Navigate to Profile > Change Password
   3. Enter current and new password
   4. Verify success message
   5. Try logging in with new password
   ```

2. **Temporary Password**:
   ```
   1. Login with temporary password credentials
   2. Verify automatic redirect
   3. Complete password change
   4. Verify redirect to login
   5. Login with new password
   ```

## 🐛 Troubleshooting

### Common Issues

1. **"Invalid credentials" error**:
   - Verify current password is correct
   - Check API endpoint is accessible

2. **Validation errors**:
   - Ensure new password meets all requirements
   - Check confirm password matches (for temporary mode)

3. **Network errors**:
   - Verify internet connection
   - Check API base URL in `api_constants.dart`

## 📋 API Response Format

### Success Response (200)
```json
{
  "success": true,
  "message": "Password changed successfully",
  "data": null
}
```

### Error Response (400/401)
```json
{
  "success": false,
  "message": "Current password is incorrect",
  "error_code": "INVALID_PASSWORD"
}
```

## 🔄 Future Enhancements

- [ ] Add password strength indicator
- [ ] Implement password history (prevent reuse)
- [ ] Add biometric authentication option
- [ ] Email notification on password change
- [ ] Password expiration reminders
