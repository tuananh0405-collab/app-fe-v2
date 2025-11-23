# Tóm tắt các thay đổi: Lấy tọa độ GPS hiện tại và gửi kèm request

## Mục tiêu
Thay vì sử dụng tọa độ fix cứng, hệ thống sẽ lấy tọa độ GPS hiện tại của thiết bị và gửi kèm các thông tin bổ sung (latitude, longitude, location_accuracy, device_id, ip_address) vào request verify face ID.

## Các thay đổi đã thực hiện

### 1. StudentSettingVerifyFaceIdFragment.java
**File**: `android/app/src/main/java/com/example/flutter_application_1/faceid/ui/setting/StudentSettingVerifyFaceIdFragment.java`

#### a) Import thư viện GPS
```java
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
```

#### b) Thêm biến quản lý location
```java
// 📍 LOCATION
private LocationManager locationManager;
private Location currentLocation;
```

#### c) Thêm method lấy GPS hiện tại
```java
/**
 * 📍 Lấy tọa độ GPS hiện tại của thiết bị
 */
private void getCurrentLocation() {
    // Khởi tạo LocationManager
    // Kiểm tra permission
    // Lấy last known location từ GPS và Network provider
    // Chọn location tốt nhất (GPS ưu tiên hơn Network)
}
```

#### d) Cập nhật method performAttendanceCheckIn()
- **Trước**: Lấy tọa độ từ arguments với giá trị fix cứng
```java
double latitude = args.getDouble("latitude", 10.762622);
double longitude = args.getDouble("longitude", 106.660172);
double accuracy = args.getDouble("accuracy", 15.0);
```

- **Sau**: Lấy tọa độ GPS hiện tại
```java
// 📍 Lấy tọa độ GPS hiện tại thay vì dùng giá trị fix cứng
double latitude = 10.762622; // Default fallback
double longitude = 106.660172; // Default fallback
double accuracy = 15.0; // Default fallback

// Lấy tọa độ hiện tại từ GPS nếu có
getCurrentLocation();
if (currentLocation != null) {
    latitude = currentLocation.getLatitude();
    longitude = currentLocation.getLongitude();
    accuracy = currentLocation.getAccuracy();
    Log.d(TAG, "📍 Using current GPS location");
} else {
    Log.w(TAG, "⚠️ GPS location not available, using default coordinates");
}
```

#### e) Cập nhật lời gọi verifyFaceIdForRequest()
- **Trước**: Chỉ gửi userId, requestId, threshold
```java
faceIdService.verifyFaceIdForRequest(faceImage, userId, requestId, null, callback);
```

- **Sau**: Gửi thêm location và device info
```java
faceIdService.verifyFaceIdForRequest(faceImage, 
    userId, 
    requestId, 
    null, // threshold
    finalLatitude, 
    finalLongitude, 
    finalAccuracy,
    finalDeviceId,
    ipAddress,
    callback);
```

### 2. FaceIdApiController.java
**File**: `android/app/src/main/java/com/example/flutter_application_1/faceid/data/api/FaceIdApiController.java`

#### Cập nhật API interface
- **Trước**: Chỉ có userId, embedding, threshold
```java
@POST("api/faceid/requests/{requestId}/verify")
Call<FaceIdVerifyResponse> verifyFaceId(
    @Path("requestId") String requestId,
    @Part("userId") RequestBody userId,
    @Part MultipartBody.Part embedding
);
```

- **Sau**: Thêm các tham số location và device info
```java
@POST("api/faceid/requests/{requestId}/verify")
Call<FaceIdVerifyResponse> verifyFaceId(
    @Path("requestId") String requestId,
    @Part("userId") RequestBody userId,
    @Part MultipartBody.Part embedding,
    @Part("threshold") RequestBody threshold,
    @Part("latitude") RequestBody latitude,
    @Part("longitude") RequestBody longitude,
    @Part("location_accuracy") RequestBody locationAccuracy,
    @Part("device_id") RequestBody deviceId,
    @Part("ip_address") RequestBody ipAddress
);
```

### 3. FaceIdService.java
**File**: `android/app/src/main/java/com/example/flutter_application_1/faceid/data/service/FaceIdService.java`

#### Cập nhật method verifyFaceIdForRequest()
- **Trước**: Chỉ nhận userId, requestId, threshold
```java
public void verifyFaceIdForRequest(Bitmap faceBitmap, String userId, 
                                  String requestId, Float threshold, 
                                  FaceIdCallback callback)
```

- **Sau**: Nhận thêm location và device info
```java
public void verifyFaceIdForRequest(Bitmap faceBitmap, String userId, 
                                  String requestId, Float threshold, 
                                  Double latitude, Double longitude, Double locationAccuracy,
                                  String deviceId, String ipAddress, 
                                  FaceIdCallback callback)
```

#### Tạo RequestBody cho các tham số mới
```java
// 📍 Thêm location và device info
RequestBody latitudePart = latitude != null ?
        RequestBody.create(MediaType.parse("text/plain"), String.valueOf(latitude)) : null;
RequestBody longitudePart = longitude != null ?
        RequestBody.create(MediaType.parse("text/plain"), String.valueOf(longitude)) : null;
RequestBody locationAccuracyPart = locationAccuracy != null ?
        RequestBody.create(MediaType.parse("text/plain"), String.valueOf(locationAccuracy)) : null;
RequestBody deviceIdPart = deviceId != null ?
        RequestBody.create(MediaType.parse("text/plain"), deviceId) : null;
RequestBody ipAddressPart = ipAddress != null ?
        RequestBody.create(MediaType.parse("text/plain"), ipAddress) : null;
```

#### Gọi API với các tham số mới
```java
api.verifyFaceId(requestId, userIdPart, filePart, thresholdPart, 
               latitudePart, longitudePart, locationAccuracyPart, 
               deviceIdPart, ipAddressPart);
```

## Permissions đã có sẵn
Các permission cần thiết đã được khai báo trong AndroidManifest.xml:
- `ACCESS_FINE_LOCATION`
- `ACCESS_COARSE_LOCATION`
- `INTERNET`
- `ACCESS_NETWORK_STATE`

## Luồng hoạt động

1. **Khi bắt đầu verify face**:
   - Fragment gọi `getCurrentLocation()` để lấy tọa độ GPS hiện tại
   - Sử dụng LocationManager để lấy last known location từ GPS và Network provider
   - Chọn location tốt nhất (GPS ưu tiên hơn Network)

2. **Khi gọi API verify**:
   - Truyền tọa độ GPS hiện tại (hoặc giá trị mặc định nếu không có GPS)
   - Truyền device_id (Android ID)
   - Truyền ip_address (hiện tại để null, có thể implement sau)

3. **API nhận được**:
   - userId
   - embedding (face embedding binary)
   - threshold (optional)
   - latitude (tọa độ GPS hiện tại)
   - longitude (tọa độ GPS hiện tại)
   - location_accuracy (độ chính xác GPS)
   - device_id (Android device ID)
   - ip_address (optional)

## Lưu ý
- Nếu không lấy được GPS, hệ thống sẽ sử dụng tọa độ mặc định (10.762622, 106.660172)
- IP address hiện tại để null, có thể implement sau nếu cần
- Location permission đã được kiểm tra trong `checkRequiredPermissions()`
