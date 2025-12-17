import 'package:flutter/material.dart';

class AuthLocalizations {
  final Locale locale;

  AuthLocalizations(this.locale);

  static final Map<String, Map<String, String>> _translations = {
    'en': {
      // Change Password Screen
      'change_password': 'Change Password',
      'change_temporary_password': 'Change Temporary Password',
      'current_password': 'Current Password',
      'new_password': 'New Password',
      'confirm_password': 'Confirm New Password',
      'password_requirements': 'Password Requirements:',
      'requirement_min_length': 'At least 8 characters',
      'requirement_uppercase': 'At least 1 uppercase letter',
      'requirement_lowercase': 'At least 1 lowercase letter',
      'requirement_number': 'At least 1 number',
      'requirement_special_char': 'At least 1 special character (!@#\$%^&*...)',
      'using_temporary_password': 'You are using a temporary password',
      'please_change_password': 'Please change to a new password to continue',
      'enter_current_and_new': 'Enter current password and new password',
      
      // Validation Messages
      'please_enter_password': 'Please enter password',
      'password_min_8_chars': 'Password must be at least 8 characters',
      'password_need_uppercase': 'Password must have at least 1 uppercase letter',
      'password_need_lowercase': 'Password must have at least 1 lowercase letter',
      'password_need_number': 'Password must have at least 1 number',
      'password_need_special_char': 'Password must have at least 1 special character',
      'please_enter_current_password': 'Please enter current password',
      'please_confirm_password': 'Please confirm password',
      'passwords_do_not_match': 'Passwords do not match',
      
      // Success Messages
      'password_changed_success': 'Password changed successfully!',
      'password_changed_login_again': 'Password changed successfully! Please login again.',
    },
    'vi': {
      // Change Password Screen
      'change_password': 'Đổi mật khẩu',
      'change_temporary_password': 'Đổi mật khẩu tạm thời',
      'current_password': 'Mật khẩu hiện tại',
      'new_password': 'Mật khẩu mới',
      'confirm_password': 'Xác nhận mật khẩu mới',
      'password_requirements': 'Yêu cầu mật khẩu:',
      'requirement_min_length': 'Ít nhất 8 ký tự',
      'requirement_uppercase': 'Có ít nhất 1 chữ hoa',
      'requirement_lowercase': 'Có ít nhất 1 chữ thường',
      'requirement_number': 'Có ít nhất 1 số',
      'requirement_special_char': 'Có ít nhất 1 ký tự đặc biệt (!@#\$%^&*...)',
      'using_temporary_password': 'Bạn đang sử dụng mật khẩu tạm thời',
      'please_change_password': 'Vui lòng đổi sang mật khẩu mới để tiếp tục',
      'enter_current_and_new': 'Nhập mật khẩu hiện tại và mật khẩu mới',
      
      // Validation Messages
      'please_enter_password': 'Vui lòng nhập mật khẩu',
      'password_min_8_chars': 'Mật khẩu phải có ít nhất 8 ký tự',
      'password_need_uppercase': 'Mật khẩu phải có ít nhất 1 chữ hoa',
      'password_need_lowercase': 'Mật khẩu phải có ít nhất 1 chữ thường',
      'password_need_number': 'Mật khẩu phải có ít nhất 1 số',
      'password_need_special_char': 'Mật khẩu phải có ít nhất 1 ký tự đặc biệt',
      'please_enter_current_password': 'Vui lòng nhập mật khẩu hiện tại',
      'please_confirm_password': 'Vui lòng xác nhận mật khẩu',
      'passwords_do_not_match': 'Mật khẩu xác nhận không khớp',
      
      // Success Messages
      'password_changed_success': 'Đổi mật khẩu thành công!',
      'password_changed_login_again': 'Đổi mật khẩu thành công! Vui lòng đăng nhập lại.',
    },
  };

  String translate(String key) {
    return _translations[locale.languageCode]?[key] ?? key;
  }

  // Change Password Screen
  String get changePassword => translate('change_password');
  String get changeTemporaryPassword => translate('change_temporary_password');
  String get currentPassword => translate('current_password');
  String get newPassword => translate('new_password');
  String get confirmPassword => translate('confirm_password');
  String get passwordRequirements => translate('password_requirements');
  String get requirementMinLength => translate('requirement_min_length');
  String get requirementUppercase => translate('requirement_uppercase');
  String get requirementLowercase => translate('requirement_lowercase');
  String get requirementNumber => translate('requirement_number');
  String get requirementSpecialChar => translate('requirement_special_char');
  String get usingTemporaryPassword => translate('using_temporary_password');
  String get pleaseChangePassword => translate('please_change_password');
  String get enterCurrentAndNew => translate('enter_current_and_new');
  
  // Validation Messages
  String get pleaseEnterPassword => translate('please_enter_password');
  String get passwordMin8Chars => translate('password_min_8_chars');
  String get passwordNeedUppercase => translate('password_need_uppercase');
  String get passwordNeedLowercase => translate('password_need_lowercase');
  String get passwordNeedNumber => translate('password_need_number');
  String get passwordNeedSpecialChar => translate('password_need_special_char');
  String get pleaseEnterCurrentPassword => translate('please_enter_current_password');
  String get pleaseConfirmPassword => translate('please_confirm_password');
  String get passwordsDoNotMatch => translate('passwords_do_not_match');
  
  // Success Messages
  String get passwordChangedSuccess => translate('password_changed_success');
  String get passwordChangedLoginAgain => translate('password_changed_login_again');
}
