import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../flutter_flow/flutter_flow.dart';
import '../providers/auth_providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with TickerProviderStateMixin, AnimationControllerMixin<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      ref.read(forgotPasswordControllerProvider.notifier).forgotPassword(
            _emailController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordControllerProvider);
    final theme = FlutterFlowTheme.of(context);

    ref.listen(forgotPasswordControllerProvider, (previous, next) {
      if (next.errorMessage != null) {
        showSnackbar(context, next.errorMessage!);
      }
      if (next.isSuccess) {
        showSnackbar(context, 'Mật khẩu mới đã được gửi vào email của bạn');
        context.pop();
        ref.read(forgotPasswordControllerProvider.notifier).reset();
      }
    });

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: theme.primaryText,
            size: 30,
          ),
          onPressed: () => context.pop(),
        ),
        elevation: 0,
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
                  Icon(
                    Icons.lock_reset,
                    size: 80,
                    color: theme.primaryColor,
                  ).animateOnPageLoad(animationsMap['logoOnPageLoad']!),
                  const SizedBox(height: 24),
                  Text(
                    'Quên mật khẩu',
                    style: theme.title1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Nhập email của bạn để nhận mật khẩu mới',
                    style: theme.bodyText2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
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
                  const SizedBox(height: 32),
                  FFButton(
                    onPressed: state.isLoading ? null : _handleSubmit,
                    text: 'Gửi yêu cầu',
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
                  if (state.isLoading)
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
