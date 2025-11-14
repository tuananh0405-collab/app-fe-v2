# Face ID Registration Integration

This document describes how to use the Face ID registration feature that has been integrated from the zentry-app into app-fe-v2.

## Overview

The Face ID feature allows users to register their face biometrics for authentication. This is a native Android implementation that uses TensorFlow Lite models for:
- Face Detection (BlazeFace)
- Face Embedding (FaceNet-512)
- Spoof Detection (Anti-spoofing models)
- Liveness Detection (Eye blink detection)

## Architecture

```
Flutter Layer (Dart)
    ↓ MethodChannel
Android Native Layer
    ↓
Face ID Components:
    - FaceIdService
    - FaceDetector
    - FaceEmbedding
    - FaceSpoofDetector
    - EyeBlinkDetector
    - MediaPipeFaceLandmarkExtractor
```

## Files Structure

### Android Native Code
```
android/app/src/main/
├── assets/
│   ├── blaze_face_short_range.tflite
│   ├── facenet_512.tflite
│   ├── spoof_model_scale_2_7.tflite
│   ├── spoof_model_scale_4_0.tflite
│   └── face_landmarker.task
├── java/com/example/flutter_application_1/
│   ├── faceid/
│   │   ├── data/
│   │   │   ├── service/        # Core services
│   │   │   ├── api/            # API controllers
│   │   │   └── model/          # Data models
│   │   ├── ui/
│   │   │   ├── components/     # Camera, Overlay views
│   │   │   └── setting/        # Registration UI
│   │   └── util/               # Utilities
│   └── auth/
│       ├── AuthManager.java
│       └── client/
│           └── ApiClient.java
└── kotlin/com/example/flutter_application_1/
    └── MainActivity.kt         # MethodChannel setup
```

### Flutter Code
```
lib/core/services/
└── face_id_service.dart        # Dart API for Face ID
```

## Usage

### 1. Register Face ID

```dart
import 'package:app_fe_v2/core/services/face_id_service.dart';

// Register Face ID for a user
Future<void> registerFace(String userId) async {
  bool success = await FaceIdService.registerFaceId(userId);
  if (success) {
    print('Face ID registration started');
  }
}
```

### 2. Listen for Registration Results

```dart
@override
void initState() {
  super.initState();
  
  // Set up listener for Face ID results
  FaceIdService.setFaceIdResultListener((success) {
    if (success) {
      print('Face ID registered successfully!');
      // Navigate to next screen or show success message
    } else {
      print('Face ID registration failed');
      // Show error message
    }
  });
}
```

### 3. Example Widget

```dart
class FaceIdRegistrationButton extends StatelessWidget {
  final String userId;

  const FaceIdRegistrationButton({required this.userId});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await FaceIdService.registerFaceId(userId);
      },
      child: Text('Register Face ID'),
    );
  }
}
```

## Configuration

### API Endpoint

Update the base URL in `ApiClient.java`:

```java
private static final String BASE_URL = "https://your-api-endpoint.com/";
```

### Permissions

The following permissions are required (already added to AndroidManifest.xml):
- `CAMERA` - For capturing face images
- `VIBRATE` - For haptic feedback
- `INTERNET` - For API calls
- `ACCESS_NETWORK_STATE` - For checking network connectivity

### Minimum SDK

The Face ID feature requires **Android API 24 (Android 7.0)** or higher.

## Face Registration Flow

1. User clicks "Register Face ID" button
2. Flutter calls `FaceIdService.registerFaceId(userId)`
3. MainActivity receives the call via MethodChannel
4. Native Android Activity (`StudentSettingRegisterFaceIdActivity`) is launched
5. User follows on-screen instructions:
   - Position face in oval guide
   - Pass liveness detection (blink eyes)
   - Pass spoof detection (real face check)
   - Face stabilization check
6. Face embedding is generated and sent to backend
7. Result is sent back to Flutter via MethodChannel

## Security Features

- **Liveness Detection**: Requires user to blink eyes
- **Spoof Detection**: Detects printed photos, videos, masks
- **Face Stabilization**: Ensures face is stable for quality capture
- **Position Validation**: Face must be within oval guide
- **Multiple Model Validation**: Uses multiple TensorFlow Lite models for accuracy

## Models Used

| Model | Purpose | Size |
|-------|---------|------|
| blaze_face_short_range.tflite | Face detection | ~1MB |
| facenet_512.tflite | Face embedding (512-dim) | ~23MB |
| spoof_model_scale_2_7.tflite | Anti-spoofing (scale 2.7) | ~4MB |
| spoof_model_scale_4_0.tflite | Anti-spoofing (scale 4.0) | ~4MB |
| face_landmarker.task | MediaPipe landmarks | ~10MB |

## Troubleshooting

### Camera not starting
- Check camera permissions are granted
- Ensure device has a camera

### Models not loading
- Verify .tflite files are in `assets/` folder
- Check `aaptOptions` in `build.gradle.kts` includes `.tflite` files

### Network errors
- Update `BASE_URL` in `ApiClient.java`
- Ensure backend API is accessible

### Build errors
- Run `flutter clean` and `flutter pub get`
- Rebuild Android: `cd android && ./gradlew clean`

## Future Enhancements (iOS)

The iOS implementation will be added in a future update. The Flutter API (`FaceIdService`) is designed to work with both platforms.

## Credits

Face ID implementation adapted from zentry-app project.

## License

Proprietary - Internal use only
