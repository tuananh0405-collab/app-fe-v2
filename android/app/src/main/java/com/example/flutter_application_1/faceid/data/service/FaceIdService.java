package com.example.flutter_application_1.faceid.data.service;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Rect;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;

import com.example.flutter_application_1.BuildConfig;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.io.File;
import java.io.FileOutputStream;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;

import lombok.Getter;
import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.RequestBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import com.example.flutter_application_1.auth.client.ApiClient;
import com.example.flutter_application_1.auth.AuthManager;
import com.example.flutter_application_1.faceid.data.api.FaceIdApiController;
import com.example.flutter_application_1.faceid.data.model.response.FaceIdResponse;
import com.example.flutter_application_1.faceid.data.model.response.FaceIdVerifyResponse;


public class FaceIdService {
    private static final String TAG = "FaceIdService";
    
    private final Context context;
    private FaceDetector faceDetector;
    private FaceEmbedding faceEmbedding;
    private AuthManager authManager;

    private FaceSpoofDetector faceSpoofDetector;

    private GazeEstimator gazeEstimator; // Add GazeEstimator field

    // 🔧 NEW: MediaPipe FaceLandmarkExtractor for real landmark detection
    private MediaPipeFaceLandmarkExtractor mediaPipeFaceLandmarkExtractor;

    // Explicit getters to avoid relying on Lombok during Android/Gradle compile
    public FaceSpoofDetector getFaceSpoofDetector() {
        return this.faceSpoofDetector;
    }

    public GazeEstimator getGazeEstimator() {
        return this.gazeEstimator;
    }

    public MediaPipeFaceLandmarkExtractor getMediaPipeFaceLandmarkExtractor() {
        return this.mediaPipeFaceLandmarkExtractor;
    }

    private final FaceIdApiController faceIdApiController;
    private final ExecutorService executor;
    private final Handler mainHandler;
    
    // 🔧 NEW: Improved components
    private final FaceDecisionEngine decisionEngine;
    private final ModelRetryManager retryManager;
    private final FaceProcessingErrorHandler errorHandler;
    
    // 🔧 NEW: Memory, Performance, and Configuration Management
    private final FaceIdConfig configManager;
    private final FaceIdMemoryManager memoryManager;
    private final FaceIdPerformanceManager performanceManager;
    
    private final CountDownLatch modelLoadLatch = new CountDownLatch(5); // Update to 5 models (added MediaPipeFaceLandmarkExtractor)
    private volatile boolean isInitialized = false;
    private final AtomicBoolean isProcessing = new AtomicBoolean(false);
    
    public FaceIdService(Context context) {
        this.context = context.getApplicationContext();
        this.executor = Executors.newCachedThreadPool(); // Thay đổi thành thread pool
        this.mainHandler = new Handler(Looper.getMainLooper());
        this.faceIdApiController = ApiClient.getClient(context).create(FaceIdApiController.class);
        this.authManager = AuthManager.getInstance(context);
        // 🔧 NEW: Initialize configuration and managers
        this.configManager = new FaceIdConfig(context);
        this.memoryManager = new FaceIdMemoryManager(context, configManager.getConfig().memoryConfig);
        this.performanceManager = new FaceIdPerformanceManager(context, configManager.getConfig().performanceConfig);
        
        // 🔧 NEW: Initialize improved components with configuration
        this.decisionEngine = new FaceDecisionEngine(FaceDecisionEngine.FaceDecisionConfig.getDefault());
        this.retryManager = new ModelRetryManager.Builder()
            .maxRetries(3)
            .initialRetryDelayMs(1000)
            .build();
        this.errorHandler = new FaceProcessingErrorHandler(context);
        
        // Khởi tạo các model bất đồng bộ
        initializeModelsAsync();
    }
    
    private void initializeModelsAsync() {
        // 🔧 NEW: Initialize FaceDetector with retry
        executor.execute(() -> {
            try {
                this.faceDetector = retryManager.executeWithRetry(() -> new FaceDetector(context));
                modelLoadLatch.countDown();
            } catch (ModelRetryManager.ModelRetryException e) {
                errorHandler.handleModelInitializationError(e, "FaceDetector");
                modelLoadLatch.countDown();
            }
        });
        
        // 🔧 NEW: Initialize FaceEmbedding with retry
        executor.execute(() -> {
            try {
                this.faceEmbedding = retryManager.executeWithRetry(() -> new FaceEmbedding(context));
                modelLoadLatch.countDown();
            } catch (ModelRetryManager.ModelRetryException e) {
                errorHandler.handleModelInitializationError(e, "FaceEmbedding");
                modelLoadLatch.countDown();
            }
        });
        
        // 🔧 NEW: Initialize FaceSpoofDetector with retry
        executor.execute(() -> {
            try {
                this.faceSpoofDetector = retryManager.executeWithRetry(() -> new FaceSpoofDetector(context));
                modelLoadLatch.countDown();
            } catch (ModelRetryManager.ModelRetryException e) {
                errorHandler.handleModelInitializationError(e, "FaceSpoofDetector");
                modelLoadLatch.countDown();
            }
        });
        
        // 🔧 NEW: Initialize GazeEstimator with retry
        executor.execute(() -> {
            try {
                this.gazeEstimator = retryManager.executeWithRetry(() -> new GazeEstimator(context, null));
                // Configure gaze estimator for front camera mirrored preview and reduced head pose weight
                this.gazeEstimator.setFrontCameraMirrored(true);
                this.gazeEstimator.setHeadPoseWeight(0.2f);
                modelLoadLatch.countDown();
            } catch (ModelRetryManager.ModelRetryException e) {
                errorHandler.handleModelInitializationError(e, "GazeEstimator");
                modelLoadLatch.countDown();
            }
        });
        
        // 🔧 NEW: Initialize MediaPipeFaceLandmarkExtractor with retry
        executor.execute(() -> {
            try {
                this.mediaPipeFaceLandmarkExtractor = retryManager.executeWithRetry(() -> new MediaPipeFaceLandmarkExtractor(context));
                modelLoadLatch.countDown();
            } catch (ModelRetryManager.ModelRetryException e) {
                errorHandler.handleModelInitializationError(e, "MediaPipeFaceLandmarkExtractor");
                modelLoadLatch.countDown();
            }
        });
    }
    
    public boolean isInitialized() {
        if (isInitialized) {
            return true;
        }
        
        try {
            // Kiểm tra xem tất cả model đã load xong chưa (với timeout 0 để không block)
            boolean allLoaded = modelLoadLatch.await(0, TimeUnit.MILLISECONDS);
            isInitialized = allLoaded;
            return allLoaded;
        } catch (InterruptedException e) {
            return false;
        }
    }
    
    public void awaitInitialization(long timeoutMs, Runnable onComplete, Runnable onTimeout) {
        executor.execute(() -> {
            try {
                boolean initialized = modelLoadLatch.await(timeoutMs, TimeUnit.MILLISECONDS);
                if (initialized) {
                    isInitialized = true;
                    mainHandler.post(onComplete);
                } else {
                    mainHandler.post(onTimeout);
                }
            } catch (InterruptedException e) {
                mainHandler.post(onTimeout);
            }
        });
    }
    
    public interface FaceIdCallback {
        void onSuccess(String message);
        void onFailure(String errorMessage);
        
        // Optional: Handle "already registered" case with embedding data for potential update
        default void onAlreadyRegistered(MultipartBody.Part embeddingPart, RequestBody userIdBody) {
            // Default behavior: treat as failure
            onFailure("Face ID already registered. Please use update feature.");
        }
    }
    
