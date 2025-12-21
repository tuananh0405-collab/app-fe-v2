package vn.edu.fpt.zentryapp;

import androidx.annotation.Nullable;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import android.content.Intent;
import android.util.Log;

/**
 * Lightweight MainActivity shim so legacy package references to vn.edu.fpt.zentryapp.MainActivity
 * resolve during Java compilation. This simply hosts the Flutter activity.
 */
public class MainActivity extends FlutterActivity {
    private static final String TAG = "MainActivity";
    private static final String FACE_ID_CHANNEL = "com.example.flutter_application_1/faceid";
    private MethodChannel methodChannel;

    @Override
    public void configureFlutterEngine(@Nullable FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        
        // Setup method channel
        methodChannel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), FACE_ID_CHANNEL);
        
        // Check for success data in intent
        checkForSuccessData();
    }
    
    @Override
    protected void onNewIntent(@Nullable Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        checkForSuccessData();
    }
    
    private void checkForSuccessData() {
        Intent intent = getIntent();
        if (intent != null && methodChannel != null) {
            // Check for Face ID success flags
            boolean registerSuccess = intent.getBooleanExtra("face_id_register_success", false);
            boolean updateSuccess = intent.getBooleanExtra("face_id_update_success", false);
            boolean verifySuccess = intent.getBooleanExtra("face_id_verify_success", false);
            
            boolean registerFailed = intent.getBooleanExtra("face_id_register_failed", false);
            boolean updateFailed = intent.getBooleanExtra("face_id_update_failed", false);
            boolean operationFailed = intent.getBooleanExtra("face_id_operation_failed", false);

            if (registerSuccess || updateSuccess || verifySuccess) {
                try {
                    java.util.Map<String, Object> successData = new java.util.HashMap<>();
                    
                    String action = "register";
                    if (updateSuccess) action = "update";
                    else if (verifySuccess) action = "verify";
                    
                    successData.put("action", action);
                    successData.put("success_message", intent.getStringExtra("success_message"));
                    successData.put("user_name", intent.getStringExtra("user_name"));
                    successData.put("user_id", intent.getStringExtra("user_id"));
                    
                    methodChannel.invokeMethod("onFaceIdSuccess", successData);
                    Log.d(TAG, "Sent success data from MainActivity: " + successData);
                    
                    // Clear the intent to avoid duplicate processing
                    intent.removeExtra("face_id_register_success");
                    intent.removeExtra("face_id_update_success");
                    intent.removeExtra("face_id_verify_success");
                    intent.removeExtra("success_message");
                    intent.removeExtra("user_name");
                    intent.removeExtra("user_id");
                    
                } catch (Exception e) {
                    Log.e(TAG, " Failed to send success data from MainActivity", e);
                }
            }

            // Handle failure events
            if (registerFailed || updateFailed || operationFailed) {
                try {
                    java.util.Map<String, Object> errorData = new java.util.HashMap<>();
                    String action = registerFailed ? "register" : (updateFailed ? "update" : "operation");
                    // Use standard keys expected by Flutter: error and message
                    errorData.put("error", action);
                    errorData.put("message", intent.getStringExtra("error_message"));

                    methodChannel.invokeMethod("onFaceIdError", errorData);
                    Log.d(TAG, "Sent failure data from MainActivity: " + errorData);

                    // Clear failure extras
                    intent.removeExtra("face_id_register_failed");
                    intent.removeExtra("face_id_update_failed");
                    intent.removeExtra("face_id_operation_failed");
                    intent.removeExtra("error_message");
                } catch (Exception e) {
                    Log.e(TAG, " Failed to send failure data from MainActivity", e);
                }
            }
        }
    }
}
