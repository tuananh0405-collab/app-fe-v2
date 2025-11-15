import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'faceid_channel.dart';
import 'features/auth/providers/auth_providers.dart';
import 'flutter_flow/flutter_flow.dart';

class FaceIdPage extends ConsumerStatefulWidget {
  const FaceIdPage({Key? key}) : super(key: key);

  @override
  ConsumerState<FaceIdPage> createState() => _FaceIdPageState();
}

class _FaceIdPageState extends ConsumerState<FaceIdPage>
    with TickerProviderStateMixin, AnimationControllerMixin<FaceIdPage> {
  String _status = 'Idle';

  @override
  void initState() {
    super.initState();
    
    // Setup animations
    setupAnimations({
      'containerOnPageLoad': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effects: FFAnimations.fadeInSlideUp(
          delay: const Duration(milliseconds: 100),
          duration: const Duration(milliseconds: 600),
        ),
      ),
      'buttonOnPageLoad': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effects: FFAnimations.scaleIn(
          delay: const Duration(milliseconds: 300),
          duration: const Duration(milliseconds: 400),
        ),
      ),
    });
    
    FaceIdChannel.onRegistered.listen((success) {
      if (!mounted) return;
      setState(() {
        _status = success ? 'Registered successfully' : 'Registration failed';
      });
      showSnackbar(context, _status);
    });
  }

  Future<void> _openRegister() async {
    // ✅ Lấy user ID từ login state
    final loginState = ref.read(loginControllerProvider);
    final userId = loginState.user?.id;
    
    if (userId == null || userId.isEmpty) {
      setState(() {
        _status = 'Error: User not logged in';
      });
      if (mounted) {
        showSnackbar(context, 'Please login first');
      }
      return;
    }
    
    final started = await FaceIdChannel.registerFace(userId: userId);
    if (!mounted) return;
    setState(() {
      _status = started ? 'Register screen opened' : 'Failed to open native register screen';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: Text(
          'Face ID Registration',
          style: theme.title2.override(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 2,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.face,
                      size: 80,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Face ID Status',
                      style: theme.title3,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _status,
                      style: theme.bodyText1.override(
                        color: theme.secondaryText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    FFButton(
                      onPressed: _openRegister,
                      text: 'Register Face ID',
                      icon: const Icon(Icons.face_retouching_natural, size: 20),
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 56,
                        color: theme.primaryColor,
                        textStyle: theme.subtitle1.override(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        elevation: 2,
                      ),
                    ).animateOnPageLoad(animationsMap['buttonOnPageLoad']!),
                  ],
                ),
              ).animateOnPageLoad(animationsMap['containerOnPageLoad']!),
            ],
          ),
        ),
      ),
    );
  }
}
