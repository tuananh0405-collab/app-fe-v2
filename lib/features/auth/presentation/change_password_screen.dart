import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/routes.dart';
import '../providers/auth_providers.dart';
import '../../../flutter_flow/flutter_flow.dart';
import '../../../core/localization/auth_localizations.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  final bool isTemporary;

  const ChangePasswordScreen({super.key, this.isTemporary = false});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen>
    with
        TickerProviderStateMixin,
        AnimationControllerMixin<ChangePasswordScreen> {
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
      if (widget.isTemporary) {
        // Use temporary password change endpoint
        ref
            .read(changePasswordControllerProvider.notifier)
            .changeTemporaryPassword(
              currentPassword: _currentPasswordController.text,
              newPassword: _newPasswordController.text,
              confirmPassword: _confirmPasswordController.text,
            );
      } else {
        // Use regular password change endpoint
        ref
            .read(changePasswordControllerProvider.notifier)
            .changePassword(
              currentPassword: _currentPasswordController.text,
              newPassword: _newPasswordController.text,
            );
      }
    }
  }

  String? _validatePassword(String? value, AuthLocalizations authLoc) {
    if (value == null || value.isEmpty) {
      return authLoc.pleaseEnterPassword;
    }
    if (value.length < 8) {
      return authLoc.passwordMin8Chars;
    }
    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return authLoc.passwordNeedUppercase;
    }
    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return authLoc.passwordNeedLowercase;
    }
    // Check for at least one digit
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return authLoc.passwordNeedNumber;
    }
    // Check for at least one special character
    if (!RegExp(r'[!@#\\$%^\\&*(),.?\":{}|<>]').hasMatch(value)) {
      return authLoc.passwordNeedSpecialChar;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final changePasswordState = ref.watch(changePasswordControllerProvider);
    final authLoc = AuthLocalizations(Localizations.localeOf(context));

    // Listen for password change success
    ref.listen(changePasswordControllerProvider, (previous, next) {
      if (previous == null || next == previous) return;

      if (next.isSuccess) {
        final message = widget.isTemporary
            ? authLoc.passwordChangedLoginAgain
            : authLoc.passwordChangedSuccess;

        showSnackbar(context, message);

        if (widget.isTemporary) {
          // Clear login state and navigate to login
          ref.read(loginControllerProvider.notifier).reset();
          context.go(AppRoutePath.signIn);
        } else {
          // Just go back to profile
          context.pop();
        }
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
          widget.isTemporary ? authLoc.changeTemporaryPassword : authLoc.changePassword,
          style: theme.title2.override(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 2,
        automaticallyImplyLeading: !widget.isTemporary,
        leading: widget.isTemporary
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
              ),
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
                      if (widget.isTemporary) ...[
                        Text(
                          authLoc.usingTemporaryPassword,
                          style: theme.title3,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          authLoc.pleaseChangePassword,
                          style: theme.bodyText2,
                          textAlign: TextAlign.center,
                        ),
                      ] else ...[
                        Text(
                          authLoc.changePassword,
                          style: theme.title3,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          authLoc.enterCurrentAndNew,
                          style: theme.bodyText2,
                          textAlign: TextAlign.center,
                        ),
                      ],
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
                          labelText: authLoc.currentPassword,
                          labelStyle: theme.bodyText2,
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: theme.secondaryText,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.alternate),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.primaryColor,
                              width: 2,
                            ),
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
                                _obscureCurrentPassword =
                                    !_obscureCurrentPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return authLoc.pleaseEnterCurrentPassword;
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
                          labelText: authLoc.newPassword,
                          labelStyle: theme.bodyText2,
                          prefixIcon: Icon(
                            Icons.lock,
                            color: theme.secondaryText,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.alternate),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.primaryColor,
                              width: 2,
                            ),
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
                        validator: (value) => _validatePassword(value, authLoc),
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password Field (only for temporary password)
                      if (widget.isTemporary) ...[
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          style: theme.bodyText1,
                          decoration: InputDecoration(
                            labelText: authLoc.confirmPassword,
                            labelStyle: theme.bodyText2,
                            prefixIcon: Icon(
                              Icons.lock,
                              color: theme.secondaryText,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: theme.alternate),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: theme.primaryColor,
                                width: 2,
                              ),
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
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return authLoc.pleaseConfirmPassword;
                            }
                            if (value != _newPasswordController.text) {
                              return authLoc.passwordsDoNotMatch;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                      ],

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
                              authLoc.passwordRequirements,
                              style: theme.bodyText2.override(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _buildRequirement(theme, authLoc.requirementMinLength),
                            _buildRequirement(theme, authLoc.requirementUppercase),
                            _buildRequirement(theme, authLoc.requirementLowercase),
                            _buildRequirement(theme, authLoc.requirementNumber),
                            _buildRequirement(theme, authLoc.requirementSpecialChar),
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
                    text: authLoc.changePassword,
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
            child: Text(text, style: theme.bodyText2.override(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
