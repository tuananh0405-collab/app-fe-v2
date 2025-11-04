# Face ID Registration Feature

## Tổng quan
Feature Face ID Registration cho phép người dùng đăng ký khuôn mặt của họ để xác thực bảo mật.

## Cấu trúc

```
lib/features/faceid/
├── data/
│   ├── datasources/
│   │   └── faceid_remote_datasource.dart     # API calls to backend
│   ├── models/
│   │   ├── face_detection_result.dart        # Face detection result model
│   │   └── faceid_response_model.dart        # API response model
│   └── repositories/
│       └── faceid_repository_impl.dart       # Repository implementation
├── domain/
│   ├── repositories/
│   │   └── faceid_repository.dart            # Repository interface
│   └── usecases/
│       ├── register_faceid_usecase.dart      # Register Face ID use case
│       └── update_faceid_usecase.dart        # Update Face ID use case
└── presentation/
    ├── controllers/
    │   └── faceid_controller.dart            # State management
    ├── providers/
    │   └── faceid_providers.dart             # Riverpod providers
    ├── state/
    │   └── faceid_state.dart                 # Face ID state
    └── faceid_register_screen.dart           # UI screen
```

## API Endpoints

### Register Face ID
```
POST /api/faceid/register
Content-Type: multipart/form-data

Parameters:
- embedding: MultipartFile (binary file, 512 floats as Float32 little-endian)
- userId: String
```

### Update Face ID
```
PUT /api/faceid/update
Content-Type: multipart/form-data

Parameters:
- embedding: MultipartFile (binary file, 512 floats as Float32 little-endian)
- userId: String
```

### Verify Face ID
```
POST /api/faceid/verify/{requestId}
Content-Type: multipart/form-data

Parameters:
- embedding: MultipartFile (binary file, 512 floats as Float32 little-endian)
- userId: String
- threshold: Double (optional)
```

## Cách sử dụng

### 1. Navigation
Từ Profile Screen, nhấn vào "Face ID Registration":
```dart
context.push(AppRoutePath.faceIdRegister);
```

### 2. Register Flow
1. Camera sẽ tự động khởi tạo với front camera
2. Người dùng đặt mặt vào trong oval guide
3. Nhấn "Capture Face" để chụp
4. Hệ thống sẽ:
   - Detect face (TODO: cần implement ML model)
   - Check spoof detection (TODO: cần implement)
   - Generate embedding (TODO: cần implement ML model)
   - Gửi lên server

### 3. Mock Data
Hiện tại đang sử dụng mock embedding (512 floats) cho testing.
Trong production, bạn cần:

```dart
// 1. Face Detection using Google ML Kit
import 'package:google_ml_kit/google_ml_kit.dart';

final faceDetector = FaceDetector(options: FaceDetectorOptions());
final faces = await faceDetector.processImage(inputImage);

// 2. Generate embedding using TensorFlow Lite
import 'package:tflite_flutter/tflite_flutter.dart';

final interpreter = await Interpreter.fromAsset('facenet_model.tflite');
final embedding = generateEmbedding(interpreter, faceImage);

// 3. Convert to Uint8List
final byteData = ByteData(embedding.length * 4);
for (int i = 0; i < embedding.length; i++) {
  byteData.setFloat32(i * 4, embedding[i], Endian.little);
}
final embeddingBytes = byteData.buffer.asUint8List();
```

## Permissions

### Android
Đã thêm vào `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" android:required="false" />
<uses-feature android:name="android.hardware.camera.front" android:required="false" />
```

### iOS
Đã thêm vào `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to register your Face ID for secure authentication</string>
```

## Dependencies
```yaml
dependencies:
  camera: ^0.11.0+2
  http_parser: ^4.0.2
```

## Error Handling

Feature này đã implement error handling cho:
- ✅ Network errors
- ✅ Authentication errors  
- ✅ Server errors
- ✅ Camera initialization errors
- ✅ Automatic fallback từ register → update khi user đã có Face ID

## TODO - Production Ready Checklist

### High Priority
- [ ] Implement face detection using Google ML Kit hoặc TensorFlow Lite
- [ ] Implement spoof detection (liveness detection)
- [ ] Implement face embedding generation (FaceNet hoặc ArcFace model)
- [ ] Add proper error messages (i18n)
- [ ] Add loading states và progress indicators
- [ ] Test với real API backend

### Medium Priority  
- [ ] Add face position guidance (move left, right, closer, further)
- [ ] Add lighting condition check
- [ ] Implement retry mechanism with better UX
- [ ] Add face quality check
- [ ] Store embedding securely (encrypted storage)

### Low Priority
- [ ] Add face registration tutorial/onboarding
- [ ] Add analytics events
- [ ] Add accessibility features
- [ ] Support multiple face angles
- [ ] Add face comparison confidence score display

## Testing

```bash
# Run tests
flutter test

# Run app in debug mode
flutter run

# Build for Android
flutter build apk --release

# Build for iOS
flutter build ios --release
```

## Notes

1. **Security**: Embedding data được gửi qua HTTPS và nên được mã hóa
2. **Privacy**: Cần thông báo rõ ràng cho user về việc thu thập dữ liệu khuôn mặt
3. **Performance**: Face detection và embedding generation nên chạy trên background thread
4. **Storage**: Không lưu raw image, chỉ lưu embedding vector
5. **Compliance**: Đảm bảo tuân thủ GDPR, CCPA và các quy định về dữ liệu sinh trắc học

## Support
Nếu có vấn đề, vui lòng tạo issue hoặc liên hệ team development.