    public interface FaceDetectionCallback {
        void onFaceDetected(Bitmap faceBitmap, Rect boundingBox);
        void onNoFaceDetected();
        void onMultipleFacesDetected();
        void onError(String errorMessage);
    }
    
    public interface ContinuousProcessingCallback {
        void onFaceDetected(Rect boundingBox, boolean isSpoof, float spoofScore);
        void onNoFaceDetected();
        void onMultipleFacesDetected();
        void onError(String errorMessage);
    }
    
    public interface FaceVerificationCallback {
        void onVerified(float confidence);
        void onVerificationFailed(String reason);
        void onError(String errorMessage);
    }
    
    /**
     * Process a bitmap to detect face, check for spoofing, and generate embedding
     * Enhanced with oval boundary validation
     */
    public void processFaceImage(Bitmap bitmap, Rect faceRect, android.graphics.RectF ovalRect, FaceDetectionCallback callback) {
        // Check if models are initialized
        if (!isInitialized()) {
            awaitInitialization(5000, 
                () -> processFaceImage(bitmap, faceRect, ovalRect, callback),
                () -> runOnMainThread(() -> callback.onError("Face detection models not initialized yet"))
            );
            return;
        }
        
        executor.execute(() -> {
            try {
                // If face rectangle is not provided, detect it
                if (faceRect == null) {
                    List<FaceDetector.FaceDetectionResult> faces = faceDetector.detectFaces(bitmap);
                    
                    if (faces.isEmpty()) {
                        runOnMainThread(() -> callback.onNoFaceDetected());
                        return;
                    }
                    
                    if (faces.size() > 1) {
                        runOnMainThread(() -> callback.onMultipleFacesDetected());
                        return;
                    }
                    
                    // Get the single detected face
                    FaceDetector.FaceDetectionResult faceResult = faces.get(0);
                    Bitmap faceBitmap = faceResult.getCroppedBitmap();
                    Rect boundingBox = faceResult.getBoundingBox();
                    
                    // Now perform spoof detection with oval validation
                    processFaceWithOvalBoundary(bitmap, boundingBox, ovalRect, faceBitmap, callback);
                } else {
                    // Use the provided face rectangle
                    // Crop the face bitmap
                    Bitmap faceBitmap = Bitmap.createBitmap(
                            bitmap, 
                            faceRect.left, 
                            faceRect.top, 
                            faceRect.width(), 
                            faceRect.height()
                    );
                    
                    // Perform spoof detection with oval validation
                    processFaceWithOvalBoundary(bitmap, faceRect, ovalRect, faceBitmap, callback);
                }
            } catch (Exception e) {
                runOnMainThread(() -> callback.onError("Error processing face: " + e.getMessage()));
            }
        });
    }
    
    /**
     * 🔧 NEW: Improved helper method using FaceDecisionEngine with Memory and Performance Management
     */
    private void processFaceWithOvalBoundary(Bitmap bitmap, Rect boundingBox, android.graphics.RectF ovalRect, 
                                           Bitmap faceBitmap, FaceDetectionCallback callback) {
        // 🔧 NEW: Memory management - acquire rect from pool
        Rect pooledBoundingBox = memoryManager.acquireRect();
        pooledBoundingBox.set(boundingBox);
        
        // 🔧 NEW: Performance optimization - use caching
        String cacheKey = generateCacheKey(faceBitmap, "spoof_detection");
        FaceIdPerformanceManager.CachedResult cachedResult = performanceManager.processFrameWithCache(faceBitmap, cacheKey);
        
        // 🔧 NEW: Use FaceDecisionEngine for oval validation
        FaceDecisionEngine.OvalValidationResult ovalValidation = validateOvalBoundary(pooledBoundingBox, ovalRect);
                        
        // Step 2: Check for spoofing using async method with oval validation
        faceSpoofDetector.detectSpoofAsync(cachedResult.bitmap, pooledBoundingBox, ovalRect, spoofResult -> {
            // 🔧 NEW: Use FaceDecisionEngine for decision making
            FaceDecisionEngine.FaceDetectionResult detectionResult = new FaceDecisionEngine.FaceDetectionResult(
                true, pooledBoundingBox, spoofResult.getConfidence()
            );
            
            FaceDecisionEngine.SpoofDetectionResult spoofDetectionResult = new FaceDecisionEngine.SpoofDetectionResult(
                spoofResult.isSpoof(), spoofResult.getConfidence(), spoofResult.getScore()
            );
            
            FaceDecisionEngine.FaceDecisionResult decision = decisionEngine.evaluate(
                detectionResult, spoofDetectionResult, ovalValidation
            );
            
            // 🔧 NEW: Handle decision result
            if (decision.isAccepted()) {
                runOnMainThread(() -> callback.onFaceDetected(faceBitmap, boundingBox));
            } else if (decision.isRejected()) {
                runOnMainThread(() -> callback.onError(decision.getMessage()));
            } else if (decision.needsGuidance()) {
                runOnMainThread(() -> callback.onError(decision.getMessage()));
            }
            
            // 🔧 NEW: Memory management - release pooled objects
            memoryManager.releaseRect(pooledBoundingBox);
        });
    }
    
    /**
     * 🔧 NEW: Helper method to validate oval boundary
     */
    private FaceDecisionEngine.OvalValidationResult validateOvalBoundary(Rect boundingBox, android.graphics.RectF ovalRect) {
        if (ovalRect == null) {
            return new FaceDecisionEngine.OvalValidationResult(true, "No oval boundary provided");
        }
        
        // Map ovalRect (view space) to bitmap space using current mapping
        android.graphics.RectF mappedOval = ovalRect;
        try {
            android.graphics.RectF mapped = com.example.flutter_application_1.faceid.util.CoordinateMapper.getInstance().mapViewRectToBitmap(ovalRect);
            if (mapped != null) {
                mappedOval = mapped;
            }
        } catch (Exception ignored) {}

        // Apply slight tolerance by expanding oval by 7% for validation only (not UI)
        android.graphics.RectF tolerantOval = new android.graphics.RectF(mappedOval);
        float expandX = tolerantOval.width() * 0.07f * 0.5f;
        float expandY = tolerantOval.height() * 0.07f * 0.5f;
        tolerantOval.inset(-expandX, -expandY);

        boolean isWithinOval = checkFaceWithinOval(boundingBox, tolerantOval);
        
        // 🔧 NEW: Fallback validation for registration scenario
        if (!isWithinOval && configManager.getConfig().scenario == FaceIdConfig.Scenario.REGISTRATION) {
            // Try with more lenient thresholds for registration
            boolean fallbackCheck = checkFaceWithinOvalFallback(boundingBox, ovalRect);
            if (fallbackCheck) {
                return new FaceDecisionEngine.OvalValidationResult(true, "Face positioned within oval (fallback validation)");
            }
        }
        
        String reason = isWithinOval ? "Face properly positioned within oval" : "Face not within oval boundary";
        return new FaceDecisionEngine.OvalValidationResult(isWithinOval, reason);
    }
    
    /**
     * Legacy method for backward compatibility
     */
    public void processFaceImage(Bitmap bitmap, FaceDetectionCallback callback) {
        processFaceImage(bitmap, null, null, callback);
    }
    
