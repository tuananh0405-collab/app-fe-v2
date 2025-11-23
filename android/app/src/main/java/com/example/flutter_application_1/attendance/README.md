# 📦 Attendance Package

## Overview

This package implements the **3-step attendance check-in flow** as documented in the backend API specifications.

## Package Structure

```
attendance/
├── data/
│   ├── api/
│   │   └── AttendanceApiController.java       // Retrofit API interface
│   ├── model/
│   │   ├── request/
│   │   │   ├── ValidateBeaconRequest.java     // Step 1 request
│   │   │   └── RequestFaceVerificationRequest.java  // Step 2 request
│   │   └── response/
│   │       ├── ValidateBeaconResponse.java    // Step 1 response
│   │       └── RequestFaceVerificationResponse.java // Step 2 response
│   └── service/
│       └── AttendanceService.java             // Main orchestrator
```

## The 3-Step Flow

### Step 1: Beacon Validation 📡
- Validates BLE beacon proximity
- Returns session token (5 min TTL)
- Endpoint: `POST /api/v1/attendance/attendance-check/validate-beacon`

### Step 2: Request Face Verification 📍
- Validates GPS location
- Creates attendance check record
- Endpoint: `POST /api/v1/attendance/attendance-check/request-face-verification`

### Step 3: Upload Face Image 📸
- Uploads captured face image
- Verifies face with AI
- Endpoint: `POST /api/face-id/attendance/verify`

## Usage

### Quick Start

```java
import com.example.flutter_application_1.attendance.data.service.AttendanceService;

// Initialize service
AttendanceService service = new AttendanceService(context);

// Perform complete check-in
service.performCheckIn(
    beaconUuid, beaconMajor, beaconMinor, rssi,
    latitude, longitude, accuracy,
    deviceId,
    faceImage,
    new AttendanceService.AttendanceCallback<String>() {
        @Override
        public void onSuccess(String result) {
            //  Check-in successful
        }
        
        @Override
        public void onFailure(String error) {
            //  Check-in failed
        }
    }
);
```

### Step-by-Step

```java
// Step 1: Validate Beacon
service.validateBeacon(uuid, major, minor, rssi, callback);

// Step 2: Request Face Verification
service.requestFaceVerification(
    "check_in", latitude, longitude, accuracy, deviceId, callback);

// Step 3: Upload Face Image
service.uploadFaceImage(faceImage, "check_in", callback);
```

## API Endpoints

| Step | Method | Endpoint | Auth |
|------|--------|----------|------|
| 1 | POST | `/api/v1/attendance/attendance-check/validate-beacon` | Bearer |
| 2 | POST | `/api/v1/attendance/attendance-check/request-face-verification` | Bearer |
| 3 | POST | `/api/face-id/attendance/verify` | None |

## Dependencies

- Retrofit 2.9.0
- Gson converter
- OkHttp logging interceptor
- AuthManager (for JWT tokens)
- FaceIdApiController (for Step 3)

## Integration

See `HOW_TO_TRIGGER_ATTENDANCE_FLOW.md` for complete integration guide.

## Documentation

- `CLIENT_API_SEQUENCE.md` - API call sequence
- `CLIENT_ATTENDANCE_FLOW.md` - Attendance flow details
- `ANDROID_ATTENDANCE_IMPLEMENTATION.md` - Implementation guide
- `ATTENDANCE_FLOW_DIAGRAM.md` - Visual diagrams
- `QUICK_REFERENCE.md` - Quick reference
- `HOW_TO_TRIGGER_ATTENDANCE_FLOW.md` - Usage guide
