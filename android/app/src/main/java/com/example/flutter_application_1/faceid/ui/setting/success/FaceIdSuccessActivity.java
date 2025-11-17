package com.example.flutter_application_1.faceid.ui.setting.success;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import com.example.flutter_application_1.auth.AuthManager;
import io.flutter.plugin.common.MethodChannel;

/**
 * Success Activity cho Face ID Registration/Update
 * Hiển thị màn hình success với UI native và gửi dữ liệu về Flutter để sync state
 * 
 * Flow:
 * 1. Hiển thị UI success với thông tin phù hợp (register/update/verify)
 * 2. Gửi data về Flutter để sync state
 * 3. User nhấn Continue/Back để quay về Flutter
 */
public class FaceIdSuccessActivity extends AppCompatActivity {
    private static final String TAG = "FaceIdSuccessActivity";
    private static final String FACE_ID_CHANNEL = "com.example.flutter_application_1/faceid";
    
    private static final String EXTRA_USER_ID = "user_id";
    private static final String EXTRA_SUCCESS_MESSAGE = "success_message";
    private static final String EXTRA_BITMAP_PATH = "bitmap_path";
    private static final String EXTRA_ACTION = "action"; // "register" | "update" | "status_check"
    private static final String EXTRA_SHOW_UPDATE_BUTTON = "show_update_button"; // true để hiển thị button update
    private static final String EXTRA_USER_NAME = "user_name"; // Thêm biến mới để lấy tên người dùng
    
    public static Intent createIntent(Context context, String userId, String successMessage, String bitmapPath) {
        Intent intent = new Intent(context, FaceIdSuccessActivity.class);
        intent.putExtra(EXTRA_USER_ID, userId);
        intent.putExtra(EXTRA_SUCCESS_MESSAGE, successMessage);
        intent.putExtra(EXTRA_BITMAP_PATH, bitmapPath);
        intent.putExtra(EXTRA_ACTION, "register");
        intent.putExtra(EXTRA_SHOW_UPDATE_BUTTON, false); // Sau khi đăng ký thành công, không hiển thị button update
        return intent;
    }

    public static Intent createIntent(Context context, String userId, String successMessage, String bitmapPath, String action) {
        Intent intent = createIntent(context, userId, successMessage, bitmapPath);
        intent.putExtra(EXTRA_ACTION, action);
        // ✅ FIX: Hiển thị button update khi update thành công, chỉ ẩn khi đăng ký thành công
        boolean showUpdateButton = !"register".equals(action); // Hiển thị button update cho update và verify, ẩn cho register
        intent.putExtra(EXTRA_SHOW_UPDATE_BUTTON, showUpdateButton);
        return intent;
    }
    
    // ✅ NEW: Intent cho kiểm tra trạng thái (có button update)
    public static Intent createStatusCheckIntent(Context context, String userId, String successMessage) {
        Intent intent = new Intent(context, FaceIdSuccessActivity.class);
        intent.putExtra(EXTRA_USER_ID, userId);
        intent.putExtra(EXTRA_SUCCESS_MESSAGE, successMessage);
        intent.putExtra(EXTRA_ACTION, "status_check");
        intent.putExtra(EXTRA_SHOW_UPDATE_BUTTON, true); // Hiển thị button update khi kiểm tra trạng thái
        return intent;
    }
    
    // ✅ NEW: Intent cho đăng ký thành công với userName
    public static Intent createRegisterSuccessIntent(Context context, String userId, String userName, String bitmapPath) {
        Intent intent = new Intent(context, FaceIdSuccessActivity.class);
        intent.putExtra(EXTRA_USER_ID, userId);
        intent.putExtra(EXTRA_USER_NAME, userName);
        intent.putExtra(EXTRA_BITMAP_PATH, bitmapPath);
        intent.putExtra(EXTRA_ACTION, "register");
        intent.putExtra(EXTRA_SHOW_UPDATE_BUTTON, false);
        return intent;
    }
    
    // ✅ NEW: Intent cho cập nhật thành công với userName
    public static Intent createUpdateSuccessIntent(Context context, String userId, String userName, String bitmapPath) {
        Intent intent = new Intent(context, FaceIdSuccessActivity.class);
        intent.putExtra(EXTRA_USER_ID, userId);
        intent.putExtra(EXTRA_USER_NAME, userName);
        intent.putExtra(EXTRA_BITMAP_PATH, bitmapPath);
        intent.putExtra(EXTRA_ACTION, "update");
        intent.putExtra(EXTRA_SHOW_UPDATE_BUTTON, false);
        return intent;
    }
    
    // ✅ NEW: Intent cho xác thực thành công với userName
    public static Intent createVerifySuccessIntent(Context context, String userId, String userName) {
        Intent intent = new Intent(context, FaceIdSuccessActivity.class);
        intent.putExtra(EXTRA_USER_ID, userId);
        intent.putExtra(EXTRA_USER_NAME, userName);
        intent.putExtra(EXTRA_ACTION, "verify");
        intent.putExtra(EXTRA_SHOW_UPDATE_BUTTON, false);
        return intent;
    }
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        // 🔧 DEBUG: Log intent extras để debug
        Log.d(TAG, "🔍 Intent extras:");
        if (getIntent() != null && getIntent().getExtras() != null) {
            for (String key : getIntent().getExtras().keySet()) {
                Object value = getIntent().getExtras().get(key);
                Log.d(TAG, "  " + key + " = " + value + " (" + (value != null ? value.getClass().getSimpleName() : "null") + ")");
            }
        }
        