    /**
     * Check if face is within oval boundary
     */
    private boolean checkFaceWithinOval(Rect faceRect, android.graphics.RectF ovalRect) {
        if (faceRect == null || ovalRect == null) {
            return true; // No validation needed
        }
        
        // Calculate face center relative to oval center
        float faceCenterX = faceRect.exactCenterX();
        float faceCenterY = faceRect.exactCenterY();
        float ovalCenterX = ovalRect.centerX();
        float ovalCenterY = ovalRect.centerY();
        
        // Calculate ellipse parameters
        float a = ovalRect.width() / 2; // semi-major axis
        float b = ovalRect.height() / 2; // semi-minor axis
        
        // Ellipse equation: (x-h)²/a² + (y-k)²/b² ≤ 1
        float ellipseValue = (float) (
            Math.pow(faceCenterX - ovalCenterX, 2) / Math.pow(a, 2) +
            Math.pow(faceCenterY - ovalCenterY, 2) / Math.pow(b, 2)
        );
        
        // 🔧 NEW: Use configuration for oval validation
        FaceIdConfig.OvalConfig ovalConfig = configManager.getConfig().ovalConfig;
        
        // Calculate face size relative to oval
        float faceWidth = faceRect.width();
        float faceHeight = faceRect.height();
        float widthRatio = faceWidth / ovalRect.width();
        float heightRatio = faceHeight / ovalRect.height();
        
        // 🔧 NEW: Use configurable thresholds
        // Ellipse equation returns ≤ 1 for points inside ellipse, so we check if it's within the ellipse
        // Align ellipse tolerance with overlay view tolerance for consistency
        float ELLIPSE_TOLERANCE = 1.2f; // matches overlay behavior
        boolean isWithinEllipse = ellipseValue <= ELLIPSE_TOLERANCE;
        boolean isGoodSize = widthRatio >= ovalConfig.minFaceSizeRatio && widthRatio <= ovalConfig.maxFaceSizeRatio && 
                            heightRatio >= ovalConfig.minFaceSizeRatio && heightRatio <= ovalConfig.maxFaceSizeRatio;
        
        return isWithinEllipse && isGoodSize;
    }
    
    /**
     * 🔧 NEW: Fallback oval validation with more lenient thresholds for registration
     */
    private boolean checkFaceWithinOvalFallback(Rect faceRect, android.graphics.RectF ovalRect) {
        if (faceRect == null || ovalRect == null) {
            return true; // No validation needed
        }
        
        // Calculate face center relative to oval center
        float faceCenterX = faceRect.exactCenterX();
        float faceCenterY = faceRect.exactCenterY();
        float ovalCenterX = ovalRect.centerX();
        float ovalCenterY = ovalRect.centerY();
        
        // Calculate ellipse parameters
        float a = ovalRect.width() / 2; // semi-major axis
        float b = ovalRect.height() / 2; // semi-minor axis
        
        // Ellipse equation: (x-h)²/a² + (y-k)²/b² ≤ 1
        float ellipseValue = (float) (
            Math.pow(faceCenterX - ovalCenterX, 2) / Math.pow(a, 2) +
            Math.pow(faceCenterY - ovalCenterY, 2) / Math.pow(b, 2)
        );
        
        // 🔧 NEW: More lenient thresholds for fallback validation
        float fallbackMinFaceSizeRatio = 0.15f; // 15% size instead of 20%
        float fallbackMaxFaceSizeRatio = 0.95f; // 95% size instead of 90%
        
        // Calculate face size relative to oval
        float faceWidth = faceRect.width();
        float faceHeight = faceRect.height();
        float widthRatio = faceWidth / ovalRect.width();
        float heightRatio = faceHeight / ovalRect.height();
        
        // 🔧 NEW: Use fallback thresholds
        // Ellipse equation returns ≤ 1 for points inside ellipse, so we check if it's within the ellipse
        boolean isWithinEllipse = ellipseValue <= 1.0f;
        boolean isGoodSize = widthRatio >= fallbackMinFaceSizeRatio && widthRatio <= fallbackMaxFaceSizeRatio && 
                            heightRatio >= fallbackMinFaceSizeRatio && heightRatio <= fallbackMaxFaceSizeRatio;

        return isWithinEllipse && isGoodSize;
    }
    
    /**
     * Process a frame continuously for zero-touch face recognition
     * Enhanced with oval boundary validation
     * 
     * @param bitmap Current frame bitmap
     * @param ovalRect Oval boundary for validation (can be null)
     * @param callback Callback for continuous processing results
     * @return true if processing was started, false if already processing
     */
    public boolean processContinuousFrame(Bitmap bitmap, android.graphics.RectF ovalRect, ContinuousProcessingCallback callback) {
        // Skip if already processing a frame or models not initialized
        if (!isInitialized()) {
            return false;
        }
        
        // If already processing, reset the flag to allow processing this new frame
        if (isProcessing.get()) {
            isProcessing.set(false);
        }
        
        isProcessing.set(true);
        
        // 🔧 NEW: Use retry manager for face detection
        retryManager.executeWithRetryAsync(() -> {
            try {
                // Step 1: Detect face with retry
                List<FaceDetector.FaceDetectionResult> faces = faceDetector.detectFaces(bitmap);
    
                if (faces.isEmpty()) {
                    runOnMainThread(() -> {
                        callback.onNoFaceDetected();
                        isProcessing.set(false);
                    });
                    return null;
                }
                
                if (faces.size() > 1) {
                    runOnMainThread(() -> {
                        callback.onMultipleFacesDetected();
                        isProcessing.set(false);
                    });
                    return null;
                }
                
                // Get the single detected face
                FaceDetector.FaceDetectionResult faceResult = faces.get(0);
                Rect boundingBox = faceResult.getBoundingBox();
                
                // 🔧 NEW: Use FaceDecisionEngine for oval validation
                FaceDecisionEngine.OvalValidationResult ovalValidation = validateOvalBoundary(boundingBox, ovalRect);
                
                if (!ovalValidation.isValid()) {
                    runOnMainThread(() -> {
                        callback.onError(ovalValidation.getReason());
                        isProcessing.set(false);
                    });
                    return null;
                }
                
                // Step 2: Check for spoofing with oval validation
                faceSpoofDetector.detectSpoofAsync(bitmap, boundingBox, ovalRect, spoofResult -> {
                    // 🔧 NEW: Use FaceDecisionEngine for decision making
                    FaceDecisionEngine.FaceDetectionResult detectionResult = new FaceDecisionEngine.FaceDetectionResult(
                        true, boundingBox, spoofResult.getConfidence()
                    );
                    
                    FaceDecisionEngine.SpoofDetectionResult spoofDetectionResult = new FaceDecisionEngine.SpoofDetectionResult(
                        spoofResult.isSpoof(), spoofResult.getConfidence(), spoofResult.getScore()
                    );
                    
                    FaceDecisionEngine.FaceDecisionResult decision = decisionEngine.evaluate(
                        detectionResult, spoofDetectionResult, ovalValidation
                    );
                    
                    runOnMainThread(() -> {
                         callback.onFaceDetected(boundingBox, spoofResult.isSpoof(), spoofResult.getScore());
                        isProcessing.set(false);
                    });
                });
                
                return null;
                
            } catch (Exception e) {
                errorHandler.handleFaceDetectionError(e);
                runOnMainThread(() -> {
                    callback.onError("Error processing frame: " + e.getMessage());
                    isProcessing.set(false);
                });
                return null;
            }
        }, new ModelRetryManager.RetryCallback<Object>() {
            @Override
            public void onSuccess(Object result) {
                // Success handled in the operation
            }
            
            @Override
            public void onFailure(ModelRetryManager.ModelRetryException exception) {
                errorHandler.handleGeneralError(exception, "continuous frame processing");
                runOnMainThread(() -> {
                    callback.onError("Processing failed after retries");
                    isProcessing.set(false);
                });
            }
        });
        
        return true;
    }
    
    /**
     * Legacy method for backward compatibility
     */
    public boolean processContinuousFrame(Bitmap bitmap, ContinuousProcessingCallback callback) {
        return processContinuousFrame(bitmap, null, callback);
    }
    
