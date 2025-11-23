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
import com.example.flutter_application_1.MainActivity;
import io.flutter.plugin.common.MethodChannel;

/**
 * Success Activity cho Face ID Registration/Update
 * Hiển thị màn hình success với UI native
 * 
 * Flow:
 * 1. Hiển thị UI success với thông tin phù hợp (register/update/verify)
 * 2. User nhấn Continue/Back để quay về Flutter
 */
public class FaceIdSuccessActivity extends AppCompatActivity {
    private static final String TAG = "FaceIdSuccessActivity";
    
    private static final String EXTRA_USER_ID = "user_id";
    private static final String EXTRA_SUCCESS_MESSAGE = "success_message";
    private static final String EXTRA_BITMAP_PATH = "bitmap_path";
    private static final String EXTRA_ACTION = "action"; // "register" | "update" | "verify"
    private static final String EXTRA_SHOW_UPDATE_BUTTON = "show_update_button"; // true để hiển thị button update
    private static final String EXTRA_USER_NAME = "user_name"; // Thêm biến mới để lấy tên người dùng
    


    public static Intent createRegisterSuccessIntent(Context context, String userId, String userName, String bitmapPath) {
        Intent intent = new Intent(context, FaceIdSuccessActivity.class);
        intent.putExtra(EXTRA_USER_ID, userId);
        intent.putExtra(EXTRA_USER_NAME, userName);
        intent.putExtra(EXTRA_BITMAP_PATH, bitmapPath);
        intent.putExtra(EXTRA_ACTION, "register");
        intent.putExtra(EXTRA_SHOW_UPDATE_BUTTON, false);
        return intent;
    }
    
    public static Intent createUpdateSuccessIntent(Context context, String userId, String userName, String bitmapPath) {
        Intent intent = new Intent(context, FaceIdSuccessActivity.class);
        intent.putExtra(EXTRA_USER_ID, userId);
        intent.putExtra(EXTRA_USER_NAME, userName);
        intent.putExtra(EXTRA_BITMAP_PATH, bitmapPath);
        intent.putExtra(EXTRA_ACTION, "update");
        intent.putExtra(EXTRA_SHOW_UPDATE_BUTTON, false);
        return intent;
    }
    
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
        if (getIntent() != null && getIntent().getExtras() != null) {
            for (String key : getIntent().getExtras().keySet()) {
                Object value = getIntent().getExtras().get(key);
            }
        }

        setContentView(com.example.flutter_application_1.R.layout.activity_face_id_success);

        // Get data
        String action = getIntent().getStringExtra(EXTRA_ACTION);
        String userName = getIntent().getStringExtra(EXTRA_USER_NAME);
        boolean showUpdateButton = getIntent().getBooleanExtra(EXTRA_SHOW_UPDATE_BUTTON, false);

        // Setup UI
        setupUI(action, userName, showUpdateButton);
    }

    
    /**
     * Setup UI elements based on action type
     */
    private void setupUI(String action, String userName, boolean showUpdateButton) {
        // Find views
        TextView tvSuccessTitle = findViewById(com.example.flutter_application_1.R.id.tvSuccessTitle);
        TextView tvSuccessSubtitle = findViewById(com.example.flutter_application_1.R.id.tvSuccessSubtitle);
        ImageView ivBack = findViewById(com.example.flutter_application_1.R.id.ivBack);
        Button btnContinue = findViewById(com.example.flutter_application_1.R.id.btnContinue);
        Button btnUpdateFaceId = findViewById(com.example.flutter_application_1.R.id.btnUpdateFaceId);
        
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
            btnUpdateFaceId.setVisibility(View.VISIBLE);
            btnUpdateFaceId.setOnClickListener(v -> {
                Log.d(TAG, "Update Face ID button clicked");
                finish();
            });
        }
        
        // Back button - simply close this activity
        if (ivBack != null) {
            ivBack.setOnClickListener(v -> {
                Log.d(TAG, "Back button clicked - returning to Flutter");
                finish();
            });
        }
        
        // Continue button - navigate back to Flutter home
        if (btnContinue != null) {
            btnContinue.setOnClickListener(v -> {
                Log.d(TAG, "Continue button clicked - navigating back to Flutter Home");
                navigateToFlutterHome();
            });
        }
    }
    
    /**
     * Navigate back to Flutter MainActivity (Home screen)
     * Returns to existing MainActivity without clearing app state
     */
    private void navigateToFlutterHome() {
        Intent intent = new Intent(this, MainActivity.class);
        // Use CLEAR_TOP to return to existing MainActivity without restarting the app
        // This preserves login state and app data
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        // Add extra to tell MainActivity to navigate to home screen
        intent.putExtra("navigate_to", "home");
        startActivity(intent);
        finish();
    }
    
    @Override
    protected void onDestroy() {
        super.onDestroy();
    }
}