        // ✅ UPDATED: Hiển thị UI success trước khi về Flutter
        Log.d(TAG, "🎯 Face ID success - showing success screen");
        
        // Inflate layout để hiển thị UI success
        setContentView(com.example.flutter_application_1.R.layout.activity_face_id_success);
        
        // Lấy thông tin từ intent
        String action = getIntent().getStringExtra(EXTRA_ACTION);
        String userName = getIntent().getStringExtra(EXTRA_USER_NAME);
        boolean showUpdateButton = getIntent().getBooleanExtra(EXTRA_SHOW_UPDATE_BUTTON, false);
        
        // Setup UI elements
        setupUI(action, userName, showUpdateButton);
        
        // Gửi dữ liệu về Flutter (để sync state)
        sendSuccessDataToFlutter();
    }
    
    /**
     * Setup UI elements based on action type
     */
    private void setupUI(String action, String userName, boolean showUpdateButton) {
        // Find views
        android.widget.TextView tvSuccessTitle = findViewById(com.example.flutter_application_1.R.id.tvSuccessTitle);
        android.widget.TextView tvSuccessSubtitle = findViewById(com.example.flutter_application_1.R.id.tvSuccessSubtitle);
        android.widget.ImageView ivBack = findViewById(com.example.flutter_application_1.R.id.ivBack);
        android.widget.Button btnContinue = findViewById(com.example.flutter_application_1.R.id.btnContinue);
        android.widget.Button btnUpdateFaceId = findViewById(com.example.flutter_application_1.R.id.btnUpdateFaceId);
        
        // Set text based on action
        if ("register".equals(action)) {
            tvSuccessTitle.setText("Face ID Registered Successfully!");
            tvSuccessSubtitle.setText("Now you can use your Face ID for quick and secure verification.");
        } else if ("update".equals(action)) {
            tvSuccessTitle.setText("Face ID Updated Successfully!");
            tvSuccessSubtitle.setText("Your Face ID has been updated. You can now use it for verification.");
        } else if ("verify".equals(action)) {
            tvSuccessTitle.setText("Verification Successful!");
            tvSuccessSubtitle.setText("Welcome back" + (userName != null ? ", " + userName : "") + "!");
        }
        
        // Show/hide update button
        if (showUpdateButton && btnUpdateFaceId != null) {
            btnUpdateFaceId.setVisibility(android.view.View.VISIBLE);
            btnUpdateFaceId.setOnClickListener(v -> {
                // Navigate to update Face ID screen
                Log.d(TAG, "Update Face ID button clicked");
                // TODO: Navigate to update screen
                finish();
            });
        }
        
        // Back button
        if (ivBack != null) {
            ivBack.setOnClickListener(v -> {
                finish();
            });
        }
        
        // Continue button
        if (btnContinue != null) {
            btnContinue.setOnClickListener(v -> {
                Log.d(TAG, "Continue button clicked - finishing activity");
                finish();
            });
        }
    }
    
    private void sendSuccessDataToFlutter() {
        // Tạo intent implicit để quay về MainActivity (Flutter) với dữ liệu success
        // Sử dụng package name của app để đảm bảo start đúng activity
        Intent flutterIntent = new Intent();
        flutterIntent.setClassName(this, "com.example.flutter_application_1.MainActivity");
        flutterIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        
        // Thêm dữ liệu success để Flutter xử lý
        String action = getIntent().getStringExtra(EXTRA_ACTION);
        String userId = getIntent().getStringExtra(EXTRA_USER_ID);
        String userName = getIntent().getStringExtra(EXTRA_USER_NAME);
        
        // Support both success and failure flows.
        boolean isFailure = getIntent().getBooleanExtra("is_failure", false);
        String errorMessage = getIntent().getStringExtra("error_message");

        if (isFailure) {
            // Send a failure event to Flutter so it can show a failure message and navigate back
            if ("update".equals(action)) {
                flutterIntent.putExtra("face_id_update_failed", true);
            } else if ("register".equals(action)) {
                flutterIntent.putExtra("face_id_register_failed", true);
            } else {
                flutterIntent.putExtra("face_id_operation_failed", true);
            }
            if (errorMessage != null) {
                flutterIntent.putExtra("error_message", errorMessage);
            }
            flutterIntent.putExtra("navigate_to", "face_id_failure");
        } else {
            if ("register".equals(action)) {
                flutterIntent.putExtra("face_id_register_success", true);
                flutterIntent.putExtra("success_message", "Face ID registered successfully!");
                flutterIntent.putExtra("navigate_to", "face_id_success");
            } else if ("update".equals(action)) {
                flutterIntent.putExtra("face_id_update_success", true);
                flutterIntent.putExtra("success_message", "Face ID updated successfully!");
                flutterIntent.putExtra("navigate_to", "face_id_success");
            } else if ("verify".equals(action)) {
                flutterIntent.putExtra("face_id_verify_success", true);
                flutterIntent.putExtra("success_message", "Face ID verification successful!");
                flutterIntent.putExtra("navigate_to", "face_id_success");
            }
        }
        
        // Thêm thông tin user nếu có
        if (userId != null) {
            flutterIntent.putExtra("user_id", userId);
        }

        Log.d(TAG, "📤 Sending success data to Flutter - Action: " + action + ", User: " + userId);
        startActivity(flutterIntent);
    }
    
    @Override
    protected void onDestroy() {
        super.onDestroy();
    }
}