    /**
     * Capture and process a stable face for registration
     * Enhanced with oval boundary validation
     * 
     * @param bitmap Bitmap containing the face
     * @param boundingBox Bounding box of the face
     * @param ovalRect Oval boundary for validation (can be null)
     * @param userId User ID for registration
     * @param callback Callback for registration result
     */
    public void captureAndRegisterFace(Bitmap bitmap, Rect boundingBox, android.graphics.RectF ovalRect, 
                                     String userId, FaceIdCallback callback) {
        executor.execute(() -> {
            try {
                // Check if face is within oval boundary if oval is provided
                if (ovalRect != null) {
                    boolean isWithinOval = checkFaceWithinOval(boundingBox, ovalRect);
                    if (!isWithinOval) {
                        runOnMainThread(() -> callback.onFailure("Please position your face within the oval guide"));
                        return;
                    }
                }
                
                // Crop the face using landmark-aware pipeline
                Rect stableCrop = computeSquareCropWithMargin(bitmap, boundingBox, 1.25f);
                Bitmap faceBitmap = Bitmap.createBitmap(bitmap, stableCrop.left, stableCrop.top, stableCrop.width(), stableCrop.height());
                Bitmap aligned = tryAlignFace(faceBitmap);
                if (aligned != null) faceBitmap = aligned;
                
                // Do one final spoof check with oval boundary
                Bitmap finalFaceBitmap = faceBitmap;
                faceSpoofDetector.detectSpoofAsync(bitmap, boundingBox, ovalRect, spoofResult -> {
                    if (spoofResult.isSpoof()) {
                        runOnMainThread(() -> callback.onFailure("Spoof detected! Please use a real face for registration."));
                        return;
                    }
                    
                    // Register the face
                    registerFaceId(finalFaceBitmap, userId, callback);
                });
                
            } catch (Exception e) {
                runOnMainThread(() -> callback.onFailure("Error capturing face: " + e.getMessage()));
            }
        });
    }

    /**
     * Capture and update face embedding with spoof/oval validations (Update flow)
     */
    public void captureAndUpdateFace(Bitmap bitmap, Rect boundingBox, android.graphics.RectF ovalRect,
                                     String userId, FaceIdCallback callback) {
        executor.execute(() -> {
            try {
                // Validate oval if provided
                if (ovalRect != null) {
                    boolean isWithinOval = checkFaceWithinOval(boundingBox, ovalRect);
                    if (!isWithinOval) {
                        runOnMainThread(() -> callback.onFailure("Please position your face within the oval guide"));
                        return;
                    }
                }

                // Crop the face using landmark-aware pipeline
                Rect stableCrop = computeSquareCropWithMargin(bitmap, boundingBox, 1.25f);
                Bitmap faceBitmap = Bitmap.createBitmap(bitmap, stableCrop.left, stableCrop.top, stableCrop.width(), stableCrop.height());
                Bitmap aligned = tryAlignFace(faceBitmap);
                if (aligned != null) faceBitmap = aligned;

                // Final spoof check before update
                Bitmap finalFaceBitmap = faceBitmap;
                faceSpoofDetector.detectSpoofAsync(bitmap, boundingBox, ovalRect, spoofResult -> {
                    if (spoofResult.isSpoof()) {
                        runOnMainThread(() -> callback.onFailure("Spoof detected! Please use a real face for update."));
                        return;
                    }

                    // Proceed with update API
                    updateFaceId(finalFaceBitmap, userId, callback);
                });
            } catch (Exception e) {
                runOnMainThread(() -> callback.onFailure("Error capturing face: " + e.getMessage()));
            }
        });
    }
    
    /**
     * Capture and verify face embedding with spoof/oval validations (Verify flow)
     */
    public void captureAndVerifyFace(Bitmap bitmap, Rect boundingBox, android.graphics.RectF ovalRect,
                                     String userId, FaceIdCallback callback) {
        executor.execute(() -> {
            try {
                // Validate oval if provided
                if (ovalRect != null) {
                    boolean isWithinOval = checkFaceWithinOval(boundingBox, ovalRect);
                    if (!isWithinOval) {
                        runOnMainThread(() -> callback.onFailure("Please position your face within the oval guide"));
                        return;
                    }
                }
                
                // Crop the face using landmark-aware pipeline
                Rect stableCrop = computeSquareCropWithMargin(bitmap, boundingBox, 1.25f);
                Bitmap faceBitmap = Bitmap.createBitmap(bitmap, stableCrop.left, stableCrop.top, stableCrop.width(), stableCrop.height());
                Bitmap aligned = tryAlignFace(faceBitmap);
                if (aligned != null) faceBitmap = aligned;
                
                // Optional spoof check before verification (same gate as update)
                Bitmap finalFaceBitmap = faceBitmap;
                faceSpoofDetector.detectSpoofAsync(bitmap, boundingBox, ovalRect, spoofResult -> {
                    if (spoofResult.isSpoof()) {
                        runOnMainThread(() -> callback.onFailure("Spoof detected! Please use a real face for verification."));
                        return;
                    }
                    
                    // Proceed with legacy verify API (ad-hoc) by default
                    verifyFaceId(finalFaceBitmap, userId, callback);
                });
            } catch (Exception e) {
                runOnMainThread(() -> callback.onFailure("Error capturing face: " + e.getMessage()));
            }
        });
    }

    /**
     * Verify face embedding for a specific request window
     */
    public void verifyFaceIdForRequest(Bitmap faceBitmap, String userId, String requestId, Float threshold, 
                                      Double latitude, Double longitude, Double locationAccuracy,
                                      String deviceId, String ipAddress, FaceIdCallback callback) {
        if (!isInitialized()) {
            awaitInitialization(5000,
                () -> verifyFaceIdForRequest(faceBitmap, userId, requestId, threshold, latitude, longitude, locationAccuracy, deviceId, ipAddress, callback),
                () -> runOnMainThread(() -> callback.onFailure("Face embedding model not initialized yet"))
            );
            return;
        }

        faceEmbedding.getFaceEmbeddingAsync(faceBitmap, embedding -> {
            executor.execute(() -> {
                try {
                    ByteBuffer buffer = ByteBuffer.allocate(embedding.length * 4);
                    buffer.order(ByteOrder.LITTLE_ENDIAN);
                    for (float v : embedding) buffer.putFloat(v);
                    logEmbeddingDebug(embedding, buffer.array(), "verify_request");
                    saveEmbeddingDebug(buffer.array(), "verify_request");

                    // 🔧 Use employeeId from AuthManager instead of userId for API call
                    String employeeId = authManager.getEmployeeId();
                    String userIdForApi = (employeeId != null && !employeeId.isEmpty()) ? employeeId : userId;

                    RequestBody userIdPart = RequestBody.create(MediaType.parse("text/plain"), userIdForApi);
                    RequestBody thresholdPart = threshold != null ?
                            RequestBody.create(MediaType.parse("text/plain"), String.valueOf(threshold)) :
                            null;
                    RequestBody embeddingPart = RequestBody.create(MediaType.parse("application/octet-stream"), buffer.array());
                    MultipartBody.Part filePart = MultipartBody.Part.createFormData("embedding", "embedding.bin", embeddingPart);

                    // 📍 Thêm location và device info
                    RequestBody latitudePart = latitude != null ?
                            RequestBody.create(MediaType.parse("text/plain"), String.valueOf(latitude)) :
                            null;
                    RequestBody longitudePart = longitude != null ?
                            RequestBody.create(MediaType.parse("text/plain"), String.valueOf(longitude)) :
                            null;
                    RequestBody locationAccuracyPart = locationAccuracy != null ?
                            RequestBody.create(MediaType.parse("text/plain"), String.valueOf(locationAccuracy)) :
                            null;
                    RequestBody deviceIdPart = deviceId != null ?
                            RequestBody.create(MediaType.parse("text/plain"), deviceId) :
                            null;
                    RequestBody ipAddressPart = ipAddress != null ?
                            RequestBody.create(MediaType.parse("text/plain"), ipAddress) :
                            null;

                    FaceIdApiController api = ApiClient.getClient(context).create(FaceIdApiController.class);
                    retrofit2.Call<FaceIdVerifyResponse> call =
                            api.verifyFaceId(requestId, userIdPart, filePart, thresholdPart, 
                                           latitudePart, longitudePart, locationAccuracyPart, 
                                           deviceIdPart, ipAddressPart);
                    call.enqueue(new retrofit2.Callback<FaceIdVerifyResponse>() {
                        @Override
                        public void onResponse(@NonNull retrofit2.Call<FaceIdVerifyResponse> c,
                                               @NonNull retrofit2.Response<FaceIdVerifyResponse> resp) {
                            if (resp.isSuccessful() && resp.body() != null) {
                                if (resp.body().isSuccess()) {
                                    runOnMainThread(() -> callback.onSuccess("Face ID verified successfully"));
                                } else {
                                    runOnMainThread(() -> callback.onFailure(resp.body().getMessage() != null ? resp.body().getMessage() : "Verification failed"));
                                }
                            } else if (resp.code() == 410) {
                                runOnMainThread(() -> callback.onFailure("Verification window expired"));
                            } else {
                                runOnMainThread(() -> callback.onFailure("Failed to verify: HTTP " + resp.code())) ;
                            }
                        }

                        @Override
                        public void onFailure(@NonNull retrofit2.Call<FaceIdVerifyResponse> c,
                                              @NonNull Throwable t) {
                            runOnMainThread(() -> callback.onFailure("Network error: " + t.getMessage()));
                        }
                    });
                } catch (Exception e) {
                    runOnMainThread(() -> callback.onFailure("Error: " + e.getMessage()));
                }
            });
        });
    }
    
