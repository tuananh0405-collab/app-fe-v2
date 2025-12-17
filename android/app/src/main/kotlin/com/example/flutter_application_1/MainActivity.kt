package com.example.flutter_application_1

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.flutter_application_1/faceid"
    private val FACE_ID_REGISTER_REQUEST = 1001

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "saveUserInfo" -> {
                    val userId = call.argument<String>("userId")
                    val employeeId = call.argument<String>("employeeId")
                    val userName = call.argument<String>("userName")
                    val authToken = call.argument<String>("authToken")
                    val refreshToken = call.argument<String>("refreshToken")

                    if (userId != null) {
                        // Save to SharedPreferences via AuthManager
                        val authManager = com.example.flutter_application_1.auth.AuthManager.getInstance(this)
                        authManager.setUserId(userId)
                        if (employeeId != null) authManager.setEmployeeId(employeeId)
                        if (userName != null) authManager.setCurrentUserName(userName)
                        if (authToken != null) authManager.setAuthToken(authToken)
                        if (refreshToken != null) authManager.setRefreshToken(refreshToken)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "userId is required", null)
                    }
                }
                "registerFaceId" -> {
                    val userId = call.argument<String>("userId")
                    if (userId != null) {
                        registerFaceId(userId)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "userId is required", null)
                    }
                }
                "verifyFaceId" -> {
                    val userId = call.argument<String>("userId")
                    if (userId != null) {
                        verifyFaceId(userId)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "userId is required", null)
                    }
                }
                "updateFaceId" -> {
                    val userId = call.argument<String>("userId")
                    if (userId != null) {
                        // Implement update if needed later
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "userId is required", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun registerFaceId(userId: String) {
        try {
            val intent = Intent(this, Class.forName("com.example.flutter_application_1.faceid.ui.setting.FaceRegisterActivity"))
            intent.putExtra("userId", userId)
            startActivityForResult(intent, FACE_ID_REGISTER_REQUEST)
        } catch (e: ClassNotFoundException) {
            e.printStackTrace()
        }
    }

    private fun verifyFaceId(userId: String) {
        try {
            val intent = Intent(this, Class.forName("com.example.flutter_application_1.faceid.ui.setting.FaceVerifyActivity"))
            intent.putExtra("userId", userId)
            // We don't necessarily need a result for verification in this flow, but we can add it if needed
            startActivity(intent)
        } catch (e: ClassNotFoundException) {
            e.printStackTrace()
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        
        if (requestCode == FACE_ID_REGISTER_REQUEST) {
            // Notify Flutter about the result
            val channel = MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
            if (resultCode == RESULT_OK) {
                // Check if there's an error in the intent
                val error = data?.getStringExtra("error")
                val message = data?.getStringExtra("message")
                
                if (error != null) {
                    // Error case (e.g., ALREADY_REGISTERED)
                    channel.invokeMethod("onFaceIdError", mapOf(
                        "error" to error,
                        "message" to message
                    ))
                } else {
                    // Success case
                    channel.invokeMethod("onFaceIdRegistered", mapOf("success" to true))
                }
            } else {
                channel.invokeMethod("onFaceIdRegistered", mapOf("success" to false))
            }
        }
    }
}
