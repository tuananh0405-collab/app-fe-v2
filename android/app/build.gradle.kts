plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.flutter_application_1"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.flutter_application_1"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24  // Face ID requires minimum SDK 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        debug {
            buildConfigField("boolean", "DEBUG", "true")
        }
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    
    // Enable ViewBinding and BuildConfig for Face ID UI
    buildFeatures {
        viewBinding = true
        buildConfig = true
    }
    
    // Prevent compression of TensorFlow Lite models
    aaptOptions {
        noCompress("tflite", "task")
    }
}

flutter {
    source = "../.."
}

dependencies {
    // AndroidX Core Libraries
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
    implementation("com.google.android.material:material:1.11.0")
    implementation("androidx.activity:activity-ktx:1.8.2")
    
    // Face ID dependencies - TensorFlow Lite
    implementation("com.google.ai.edge.litert:litert:1.1.2")
    implementation("com.google.ai.edge.litert:litert-gpu:1.1.2")
    implementation("com.google.ai.edge.litert:litert-gpu-api:1.1.2")
    implementation("com.google.ai.edge.litert:litert-support:1.1.2")
    implementation("com.google.mediapipe:tasks-vision:0.10.14")
    
    // CameraView for Face ID
    implementation("com.otaliastudios:cameraview:2.7.2")
    
    // Retrofit for API calls
    implementation("com.squareup.retrofit2:retrofit:2.9.0")
    implementation("com.squareup.retrofit2:converter-gson:2.9.0")
    
    // OkHttp for HTTP client
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
    implementation("com.squareup.okhttp3:logging-interceptor:4.12.0")
    
    // Gson for JSON parsing
    implementation("com.google.code.gson:gson:2.10.1")
    
    // Lombok for cleaner code
    compileOnly("org.projectlombok:lombok:1.18.30")
    annotationProcessor("org.projectlombok:lombok:1.18.30")
    
    // Lottie for animations
    implementation("com.airbnb.android:lottie:6.4.0")
    
    // AndroidX Work Manager for background tasks
    implementation("androidx.work:work-runtime:2.8.1")
}