    /**
     * Register a new face ID by sending the embedding to backend
     */
    public void registerFaceId(Bitmap faceBitmap, String userId, FaceIdCallback callback) {

        // Check if models are initialized
        if (!isInitialized()) {
            awaitInitialization(5000,
                () -> registerFaceId(faceBitmap, userId, callback),
                () -> runOnMainThread(() -> {
                    callback.onFailure("Face embedding model not initialized yet");
                })
            );
            return;
        }

        // 🔧 NEW: Use retry manager for embedding generation
        retryManager.executeWithRetryAsync(() -> {
            try {

                // Generate face embedding with retry
                float[] embedding = retryManager.executeWithRetry(() -> faceEmbedding.getFaceEmbedding(faceBitmap));

                // Convert embedding to byte array for API call (float32 little-endian)
                ByteBuffer buffer = ByteBuffer.allocate(embedding.length * 4);
                buffer.order(ByteOrder.LITTLE_ENDIAN);
                for (float value : embedding) {
                    buffer.putFloat(value);
                }
                // Log embedding preview + sizes
                logEmbeddingDebug(embedding, buffer.array(), "register");
                // Save a debug copy of the exact embedding being sent
                saveEmbeddingDebug(buffer.array(), "register");
                
                // 🔧 Use employeeId from AuthManager instead of userId for API call
                String employeeId = authManager.getEmployeeId();
                String userIdForApi = (employeeId != null && !employeeId.isEmpty()) ? employeeId : userId;
                
                // Create userId as form field (text/plain)
                RequestBody userIdPart = RequestBody.create(
                        MediaType.parse("text/plain"), 
                        userIdForApi);
                
                // Create embedding as binary file
                RequestBody embeddingPart = RequestBody.create(
                        MediaType.parse("application/octet-stream"), 
                        buffer.array());
                
                MultipartBody.Part embeddingFilePart = MultipartBody.Part.createFormData(
                        "embedding", "embedding.bin", embeddingPart);

                // API call with userId (form field) and embedding (binary file)
                Call<FaceIdResponse> call = faceIdApiController.registerFaceId(embeddingFilePart, userIdPart);
                
                // 🔧 NEW: Add timeout to the call
                call.enqueue(new Callback<FaceIdResponse>() {
                    @Override
                    public void onResponse(@NonNull Call<FaceIdResponse> call, @NonNull Response<FaceIdResponse> response) {
                                            String errorBodyString = null;
                        if (response.errorBody() != null) {
                            try {
                                errorBodyString = response.errorBody().string();
                            } catch (Exception e) {
                            }
                        }
                        
                        if (response.isSuccessful() && response.body() != null) {
                            FaceIdResponse responseBody = response.body();
                            if (responseBody.isSuccess()) {
                                authManager.setFaceIdRegistered(true);
                                runOnMainThread(() -> callback.onSuccess("Face ID registered successfully"));
                            } else {
                                String errorMsg = "Server error: " + responseBody.getMessage();
                                runOnMainThread(() -> callback.onFailure(errorMsg));
                            }
                        } else {
                            String errorMsg;
                            String serverMessage = null;
                            
                            // 🔧 FIX: Use the already-read errorBodyString instead of reading again
                            if (errorBodyString != null && !errorBodyString.isEmpty()) {
                                Log.d(TAG, "API Call - registerFaceId - Error body: " + errorBodyString);
                                try {
                                    
                                    // Try to extract message field (case-insensitive)
                                    String rawLower = errorBodyString.toLowerCase();
                                    int idx = rawLower.indexOf("\"message\"");
                                    if (idx >= 0) {
                                        // Find the colon after "message"
                                        int colon = errorBodyString.indexOf(":", idx);
                                        if (colon > 0) {
                                            // Find the value (between quotes)
                                            int valueStart = errorBodyString.indexOf("\"", colon + 1);
                                            if (valueStart > 0) {
                                                int valueEnd = errorBodyString.indexOf("\"", valueStart + 1);
                                                if (valueEnd > valueStart) {
                                                    serverMessage = errorBodyString.substring(valueStart + 1, valueEnd).trim();
                                                    Log.d(TAG, "API Call - registerFaceId - Parsed serverMessage: " + serverMessage);
                                                }
                                            }
                                        }
                                    }
                                } catch (Exception e) {
                                    Log.e(TAG, "API Call - registerFaceId - Error parsing message", e);
                                }
                            }
                            
                            if (response.code() == 401) {
                                errorMsg = "Authentication failed. Please login again.";
                            } else if (response.code() == 403) {
                                errorMsg = "Access denied. Please check your permissions.";
                            } else if (response.code() == 404) {
                                errorMsg = "Service not found. Please contact support.";
                            } else if (response.code() >= 500) {
                                errorMsg = "Server error. Please try again later.";
                            } else if (response.code() == 400) {
                                // Use server message when available
                                errorMsg = serverMessage != null && !serverMessage.isEmpty()
                                        ? serverMessage
                                        : ("Bad Request");
                                
                                // Check if user already has a registered Face ID
                                // 🔧 FIX: Check both parsed serverMessage and raw errorBodyString for keywords (case-insensitive)
                                boolean isAlreadyRegistered = (errorMsg != null && (
                                    errorMsg.toLowerCase().contains("user already has a registered face id") || 
                                    errorMsg.toLowerCase().contains("use update instead") ||
                                    errorMsg.toLowerCase().contains("already registered"))) ||
                                    (errorBodyString != null && (
                                    errorBodyString.toLowerCase().contains("user already has a registered face id") || 
                                    errorBodyString.toLowerCase().contains("use update instead") ||
                                    errorBodyString.toLowerCase().contains("already registered")));
                                
                                Log.d(TAG, "API Call - registerFaceId - 400 error check: errorMsg=" + errorMsg + 
                                          ", isAlreadyRegistered=" + isAlreadyRegistered);
                                
                                if (isAlreadyRegistered) {
                                    // Call the callback with embedding data so UI can decide what to do
                                    runOnMainThread(() -> callback.onAlreadyRegistered(embeddingFilePart, userIdPart));
                                    return; // IMPORTANT: Stop here, don't call onFailure
                                } else {
                                }
                            } else {
                                errorMsg = "Failed to register Face ID: " + (serverMessage != null ? serverMessage : response.message());
                            }
                            runOnMainThread(() -> callback.onFailure(errorMsg));
                        }
                    }
                    
                    @Override
                    public void onFailure(@NonNull Call<FaceIdResponse> call, @NonNull Throwable t) {
                        String errorMsg;
                        if (t instanceof java.net.SocketTimeoutException) {
                            errorMsg = "Request timeout. Please check your internet connection and try again.";
                        } else if (t instanceof java.net.UnknownHostException) {
                            errorMsg = "Cannot connect to server. Please check your internet connection.";
                        } else if (t instanceof java.net.ConnectException) {
                            errorMsg = "Connection failed. Please check your internet connection.";
                        } else {
                            errorMsg = "Network error: " + t.getMessage();
                        }
                        runOnMainThread(() -> callback.onFailure(errorMsg));
                    }
                });
                
                return null;
                
            } catch (Exception e) {
                errorHandler.handleGeneralError(e, "face registration");
                runOnMainThread(() -> callback.onFailure("Error: " + e.getMessage()));
                return null;
            }
        }, new ModelRetryManager.RetryCallback<Object>() {
            @Override
            public void onSuccess(Object result) {
                // Success handled in the operation
            }
            
            @Override
            public void onFailure(ModelRetryManager.ModelRetryException exception) {
                errorHandler.handleGeneralError(exception, "face registration");
                runOnMainThread(() -> callback.onFailure("Registration failed after retries"));
            }
        });
    }
    
