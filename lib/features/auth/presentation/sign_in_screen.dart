import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/routes.dart';
import '../providers/auth_providers.dart';
import '../../../flutter_flow/flutter_flow.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen>
    with TickerProviderStateMixin, AnimationControllerMixin<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    
    // Setup animations
    setupAnimations({
      'logoOnPageLoad': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effects: FFAnimations.scaleIn(
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      ref.read(loginControllerProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginControllerProvider);

    // Listen for authentication success
    ref.listen(loginControllerProvider, (previous, next) {
      if (previous == null || next == previous) return;
      
      if (next.isAuthenticated) {
        context.go(AppRoutePath.home);
      } else if (next.isTemporaryPassword) {
        // Navigate to change password screen
        showSnackbar(
          context,
          next.errorMessage ?? 'Bạn cần đổi mật khẩu tạm',
        );
        // context.go('/change-password');
      } else if (next.errorMessage != null) {
        showSnackbar(context, next.errorMessage!);
      }
    });

    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
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
                  // Logo or App Name
                  Icon(
                    Icons.lock_outline,
                    size: 80,
                    color: theme.primaryColor,
                  ).animateOnPageLoad(animationsMap['logoOnPageLoad']!),
                  const SizedBox(height: 24),
                  Text(
                    'Đăng nhập',
                    style: theme.title1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: theme.bodyText1,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: theme.bodyText2,
                      prefixIcon: Icon(Icons.email_outlined, color: theme.secondaryText),
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
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: theme.bodyText1,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
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
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: theme.secondaryText,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Login Button
                  FFButton(
                    onPressed: loginState.isLoading ? null : _handleLogin,
                    text: 'Đăng nhập',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 56,
                      color: theme.primaryColor,
                      disabledColor: theme.secondaryText,
                      textStyle: theme.subtitle1.override(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      elevation: 2,
                    ),
                  ),
                  
                  if (loginState.isLoading)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: FFLoadingIndicator(
                        size: 40,
                        color: theme.primaryColor,
                      ),
                    ),
                ],
              ).animateOnPageLoad(animationsMap['formOnPageLoad']!),
            ),
          ),
        ),
      ),
    );
  }
}

