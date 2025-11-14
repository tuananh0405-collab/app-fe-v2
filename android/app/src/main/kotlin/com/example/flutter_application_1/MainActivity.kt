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
                    val userName = call.argument<String>("userName")
                    val authToken = call.argument<String>("authToken")
                    
                    if (userId != null) {
                        // Save to SharedPreferences via AuthManager
                        val authManager = com.example.flutter_application_1.auth.AuthManager.getInstance(this)
                        authManager.setUserId(userId)
                        if (userName != null) authManager.setCurrentUserName(userName)
                        if (authToken != null) authManager.setAuthToken(authToken)
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
                        // Implement verify if needed later
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
            val intent = Intent(this, Class.forName("com.example.flutter_application_1.faceid.ui.setting.StudentSettingRegisterFaceIdActivity"))
            intent.putExtra("userId", userId)
            startActivityForResult(intent, FACE_ID_REGISTER_REQUEST)
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
                channel.invokeMethod("onFaceIdRegistered", mapOf("success" to true))
            } else {
                channel.invokeMethod("onFaceIdRegistered", mapOf("success" to false))
            }
        }
    }
}