    /**
     * Update existing face ID
     */
    public void updateFaceId(Bitmap faceBitmap, String userId, FaceIdCallback callback) {
        // Check if models are initialized
        if (!isInitialized()) {
            awaitInitialization(5000, 
                () -> updateFaceId(faceBitmap, userId, callback),
                () -> runOnMainThread(() -> callback.onFailure("Face embedding model not initialized yet"))
            );
            return;
        }
        
        // Use async method to generate embedding
        faceEmbedding.getFaceEmbeddingAsync(faceBitmap, embedding -> {
            executor.execute(() -> {
                try {
                    // Convert embedding to byte array for API call (float32 little-endian)
                    ByteBuffer buffer = ByteBuffer.allocate(embedding.length * 4);
                    buffer.order(ByteOrder.LITTLE_ENDIAN);
                    for (float value : embedding) {
                        buffer.putFloat(value);
                    }
                            // Log embedding preview + sizes
                            logEmbeddingDebug(embedding, buffer.array(), "update");
                            // Save a debug copy of the exact embedding being sent
                            saveEmbeddingDebug(buffer.array(), "update");
                    // Save a debug copy of the exact embedding being sent
                    saveEmbeddingDebug(buffer.array(), "update");
                    
                    // Create multipart request
                    RequestBody embeddingPart = RequestBody.create(
                            MediaType.parse("application/octet-stream"), 
                            buffer.array());
                    
                    MultipartBody.Part filePart = MultipartBody.Part.createFormData(
                            "embedding", "embedding.bin", embeddingPart);
                    
                    // 🔧 Use employeeId from AuthManager instead of userId for API call
                    String employeeId = authManager.getEmployeeId();
                    String userIdForApi = (employeeId != null && !employeeId.isEmpty()) ? employeeId : userId;
                    
                    // Create userId as RequestBody
                    RequestBody userIdBody = RequestBody.create(
                            MediaType.parse("text/plain"), 
                            userIdForApi);
                    
                    // Make API call
                    Call<FaceIdResponse> call = faceIdApiController.updateFaceId(filePart, userIdBody);
                    call.enqueue(new Callback<FaceIdResponse>() {
                        @Override
                        public void onResponse(@NonNull Call<FaceIdResponse> call, @NonNull Response<FaceIdResponse> response) {
                            if (response.isSuccessful() && response.body() != null) {
                                authManager.setFaceIdRegistered(true);
                                runOnMainThread(() -> callback.onSuccess("Face ID updated successfully"));
                            } else {
                                // Try to parse error body for detailed message
                                String errorMessage = response.message();
                                try {
                                    if (response.errorBody() != null) {
                                        String errorBodyString = response.errorBody().string();
                                        // Try to parse as JSON
                                        com.google.gson.Gson gson = new com.google.gson.Gson();
                                        FaceIdResponse errorResponse = gson.fromJson(errorBodyString, FaceIdResponse.class);
                                        if (errorResponse != null && errorResponse.getMessage() != null) {
                                            errorMessage = errorResponse.getMessage();
                                        }
                                    }
                                } catch (Exception e) {
                                    // If parsing fails, use the default message
                                    Log.w("FaceIdService", "Failed to parse error body: " + e.getMessage());
                                }
                                final String finalErrorMessage = errorMessage;
                                runOnMainThread(() -> callback.onFailure("Failed to update Face ID: " + finalErrorMessage));
                            }
                        }
                        
                        @Override
                        public void onFailure(@NonNull Call<FaceIdResponse> call, @NonNull Throwable t) {
                            runOnMainThread(() -> callback.onFailure("Network error: " + t.getMessage()));
                        }
                    });
                    
                } catch (Exception e) {
                    runOnMainThread(() -> callback.onFailure("Error: " + e.getMessage()));
                }
            });
        });
    }
    
    /**
     * Enhanced face verification with oval boundary validation
     * @param faceBitmap The face image to verify
     * @param faceRect The detected face rectangle  
     * @param ovalRect The oval boundary for position validation
     * @param userId The user ID to verify against
     * @param callback Enhanced callback with confidence scores
     */
    public void verifyFace(Bitmap faceBitmap, Rect faceRect, android.graphics.RectF ovalRect, 
                          String userId, FaceVerificationCallback callback) {
        // Check if models are initialized
        if (!isInitialized()) {
            awaitInitialization(5000, 
                () -> verifyFace(faceBitmap, faceRect, ovalRect, userId, callback),
                () -> runOnMainThread(() -> callback.onError("Face embedding model not initialized yet"))
            );
            return;
        }
        
        // Validate face position within oval if provided
        if (ovalRect != null && faceRect != null) {
            // Use the same validation logic as checkFaceWithinOval for consistency
            boolean isWithinOval = checkFaceWithinOval(faceRect, ovalRect);
            if (!isWithinOval) {
                runOnMainThread(() -> callback.onVerificationFailed("Face not properly positioned within oval"));
                return;
            }
        }
        
        // Use async method to generate embedding
        faceEmbedding.getFaceEmbeddingAsync(faceBitmap, embedding -> {
            executor.execute(() -> {
                try {
                                // Convert embedding to byte array for API call (float32 little-endian)
                    ByteBuffer buffer = ByteBuffer.allocate(embedding.length * 4);
                    buffer.order(ByteOrder.LITTLE_ENDIAN);
                    for (float value : embedding) {
                        buffer.putFloat(value);
                    }
                                // Log embedding preview + sizes
                                logEmbeddingDebug(embedding, buffer.array(), "verify");
                                // Save a debug copy of the exact embedding being sent
                                saveEmbeddingDebug(buffer.array(), "verify");
                    // Save a debug copy of the exact embedding being sent
                    saveEmbeddingDebug(buffer.array(), "verify");
                    
                    // Create multipart request
                    RequestBody embeddingPart = RequestBody.create(
                            MediaType.parse("application/octet-stream"), 
                            buffer.array());
                    
                    MultipartBody.Part filePart = MultipartBody.Part.createFormData(
                            "embedding", "embedding.bin", embeddingPart);
                    
                    RequestBody userIdPart = RequestBody.create(
                            MediaType.parse("text/plain"), userId);
                    
                    // Legacy ad-hoc verification removed
                    runOnMainThread(() -> callback.onError("Ad-hoc verification is no longer supported. Use request-based verification."));
                    
                } catch (Exception e) {
                    runOnMainThread(() -> callback.onError("Error: " + e.getMessage()));
                }
            });
        });
    }
    
