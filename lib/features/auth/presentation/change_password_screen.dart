import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/routes.dart';
import '../providers/auth_providers.dart';
import '../../../flutter_flow/flutter_flow.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen>
    with TickerProviderStateMixin, AnimationControllerMixin<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    
    // Setup animations
    setupAnimations({
      'headerOnPageLoad': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effects: FFAnimations.fadeInSlideUp(
          delay: const Duration(milliseconds: 100),
          duration: const Duration(milliseconds: 600),
        ),
      ),
      'formOnPageLoad': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effects: FFAnimations.fadeInSlideUp(
          delay: const Duration(milliseconds: 200),
          duration: const Duration(milliseconds: 600),
        ),
      ),
    });
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleChangePassword() {
    if (_formKey.currentState!.validate()) {
      ref.read(changePasswordControllerProvider.notifier).changePassword(
            currentPassword: _currentPasswordController.text,
            newPassword: _newPasswordController.text,
            confirmPassword: _confirmPasswordController.text,
          );
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự';
    }
    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Mật khẩu phải có ít nhất 1 chữ hoa';
    }
    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Mật khẩu phải có ít nhất 1 chữ thường';
    }
    // Check for at least one digit
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Mật khẩu phải có ít nhất 1 số';
    }
    // Check for at least one special character
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Mật khẩu phải có ít nhất 1 ký tự đặc biệt';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final changePasswordState = ref.watch(changePasswordControllerProvider);

    // Listen for password change success
    ref.listen(changePasswordControllerProvider, (previous, next) {
      if (previous == null || next == previous) return;
      
      if (next.isSuccess) {
        showSnackbar(
          context,
          'Đổi mật khẩu thành công! Vui lòng đăng nhập lại.',
        );
        // Clear login state and navigate to login
        ref.read(loginControllerProvider.notifier).reset();
        context.go(AppRoutePath.signIn);
      } else if (next.errorMessage != null) {
        showSnackbar(context, next.errorMessage!);
      }
    });

    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: Text(
          'Đổi mật khẩu tạm thời',
          style: theme.title2.override(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 2,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Column(
                    children: [
                      Icon(
                        Icons.lock_reset,
                        size: 80,
                        color: theme.primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Bạn đang sử dụng mật khẩu tạm thời',
                        style: theme.title3,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Vui lòng đổi sang mật khẩu mới để tiếp tục',
                        style: theme.bodyText2,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ).animateOnPageLoad(animationsMap['headerOnPageLoad']!),
                  const SizedBox(height: 40),

                  // Form Fields
                  Column(
                    children: [
                      // Current Password Field
                      TextFormField(
                        controller: _currentPasswordController,
                        obscureText: _obscureCurrentPassword,
                        style: theme.bodyText1,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu hiện tại',
                          labelStyle: theme.bodyText2,
                          prefixIcon: Icon(Icons.lock_outline, color: theme.secondaryText),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.alternate),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.primaryColor, width: 2),
                          ),
                          filled: true,
                          fillColor: theme.secondaryBackground,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureCurrentPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: theme.secondaryText,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureCurrentPassword = !_obscureCurrentPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mật khẩu hiện tại';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // New Password Field
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: _obscureNewPassword,
                        style: theme.bodyText1,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu mới',
                          labelStyle: theme.bodyText2,
                          prefixIcon: Icon(Icons.lock, color: theme.secondaryText),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.alternate),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.primaryColor, width: 2),
                          ),
                          filled: true,
                          fillColor: theme.secondaryBackground,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNewPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: theme.secondaryText,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                          ),
                        ),
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password Field
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        style: theme.bodyText1,
                        decoration: InputDecoration(
                          labelText: 'Xác nhận mật khẩu mới',
                          labelStyle: theme.bodyText2,
                          prefixIcon: Icon(Icons.lock, color: theme.secondaryText),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.alternate),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.primaryColor, width: 2),
                          ),
                          filled: true,
                          fillColor: theme.secondaryBackground,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: theme.secondaryText,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng xác nhận mật khẩu';
                          }
                          if (value != _newPasswordController.text) {
                            return 'Mật khẩu xác nhận không khớp';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      // Password Requirements
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.secondaryBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Yêu cầu mật khẩu:',
                              style: theme.bodyText2.override(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _buildRequirement(theme, 'Ít nhất 8 ký tự'),
                            _buildRequirement(theme, 'Có ít nhất 1 chữ hoa'),
                            _buildRequirement(theme, 'Có ít nhất 1 chữ thường'),
                            _buildRequirement(theme, 'Có ít nhất 1 số'),
                            _buildRequirement(theme, 'Có ít nhất 1 ký tự đặc biệt (!@#\$%^&*...)'),
                          ],
                        ),
                      ),
                    ],
                  ).animateOnPageLoad(animationsMap['formOnPageLoad']!),
                  const SizedBox(height: 32),

                  // Change Password Button
                  FFButton(
                    onPressed: changePasswordState.isLoading
                        ? null
                        : _handleChangePassword,
                    text: 'Đổi mật khẩu',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 56,
                      color: theme.primaryColor,
                      disabledColor: theme.secondaryText,
                      textStyle: theme.subtitle2.override(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(FlutterFlowTheme theme, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: theme.secondaryText,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.bodyText2.override(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
