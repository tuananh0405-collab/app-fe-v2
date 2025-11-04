import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'dart:typed_data';
import '../../../features/profile/providers/profile_providers.dart';
import 'providers/faceid_providers.dart';
import 'state/faceid_state.dart';

class FaceIdRegisterScreen extends ConsumerStatefulWidget {
  const FaceIdRegisterScreen({super.key});

  @override
  ConsumerState<FaceIdRegisterScreen> createState() => _FaceIdRegisterScreenState();
}

class _FaceIdRegisterScreenState extends ConsumerState<FaceIdRegisterScreen> {
  CameraController? _cameraController;
  bool _isInitialized = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize camera: $e')),
        );
      }
    }
  }

  Future<void> _captureFace() async {
    if (_isProcessing || _cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Capture image from camera
      await _cameraController!.takePicture();
      
      // TODO: In production, you would:
      // 1. Detect face in the image using ML Kit or TensorFlow Lite
      // 2. Check for spoof detection
      // 3. Generate face embedding using ML model (512-dimensional vector)
      // 4. Convert embedding to Uint8List
      
      // For now, we'll simulate with mock data
      final mockEmbedding = _generateMockEmbedding();
      
      // Get user ID from profile
      final profileState = ref.read(profileControllerProvider);
      final userId = profileState.profile?.id.toString();
      
      if (userId == null) {
        throw Exception('User ID not found');
      }

      // Register face ID
      await ref.read(faceIdControllerProvider.notifier).registerFaceId(
        embedding: mockEmbedding,
        userId: userId,
      );
      
    } catch (e) {
      debugPrint('Error capturing face: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture face: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // Mock embedding generator (512 floats as Float32)
  Uint8List _generateMockEmbedding() {
    final floats = List.generate(512, (i) => (i / 512.0));
    final byteData = ByteData(512 * 4); // 4 bytes per float
    
    for (int i = 0; i < floats.length; i++) {
      byteData.setFloat32(i * 4, floats[i], Endian.little);
    }
    
    return byteData.buffer.asUint8List();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final faceIdState = ref.watch(faceIdControllerProvider);

    // Listen for state changes
    ref.listen(faceIdControllerProvider, (previous, next) {
      if (previous?.status != next.status) {
        if (next.status == FaceIdStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.message ?? 'Face ID registered successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else if (next.status == FaceIdStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage ?? 'Failed to register Face ID'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Face ID'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Position your face within the oval guide and keep still',
                    style: TextStyle(color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),

          // Camera Preview
          Expanded(
            child: Stack(
              children: [
                // Camera preview
                if (_isInitialized && _cameraController != null)
                  Center(
                    child: AspectRatio(
                      aspectRatio: _cameraController!.value.aspectRatio,
                      child: CameraPreview(_cameraController!),
                    ),
                  )
                else
                  const Center(
                    child: CircularProgressIndicator(),
                  ),

                // Oval guide overlay
                CustomPaint(
                  size: Size.infinite,
                  painter: OvalGuidePainter(),
                ),

                // Processing overlay
                if (_isProcessing || faceIdState.status == FaceIdStatus.loading)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Processing...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Capture button
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _captureFace,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Capture Face',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Make sure your face is well-lit and centered',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for oval guide
class OvalGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = Offset(size.width / 2, size.height / 2);
    final ovalWidth = size.width * 0.7;
    final ovalHeight = size.height * 0.5;

    final rect = Rect.fromCenter(
      center: center,
      width: ovalWidth,
      height: ovalHeight,
    );

    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