    /**
     * Verify face ID against stored embedding (ad-hoc, no request needed)
     */
    public void verifyFaceId(Bitmap faceBitmap, String userId, FaceIdCallback callback) {
        // Check if models are initialized
        if (!isInitialized()) {
            awaitInitialization(5000, 
                () -> verifyFaceId(faceBitmap, userId, callback),
                () -> runOnMainThread(() -> callback.onFailure("Face embedding model not initialized yet"))
            );
            return;
        }
        
        // Use async method to generate embedding
        faceEmbedding.getFaceEmbeddingAsync(faceBitmap, embedding -> {
            executor.execute(() -> {
                try {
                    // Convert embedding to byte array for API call (float32 little-endian)
                    ByteBuffer buffer = ByteBuffer.allocate(embedding.length * 4);
                    buffer.order(ByteOrder.LITTLE_ENDIAN);
                    for (float value : embedding) {
                        buffer.putFloat(value);
                    }
                    // Log and save debug copy
                    logEmbeddingDebug(embedding, buffer.array(), "verify");
                    saveEmbeddingDebug(buffer.array(), "verify");
                    
                    // Create multipart request
                    RequestBody embeddingPart = RequestBody.create(
                            MediaType.parse("application/octet-stream"), 
                            buffer.array());
                    
                    MultipartBody.Part filePart = MultipartBody.Part.createFormData(
                            "embedding", "embedding.bin", embeddingPart);
                    
                    // 🔧 Use employeeId from AuthManager instead of userId for API call
                    String employeeId = authManager.getEmployeeId();
                    String userIdForApi = (employeeId != null && !employeeId.isEmpty()) ? employeeId : userId;
                    
                    RequestBody userIdPart = RequestBody.create(
                            MediaType.parse("text/plain"), userIdForApi);
                    
                    // Call ad-hoc verification API
                    FaceIdApiController api = ApiClient.getClient(context).create(FaceIdApiController.class);
                    retrofit2.Call<FaceIdVerifyResponse> call = api.verifyFaceIdAdHoc(userIdPart, filePart, null);
                    
                    call.enqueue(new retrofit2.Callback<FaceIdVerifyResponse>() {
                        @Override
                        public void onResponse(@NonNull retrofit2.Call<FaceIdVerifyResponse> c,
                                             @NonNull retrofit2.Response<FaceIdVerifyResponse> resp) {
                            if (resp.isSuccessful() && resp.body() != null) {
                                if (resp.body().isSuccess()) {
                                    runOnMainThread(() -> callback.onSuccess("Face ID verified successfully"));
                                } else {
                                    runOnMainThread(() -> callback.onFailure(resp.body().getMessage() != null ? resp.body().getMessage() : "Verification failed"));
                                }
                            } else {
                                String errorMsg = "Failed to verify: HTTP " + resp.code();
                                try {
                                    if (resp.errorBody() != null) {
                                        String errorBody = resp.errorBody().string();
                                        Log.d(TAG, "Verify error body: " + errorBody);
                                        // Try to parse error message
                                        if (errorBody.contains("message")) {
                                            int start = errorBody.indexOf("\"message\"");
                                            if (start >= 0) {
                                                int colon = errorBody.indexOf(":", start);
                                                int valueStart = errorBody.indexOf("\"", colon + 1);
                                                int valueEnd = errorBody.indexOf("\"", valueStart + 1);
                                                if (valueStart > 0 && valueEnd > valueStart) {
                                                    errorMsg = errorBody.substring(valueStart + 1, valueEnd);
                                                }
                                            }
                                        }
                                    }
                                } catch (Exception e) {
                                    Log.e(TAG, "Error parsing error body", e);
                                }
                                final String finalErrorMsg = errorMsg;
                                runOnMainThread(() -> callback.onFailure(finalErrorMsg));
                            }
                        }

                        @Override
                        public void onFailure(@NonNull retrofit2.Call<FaceIdVerifyResponse> c,
                                            @NonNull Throwable t) {
                            runOnMainThread(() -> callback.onFailure("Network error: " + t.getMessage()));
                        }
                    });
                    
                } catch (Exception e) {
                    runOnMainThread(() -> callback.onFailure("Error: " + e.getMessage()));
                }
            });
        });
    }

    /**
     * Helper method to run code on the main thread
     */
    /**
     * 🔧 NEW: Generate cache key for bitmap
     */
    private String generateCacheKey(Bitmap bitmap, String operation) {
        return bitmap.getWidth() + "x" + bitmap.getHeight() + "_" + operation + "_" + System.currentTimeMillis();
    }
    
    /**
     * 🔧 NEW: Get memory statistics
     */
    public FaceIdMemoryManager.MemoryStats getMemoryStats() {
        return memoryManager.getMemoryStats();
    }
    
    /**
     * 🔧 NEW: Get performance statistics
     */
    public FaceIdPerformanceManager.PerformanceStats getPerformanceStats() {
        return performanceManager.getPerformanceStats();
    }
    
    /**
     * 🔧 NEW: Set scenario for configuration
     */
    public void setScenario(FaceIdConfig.Scenario scenario) {
        configManager.setScenario(scenario);
    }
    
    /**
     * 🔧 NEW: Force memory cleanup
     */
    public void forceMemoryCleanup() {
        memoryManager.forceCleanup();
    }
    
    /**
     * 🔧 NEW: Clear performance cache
     */
    public void clearPerformanceCache() {
        performanceManager.clearCache();
    }
    
    private void runOnMainThread(Runnable runnable) {
        mainHandler.post(runnable);
    }

    /**
     * Save a copy of the embedding bytes to app cache for debugging/API testing
     * File name format: embedding_{action}_<timestamp>.bin
     */
     private void saveEmbeddingDebug(byte[] bytes, String action) {
         try {
             File dir = new File(context.getCacheDir(), "face_registration");
             if (!dir.exists()) {
                 //noinspection ResultOfMethodCallIgnored
                 dir.mkdirs();
             }
             File out = new File(dir, "embedding_" + action + "_" + System.currentTimeMillis() + ".bin");
             try (FileOutputStream fos = new FileOutputStream(out)) {
                 fos.write(bytes);
             }
         } catch (Exception e) {
         }
     }

    /**
     * Log a short preview and sizes to help debugging embedding payload
     */
    private void logEmbeddingDebug(float[] embedding, byte[] rawBytes, String action) {
        try {
            int n = embedding != null ? embedding.length : -1;
            int bytes = rawBytes != null ? rawBytes.length : -1;
            // preview first up to 8 floats
            StringBuilder sb = new StringBuilder();
            int preview = Math.min(8, Math.max(0, n));
            for (int i = 0; i < preview; i++) {
                if (i > 0) sb.append(", ");
                sb.append(String.format(java.util.Locale.US, "%.6f", embedding[i]));
            }
        } catch (Exception e) {
        }
    }

