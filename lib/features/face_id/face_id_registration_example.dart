import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/face_id_service.dart';
import '../auth/providers/auth_providers.dart';

/// Example screen showing how to use Face ID registration
class FaceIdRegistrationExample extends ConsumerStatefulWidget {
  const FaceIdRegistrationExample({super.key});

  @override
  ConsumerState<FaceIdRegistrationExample> createState() => _FaceIdRegistrationExampleState();
}

class _FaceIdRegistrationExampleState extends ConsumerState<FaceIdRegistrationExample> {
  String _status = 'Ready to register';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    
    // Set up listener for Face ID registration results
    FaceIdService.setFaceIdResultListener((success) {
      setState(() {
        _isProcessing = false;
        if (success) {
          _status = '✅ Face ID registered successfully!';
        } else {
          _status = '❌ Face ID registration failed';
        }
      });
    });
  }

  Future<void> _registerFaceId() async {
    setState(() {
      _isProcessing = true;
      _status = 'Opening Face ID registration...';
    });

    // ✅ Lấy user ID từ login state
    final loginState = ref.read(loginControllerProvider);
    final userId = loginState.user?.id;
    
    if (userId == null || userId.isEmpty) {
      setState(() {
        _isProcessing = false;
        _status = '❌ Error: User not logged in';
      });
      return;
    }
    
    try {
      await FaceIdService.registerFaceId(userId);
      // The result will be received in the listener above
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _status = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face ID Registration'),
        backgroundColor: const Color(0xFF6367F1),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Face ID Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF6367F1).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.face,
                  size: 60,
                  color: Color(0xFF6367F1),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Title
              const Text(
                'Face ID Registration',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Description
              const Text(
                'Register your face for secure and convenient authentication',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Status
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Register Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _registerFaceId,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6367F1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Register Face ID',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Info
              const Text(
                'You will be guided through the registration process',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
