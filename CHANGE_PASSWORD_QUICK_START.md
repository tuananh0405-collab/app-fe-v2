# Change Password Feature - Quick Start Guide

## 📱 Feature Overview

This feature allows users to change their password through the Profile settings. It supports both:
- **Regular password changes** from Profile Settings (using endpoint: `PUT /auth/me/password`)
- **Temporary password changes** from Login flow (using endpoint: `PUT /auth/me/change-temporary-password`)

## 🚀 How to Use

### From Profile Settings (Regular Password Change)

1. User navigates to **Profile** screen
2. Taps on **"Change Password"** menu item
3. Enters:
   - Current password
   - New password
4. Submits the form
5. On success: Returns to Profile screen
6. On error: Shows error message

### From Login Flow (Temporary Password Change)

1. User logs in with temporary password
2. Automatically redirected to Change Password screen
3. Enters:
   - Current temporary password
   - New password
   - Confirm new password
4. Submits the form
5. On success: Logged out and redirected to Login screen
6. User logs in with new password

## 🔧 API Details

### Endpoint: `PUT http://3.27.15.166:32527/api/v1/auth/me/password`

**Request Body:**
```json
{
  "current_password": "OldPassword123!",
  "new_password": "NewPassword456!"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Password changed successfully",
  "data": null
}
```

**Error Response (400/401):**
```json
{
  "success": false,
  "message": "Current password is incorrect",
  "error_code": "INVALID_PASSWORD"
}
```

## 📋 Password Requirements

- Minimum 8 characters
- At least 1 uppercase letter (A-Z)
- At least 1 lowercase letter (a-z)
- At least 1 number (0-9)
- At least 1 special character (!@#$%^&*(),.?":{}|<>)

## 📂 Files Modified/Created

### New Files
1. `lib/features/auth/domain/usecases/change_password_usecase.dart` - Use case for regular password change
2. `CHANGE_PASSWORD_FEATURE.md` - Complete documentation
3. `CHANGE_PASSWORD_QUICK_START.md` - This file

### Modified Files
1. `lib/features/auth/domain/repositories/auth_repository.dart` - Added `changePassword` method
2. `lib/features/auth/data/datasources/auth_remote_datasource.dart` - Added API call implementation
3. `lib/features/auth/data/repositories/auth_repository_impl.dart` - Added repository implementation
4. `lib/features/auth/presentation/controllers/change_password_controller.dart` - Added support for both modes
5. `lib/features/auth/presentation/change_password_screen.dart` - Updated UI to support both modes
6. `lib/features/auth/providers/auth_providers.dart` - Added new use case provider
7. `lib/core/routing/app_router.dart` - Added query parameter support
8. `lib/features/profile/presentation/profile_screen.dart` - Connected to change password screen
9. `lib/core/di/injection_container.dart` - Registered new use case

## ✅ Testing

### Test Regular Password Change
```bash
1. Run the app
2. Login with valid credentials
3. Go to Profile > Change Password
4. Enter current password: [your password]
5. Enter new password: NewPassword123!
6. Submit
7. Verify success message
8. Logout and login with new password
```

### Test Temporary Password Change
```bash
1. Login with temporary password credentials
2. Verify auto-redirect to Change Password screen
3. Complete password change
4. Verify redirect to Login screen
5. Login with new password
```

## 🎯 Key Features

✅ Clean Architecture implementation
✅ Dual mode support (temporary & regular)
✅ Password validation with clear requirements
✅ Network error handling
✅ Token-based authentication
✅ User-friendly error messages
✅ Smooth navigation flow
✅ State management with Riverpod

## 📖 For More Details

See `CHANGE_PASSWORD_FEATURE.md` for complete documentation including:
- Architecture details
- Code examples
- Security considerations
- Troubleshooting guide