    /**
     * Compute a square crop around the detected face with an expansion margin for stability.
     */
    private Rect computeSquareCropWithMargin(Bitmap source, Rect faceRect, float marginScale) {
        if (faceRect == null) return new Rect(0, 0, source.getWidth(), source.getHeight());
        int cx = faceRect.centerX();
        int cy = faceRect.centerY();
        int size = Math.max(faceRect.width(), faceRect.height());
        size = Math.round(size * marginScale);
        int half = size / 2;
        int left = Math.max(0, cx - half);
        int top = Math.max(0, cy - half);
        int right = Math.min(source.getWidth(), cx + half);
        int bottom = Math.min(source.getHeight(), cy + half);
        // Ensure square
        int width = right - left;
        int height = bottom - top;
        int side = Math.min(Math.min(size, source.getWidth()), source.getHeight());
        // Re-center if needed
        left = Math.max(0, cx - side / 2);
        top = Math.max(0, cy - side / 2);
        right = Math.min(source.getWidth(), left + side);
        bottom = Math.min(source.getHeight(), top + side);
        // Adjust again if clamped
        left = right - side;
        top = bottom - side;
        return new Rect(left, top, right, bottom);
    }

    /**
     * Try to align face using eye centers. Returns aligned 160x160 bitmap or null if alignment not possible.
     */
    private Bitmap tryAlignFace(Bitmap faceBitmap) {
        try {
            if (mediaPipeFaceLandmarkExtractor == null || !mediaPipeFaceLandmarkExtractor.isModelAvailable()) {
                return null;
            }
            // Extract landmarks synchronously (best-effort) using image mode
            final CountDownLatch latch = new CountDownLatch(1);
            final boolean[] ok = {false};
            mediaPipeFaceLandmarkExtractor.extractLandmarks(faceBitmap, new Rect(0,0,faceBitmap.getWidth(), faceBitmap.getHeight()), success -> {
                ok[0] = success;
                latch.countDown();
            });
            latch.await(300, TimeUnit.MILLISECONDS);
            if (!ok[0]) return null;

            android.graphics.PointF left = mediaPipeFaceLandmarkExtractor.getLastLeftEyeCenter();
            android.graphics.PointF right = mediaPipeFaceLandmarkExtractor.getLastRightEyeCenter();
            if (left == null || right == null) return null;

            // Compute angle and scale to align eyes horizontally to canonical distance
            double dx = right.x - left.x;
            double dy = right.y - left.y;
            double angle = Math.atan2(dy, dx);
            double eyeDist = Math.hypot(dx, dy);
            if (eyeDist < 1.0) return null;

            // Canonical eye positions in 160x160 (approx FaceNet canonical)
            float cxLeft = 54f;  // tweakable
            float cyLeft = 64f;
            float cxRight = 106f;
            float cyRight = 64f;
            double targetDist = Math.hypot(cxRight - cxLeft, cyRight - cyLeft);
            float scale = (float) (targetDist / eyeDist);

            android.graphics.Matrix m = new android.graphics.Matrix();
            m.postTranslate(-left.x, -left.y);
            m.postRotate((float) (-Math.toDegrees(angle)));
            m.postScale(scale, scale);
            m.postTranslate(cxLeft, cyLeft);

            Bitmap aligned = Bitmap.createBitmap(160, 160, Bitmap.Config.ARGB_8888);
            android.graphics.Canvas c = new android.graphics.Canvas(aligned);
            c.drawBitmap(faceBitmap, m, null);
            return aligned;
        } catch (Exception ignore) {
            return null;
        }
    }
    
    /**
     * Close and release all resources
     */
    public void close() {
        try {
            // Close MediaPipeFaceLandmarkExtractor
            if (mediaPipeFaceLandmarkExtractor != null) {
                mediaPipeFaceLandmarkExtractor.close();
                mediaPipeFaceLandmarkExtractor = null;
            }
            
            // Close other components if they have close methods
            if (faceDetector != null && faceDetector instanceof AutoCloseable) {
                try {
                    ((AutoCloseable) faceDetector).close();
                } catch (Exception e) {
                }
            }
            
            if (faceEmbedding != null && faceEmbedding instanceof AutoCloseable) {
                try {
                    ((AutoCloseable) faceEmbedding).close();
                } catch (Exception e) {
                }
            }
            
            if (faceSpoofDetector != null && faceSpoofDetector instanceof AutoCloseable) {
                try {
                    ((AutoCloseable) faceSpoofDetector).close();
                } catch (Exception e) {
                }
            }
            
            if (gazeEstimator != null && gazeEstimator instanceof AutoCloseable) {
                try {
                    ((AutoCloseable) gazeEstimator).close();
                } catch (Exception e) {
                }
            }
            
        } catch (Exception e) {
        }
    }

    /**
     * Extract face embedding from bitmap
     * @param bitmap Face bitmap
     * @param faceRect Face bounding box (can be null, will be detected automatically)
     * @return Face embedding as float array (512 dimensions), or null if extraction fails
     */
    public float[] extractFaceEmbedding(Bitmap bitmap, Rect faceRect) {
        if (!isInitialized()) {
            return null;
        }

        if (faceEmbedding == null) {
            return null;
        }

        try {
            Bitmap faceBitmap;
            
            // If face rect provided, crop to that region
            if (faceRect != null && faceRect.width() > 0 && faceRect.height() > 0) {
                // Ensure rect is within bitmap bounds
                int left = Math.max(0, faceRect.left);
                int top = Math.max(0, faceRect.top);
                int right = Math.min(bitmap.getWidth(), faceRect.right);
                int bottom = Math.min(bitmap.getHeight(), faceRect.bottom);
                int width = right - left;
                int height = bottom - top;
                
                if (width > 0 && height > 0) {
                    faceBitmap = Bitmap.createBitmap(bitmap, left, top, width, height);
                } else {
                    return null;
                }
            } else {
                // Use full bitmap if no rect provided
                faceBitmap = bitmap;
            }

            // Generate embedding
            float[] embedding = faceEmbedding.getFaceEmbedding(faceBitmap);
            
            if (embedding != null && embedding.length > 0) {
                return embedding;
            } else {
                return null;
            }
            
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Extract face embedding from bitmap and convert to Base64 string
     * 🆕 For new event-driven attendance flow
     * 
     * @param bitmap Face image bitmap
     * @return Base64-encoded embedding (512 float32 = 2048 bytes), or null if failed
     */
    public String extractFaceEmbeddingBase64(Bitmap bitmap) {
        try {
            // Extract embedding using existing method
            float[] embedding = extractFaceEmbedding(bitmap, null);
            if (embedding == null || embedding.length == 0) {
                android.util.Log.e(TAG, "Failed to extract face embedding");
                return null;
            }

            // Convert float[] to byte[] (little-endian)
            java.nio.ByteBuffer byteBuffer = java.nio.ByteBuffer.allocate(embedding.length * 4);
            byteBuffer.order(java.nio.ByteOrder.LITTLE_ENDIAN);
            for (float value : embedding) {
                byteBuffer.putFloat(value);
            }
            byte[] embeddingBytes = byteBuffer.array();

            // Encode to Base64
            String base64 = android.util.Base64.encodeToString(embeddingBytes, android.util.Base64.NO_WRAP);
            android.util.Log.d(TAG, "✅ Face embedding encoded to Base64: " + base64.length() + " chars (" + embeddingBytes.length + " bytes)");
            
            return base64;
            
        } catch (Exception e) {
            android.util.Log.e(TAG, "❌ Error converting embedding to Base64", e);
            return null;
        }
    }
}
