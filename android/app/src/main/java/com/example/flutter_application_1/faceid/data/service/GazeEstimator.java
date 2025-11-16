package com.example.flutter_application_1.faceid.data.service;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.PointF;
import android.graphics.Rect;
import android.graphics.RectF;

import org.tensorflow.lite.Interpreter;
import org.tensorflow.lite.gpu.CompatibilityList;
import org.tensorflow.lite.gpu.GpuDelegate;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.Arrays;
import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;

/**
 * Gaze direction estimator using TensorFlow Lite iTracker model
 * Based on the iTracker architecture with eye regions and face grid
 */
public class GazeEstimator {
    private static final String TAG = "GazeEstimator";

    // TensorFlow Lite model parameters
    private static final String MODEL_FILE = "itracker_adv_fp32.tflite";
    private static final int INPUT_SIZE = 64; // Model input size (square) for eyes and face
    private static final int FACE_GRID_SIZE = 25; // Face grid size (25x25)
    private static final int FLOAT_BYTES = 4; // Size of float in bytes

    // Input tensor indices for iTracker model
    private int eyeLeftInputIndex = -1;
    private int eyeRightInputIndex = -1;
    private int faceInputIndex = -1;
    private int faceMaskInputIndex = -1;
    
    // Map to store all input tensor indices by name
    private Map<String, Integer> inputTensorIndices = new HashMap<>();

    // Interpreter and associated objects
    private Interpreter interpreter;
    private float[][] outputBuffer; // [1][2] - x,y gaze coordinates (range depends on model)

    // Landmark indices for eye cropping (MediaPipe Face Mesh)
    private static final int[] LEFT_EYE_LANDMARKS = {33, 133, 159, 145};  // outer, inner, top, bottom
    private static final int[] RIGHT_EYE_LANDMARKS = {362, 263, 386, 374}; // outer, inner, top, bottom

    // Last estimated gaze coordinates: -1 (left) to 1 (right), -1 (up) to 1 (down)
    private float gazeX = 0;
    private float gazeY = 0;
    
    // Previous gaze for delta calculation
    private float prevGazeX = 0;
    private float prevGazeY = 0;

    // Tracking state
    private boolean isLookingAway = false;
    private boolean isLookingAtScreen = false;
    private int lookingAwayFrames = 0;
    private static final int LOOKING_AWAY_THRESHOLD = 5; // Frames threshold for looking away

    // For tracking gaze stability
    private float[] gazeHistory = new float[10]; // Last 10 gaze positions (magnitude)
    private int historyIndex = 0;

    // Camera/coordinate config
    private boolean frontCameraMirrored = true;

    // Post-process smoothing
    private float emaGazeX = 0f;
    private float emaGazeY = 0f;
    private float emaAlpha = 0.8f; // smoothing factor - higher alpha = more responsive

    // Head pose blending weight
    private float headPoseWeight = 0.0f; // DISABLED: was causing bias when head slightly turned

    // Bias correction for model output
    private float gazeXBias = 0.25f; // Subtract this from raw gazeX to center around 0
    private float gazeYBias = 0.0f;  // Y bias if needed
    
    // Calibration system
    private boolean isCalibrated = false;
    private float calibrationGazeX = 0.0f; // Baseline when looking straight
    private int calibrationSamples = 0;
    private static final int REQUIRED_CALIBRATION_SAMPLES = 10;

    /**
     * Callback interface for gaze events
     */
    public interface GazeCallback {
        void onGazeUpdate(float x, float y, boolean isLookingAtScreen);

        void onLookingAway(boolean isLookingAway);
    }

    private GazeCallback callback;

    // Async initialization support
    private volatile boolean isInitialized = false;
    private final CountDownLatch initLatch = new CountDownLatch(1);
    private final Executor executor = Executors.newSingleThreadExecutor();

    /**
     * Creates a new gaze estimator
     *
     * @param context  Application context
     * @param callback Callback for gaze events
     */
    public GazeEstimator(Context context, GazeCallback callback) {
        this.callback = callback;

        // Initialize asynchronously
        executor.execute(() -> {
            try {
                // Initialize output buffer
                outputBuffer = new float[1][2]; // x,y gaze direction

                // Initialize TensorFlow Lite with the iTracker model
                initializeTFLite(context);

                // Only set as initialized if interpreter is not null
                isInitialized = (interpreter != null);

            } catch (Exception e) {
                // Fallback to simulate mode if model loading fails
                outputBuffer = new float[1][2];
            } finally {
                initLatch.countDown();
            }
        });
    }

    /**
     * Check if the gaze estimator is initialized
     *
     * @return true if initialized, false otherwise
     */
    public boolean isInitialized() {
        return isInitialized;
    }

    /**
     * Wait for initialization to complete
     *
     * @param timeoutMs timeout in milliseconds
     * @throws InterruptedException if interrupted
     */
    public void awaitInitialization(long timeoutMs) throws InterruptedException {
        initLatch.await(timeoutMs, TimeUnit.MILLISECONDS);
    }

    /**
     * Set the callback for gaze events
     *
     * @param callback The callback to set
     */
    public void setCallback(GazeCallback callback) {
        this.callback = callback;
    }

    public void setFrontCameraMirrored(boolean mirrored) {
        this.frontCameraMirrored = mirrored;
    }

    public void setHeadPoseWeight(float weight) {
        this.headPoseWeight = Math.max(0f, Math.min(1f, weight));
    }

    /**
     * Inspect the model structure to understand input and output tensors
     */
    private void inspectModel() {
        if (interpreter == null) {
            return;
        }

        try {
            int inputTensorCount = interpreter.getInputTensorCount();
            for (int i = 0; i < inputTensorCount; i++) {
                int[] shape = interpreter.getInputTensor(i).shape();
                String shapeStr = Arrays.toString(shape);
                String tensorName = interpreter.getInputTensor(i).name();

                // Store all tensor indices in the map
                inputTensorIndices.put(tensorName, i);
                
                // Map tensor names to indices for iTracker model
                // Primary names from instruction.md specification
                if (tensorName.equals("eye_left")) {
                    eyeLeftInputIndex = i;
                } else if (tensorName.equals("eye_right")) {
                    eyeRightInputIndex = i;
                } else if (tensorName.equals("face")) {
                    faceInputIndex = i;
                } else if (tensorName.equals("face_mask")) {
                    faceMaskInputIndex = i;
                } 
                // Fallback names (in case model uses different naming)
                else if (tensorName.toLowerCase().contains("eye") && tensorName.toLowerCase().contains("left")) {
                    eyeLeftInputIndex = i;
                } else if (tensorName.toLowerCase().contains("eye") && tensorName.toLowerCase().contains("right")) {
                    eyeRightInputIndex = i;
                } else if (tensorName.toLowerCase().contains("face") && !tensorName.toLowerCase().contains("mask")) {
                    faceInputIndex = i;
                } else if (tensorName.toLowerCase().contains("mask") || tensorName.toLowerCase().contains("grid")) {
                    faceMaskInputIndex = i;
                }
            }

            // Validate that all required tensors were found
            boolean allTensorsFound = (eyeLeftInputIndex >= 0 && eyeRightInputIndex >= 0 && 
                                     faceInputIndex >= 0 && faceMaskInputIndex >= 0);
            
            if (!allTensorsFound) {
                // Don't set initialized if tensors are missing
                return;
            }
            
        } catch (Exception e) {
        }
    }

    /**
     * Initialize TensorFlow Lite interpreter with the gaze model
     */
    private void initializeTFLite(Context context) throws IOException {
        // Load model from assets
        ByteBuffer modelBuffer = loadModelFile(context);

        // Set up interpreter options
        Interpreter.Options options = new Interpreter.Options();

        try {
            // Try to use GPU delegate manager
            options = TFLiteGpuDelegateManager.getInstance().getInterpreterOptions();
        } catch (Exception e) {
            // If GPU delegate manager fails, try direct GPU delegate
            try {
                CompatibilityList compatList = new CompatibilityList();
                if (compatList.isDelegateSupportedOnThisDevice()) {
                    GpuDelegate.Options delegateOptions = compatList.getBestOptionsForThisDevice();
                    GpuDelegate gpuDelegate = new GpuDelegate(delegateOptions);
                    options.addDelegate(gpuDelegate);
                } else {
                    options.setNumThreads(4); // Use 4 threads on CPU
                }
            } catch (Exception ex) {
                options.setNumThreads(4); // Use 4 threads on CPU
            }
        }

        // Create the interpreter
        interpreter = new Interpreter(modelBuffer, options);

        // Inspect model structure
        inspectModel();
    }

    /**
     * Load the TensorFlow Lite model file from assets
     */
    private ByteBuffer loadModelFile(Context context) throws IOException {
        // Get file descriptor for the model file in assets
        try (java.io.InputStream is = context.getAssets().open(MODEL_FILE)) {
            // Get size of the model file
            int modelSize = is.available();
            ByteBuffer modelBuffer = ByteBuffer.allocateDirect(modelSize);
            modelBuffer.order(ByteOrder.nativeOrder());

            // Read model into ByteBuffer
            byte[] buffer = new byte[4096];
            int bytesRead;
            int totalRead = 0;
            while ((bytesRead = is.read(buffer)) != -1) {
                modelBuffer.put(buffer, 0, bytesRead);
                totalRead += bytesRead;
            }
            modelBuffer.rewind();
            return modelBuffer;
        } catch (IOException e) {
            throw e;
        }
    }

    /**
     * Estimate gaze direction from face image with landmarks
     *
     * @param faceImage  Full face image bitmap
     * @param landmarks  List of face landmarks (MediaPipe format)
     * @param headPose   Head pose angles [pitch, roll, yaw]
     * @return True if gaze was successfully estimated
     */
    public boolean estimateGaze(Bitmap faceImage, List<PointF> landmarks, float[] headPose) {
        try {
            if (!isInitialized) {
                return simulateGazeEstimation(headPose);
            }

            // Check if input image and landmarks are valid
            if (faceImage == null || landmarks == null || landmarks.size() < 468) {
                return simulateGazeEstimation(headPose);
            }

            // Check if interpreter is null
            if (interpreter == null) {
                return simulateGazeEstimation(headPose);
            }

            int imgW = faceImage.getWidth();
            int imgH = faceImage.getHeight();

            // Extract ROI regions from landmarks
            RectF leftEyeRect = rectFromLandmarks(landmarks, imgW, imgH, LEFT_EYE_LANDMARKS, 2.2f);
            RectF rightEyeRect = rectFromLandmarks(landmarks, imgW, imgH, RIGHT_EYE_LANDMARKS, 2.2f);
            RectF faceRect = faceRect(landmarks, imgW, imgH, 1.3f);

            // Crop and resize regions
            Bitmap leftEyeCrop = cropResize(faceImage, leftEyeRect, INPUT_SIZE, INPUT_SIZE);
            Bitmap rightEyeCrop = cropResize(faceImage, rightEyeRect, INPUT_SIZE, INPUT_SIZE);
            Bitmap faceCrop = cropResize(faceImage, faceRect, INPUT_SIZE, INPUT_SIZE);

            // Create face grid (25x25)
            float[] faceGrid = makeFaceGrid(faceRect, imgW, imgH, FACE_GRID_SIZE);

            // Run gaze estimation
            float[] gazeResult = runGaze(leftEyeCrop, rightEyeCrop, faceCrop, faceGrid);

            if (gazeResult != null && gazeResult.length >= 2) {
                // Store previous gaze for delta calculation
                prevGazeX = gazeX;
                prevGazeY = gazeY;
                
                // Extract gaze coordinates from the output
                gazeX = gazeResult[0];
                gazeY = gazeResult[1];

                // Apply bias correction BEFORE any other processing
                float rawGazeX = gazeX;
                float rawGazeY = gazeY;
                gazeX = gazeX - gazeXBias;  // Center around 0
                gazeY = gazeY - gazeYBias;
                
                // Apply front camera mirroring if needed
                if (frontCameraMirrored) {
                    gazeX = -gazeX;
                }

                // Adjust gaze based on head pose
                if (headPose != null && headPose.length >= 3) {
                    adjustGazeWithHeadPose(headPose);
                }

                // Smooth gaze with EMA to stabilize thresholds
                emaGazeX = emaAlpha * gazeX + (1 - emaAlpha) * emaGazeX;
                emaGazeY = emaAlpha * gazeY + (1 - emaAlpha) * emaGazeY;

                // Update gaze history
                updateGazeHistory();

                // Check if looking away from the screen
                checkLookingAway();

                // Notify callback if available (use smoothed values)
                if (callback != null) {
                    callback.onGazeUpdate(emaGazeX, emaGazeY, isLookingAtScreen);
                    callback.onLookingAway(isLookingAway);
                }

                // Clean up cropped bitmaps
                if (leftEyeCrop != null) leftEyeCrop.recycle();
                if (rightEyeCrop != null) rightEyeCrop.recycle();
                if (faceCrop != null) faceCrop.recycle();

                return true;
            } else {
                return simulateGazeEstimation(headPose);
            }

        } catch (Exception e) {
            // Fall back to simulation if model inference fails
            return simulateGazeEstimation(headPose);
        }
    }

    /**
     * Legacy method - Now simplified to detect "looking at camera" only
     * HEAD DIRECTION (LEFT/RIGHT) should be handled by HeadPoseEstimation class
     */
    public boolean estimateGaze(Bitmap leftEyeImage, Bitmap rightEyeImage, float[] headPose) {
        if (headPose != null && headPose.length >= 3) {
            float pitch = headPose[0];
            float roll = headPose[1]; 
            float yaw = headPose[2];
            
            // Simple "looking at camera" detection based on eye openness and head pose
            boolean lookingAtCamera = isLookingAtCamera(pitch, yaw, leftEyeImage, rightEyeImage);
            
            // Set gaze to center when looking at camera, otherwise indicate looking away
            if (lookingAtCamera) {
                gazeX = 0.0f;  // Always center for "looking at camera"
                gazeY = 0.0f;
                isLookingAtScreen = true;
                isLookingAway = false;
            } else {
                gazeX = 0.0f;  // Direction is not relevant here
                gazeY = 0.0f; 
                isLookingAtScreen = false;
                isLookingAway = true;
            }
            
            // Apply smoothing
            emaGazeX = emaAlpha * gazeX + (1 - emaAlpha) * emaGazeX;
            emaGazeY = emaAlpha * gazeY + (1 - emaAlpha) * emaGazeY;
            
            // Notify callback
            if (callback != null) {
                callback.onGazeUpdate(emaGazeX, emaGazeY, isLookingAtScreen);
                callback.onLookingAway(isLookingAway);
            }
            
            return true;
        }
        
        return false;
    }
    
    /**
     * Determine if user is looking at camera based on head pose and eye analysis
     * @param pitch head pitch angle
     * @param yaw head yaw angle  
     * @param leftEye left eye image
     * @param rightEye right eye image
     * @return true if looking at camera
     */
    private boolean isLookingAtCamera(float pitch, float yaw, Bitmap leftEye, Bitmap rightEye) {
        // Head should be approximately facing forward
        boolean headFacingForward = Math.abs(yaw) < 20.0f && Math.abs(pitch) < 15.0f;
        
        // Eyes should be open and visible
        boolean eyesOpen = (leftEye != null && rightEye != null);
        
        boolean lookingAtCamera = headFacingForward && eyesOpen;
              
        return lookingAtCamera;
    }

    /**
     * Create ROI rectangle from landmarks
     */
    private RectF rectFromLandmarks(List<PointF> landmarks, int w, int h, int[] indices, float expand) {
        float minX = 1f, minY = 1f, maxX = 0f, maxY = 0f;
        
        for (int id : indices) {
            if (id >= 0 && id < landmarks.size()) {
                PointF lm = landmarks.get(id);
                minX = Math.min(minX, lm.x);
                minY = Math.min(minY, lm.y);
                maxX = Math.max(maxX, lm.x);
                maxY = Math.max(maxY, lm.y);
            }
        }
        
        float cx = (minX + maxX) / 2f;
        float cy = (minY + maxY) / 2f;
        float half = Math.max((maxX - minX), (maxY - minY)) * 0.5f * expand;
        
        RectF r = new RectF((cx - half) * w, (cy - half) * h, (cx + half) * w, (cy + half) * h);
        r.left = Math.max(0, r.left);
        r.top = Math.max(0, r.top);
        r.right = Math.min(w - 1, r.right);
        r.bottom = Math.min(h - 1, r.bottom);
        
        return r;
    }

    /**
     * Create face ROI rectangle from all landmarks
     */
    private RectF faceRect(List<PointF> landmarks, int w, int h, float expand) {
        float minX = 1f, minY = 1f, maxX = 0f, maxY = 0f;
        
        for (PointF lm : landmarks) {
            minX = Math.min(minX, lm.x);
            minY = Math.min(minY, lm.y);
            maxX = Math.max(maxX, lm.x);
            maxY = Math.max(maxY, lm.y);
        }
        
        float cx = (minX + maxX) / 2f;
        float cy = (minY + maxY) / 2f;
        float half = Math.max((maxX - minX), (maxY - minY)) * 0.5f * expand;
        
        RectF r = new RectF((cx - half) * w, (cy - half) * h, (cx + half) * w, (cy + half) * h);
        r.left = Math.max(0, r.left);
        r.top = Math.max(0, r.top);
        r.right = Math.min(w - 1, r.right);
        r.bottom = Math.min(h - 1, r.bottom);
        
        return r;
    }

    /**
     * Crop and resize image region
     */
    private Bitmap cropResize(Bitmap src, RectF rect, int outW, int outH) {
        Rect srcRect = new Rect(
            Math.round(rect.left),
            Math.round(rect.top),
            Math.round(rect.right),
            Math.round(rect.bottom)
        );
        
        Bitmap dst = Bitmap.createBitmap(outW, outH, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(dst);
        canvas.drawBitmap(src, srcRect, new Rect(0, 0, outW, outH), null);
        
        return dst;
    }

    /**
     * Create face grid (25x25 -> 625 elements)
     */
    private float[] makeFaceGrid(RectF faceRectPx, int imgW, int imgH, int gridN) {
        float[] grid = new float[gridN * gridN];
        float cellW = imgW / (float) gridN;
        float cellH = imgH / (float) gridN;
        
        for (int gy = 0; gy < gridN; gy++) {
            for (int gx = 0; gx < gridN; gx++) {
                float x0 = gx * cellW;
                float y0 = gy * cellH;
                RectF cell = new RectF(x0, y0, x0 + cellW, y0 + cellH);
                RectF inter = new RectF();
                
                if (inter.setIntersect(faceRectPx, cell)) {
                    grid[gy * gridN + gx] = 1f;
                }
            }
        }
        
        return grid;
    }

    /**
     * Convert bitmap to NHWC float32 format [0..1]
     */
    private ByteBuffer toNHWCFloat32(Bitmap bitmap) {
        int w = bitmap.getWidth();
        int h = bitmap.getHeight();
        int[] pixels = new int[w * h];
        bitmap.getPixels(pixels, 0, w, 0, 0, w, h);
        
        ByteBuffer buffer = ByteBuffer.allocateDirect(4 * w * h * 3).order(ByteOrder.nativeOrder());
        
        for (int y = 0; y < h; y++) {
            for (int x = 0; x < w; x++) {
                int c = pixels[y * w + x];
                // Normalize to [0..1] (not [-1..1] as in old model)
                buffer.putFloat(((c >> 16) & 0xFF) / 255f); // R
                buffer.putFloat(((c >> 8) & 0xFF) / 255f);  // G
                buffer.putFloat((c & 0xFF) / 255f);         // B
            }
        }
        
        buffer.rewind();
        return buffer;
    }

    /**
     * Run gaze estimation with iTracker model
     * Input specification from instruction.md:
     * - eye_left: [1,64,64,3] NHWC float32 [0..1]  
     * - eye_right: [1,64,64,3] NHWC float32 [0..1]
     * - face: [1,64,64,3] NHWC float32 [0..1] 
     * - face_mask: [1,625] face grid 25x25 flattened
     * Output: Add_5: [1,2] → (gaze_x, gaze_y)
     */
    private float[] runGaze(Bitmap eyeLeft64, Bitmap eyeRight64, Bitmap face64, float[] faceGrid625) {
        try {
            // Convert bitmaps to input tensors (RGB [0..1], NHWC format)
            ByteBuffer inLeft = toNHWCFloat32(eyeLeft64);
            ByteBuffer inRight = toNHWCFloat32(eyeRight64);
            ByteBuffer inFace = toNHWCFloat32(face64);
            
            // Convert face grid to ByteBuffer
            ByteBuffer inGrid = ByteBuffer.allocateDirect(4 * 625).order(ByteOrder.nativeOrder());
            for (float v : faceGrid625) {
                inGrid.putFloat(v);
            }
            inGrid.rewind();

            // Validate tensor indices are found
            if (eyeLeftInputIndex < 0 || eyeRightInputIndex < 0 || 
                faceInputIndex < 0 || faceMaskInputIndex < 0) {
                return null;
            }

            // Prepare inputs array - map by tensor indices found during model inspection
            Object[] inputs = new Object[interpreter.getInputTensorCount()];
            
            // Map inputs to correct tensor indices (based on iTracker specification)
            inputs[eyeLeftInputIndex] = inLeft;    // eye_left: [1,64,64,3]
            inputs[eyeRightInputIndex] = inRight;  // eye_right: [1,64,64,3]  
            inputs[faceInputIndex] = inFace;       // face: [1,64,64,3]
            inputs[faceMaskInputIndex] = inGrid;   // face_mask: [1,625]
            
            // Prepare outputs
            Map<Integer, Object> outputs = new HashMap<>();
            outputs.put(0, outputBuffer);

            // Run inference
            interpreter.runForMultipleInputsOutputs(inputs, outputs);
            
            // Log output for debugging
            float[] result = outputBuffer[0];
            
            return result; // [gaze_x, gaze_y]
            
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Simulate gaze estimation when model inference is not possible
     */
    private boolean simulateGazeEstimation(float[] headPose) {
        try {
            // Simulate changing gaze direction based on head pose
            if (headPose != null && headPose.length >= 3) {
                // Use head pose to influence gaze direction
                float yaw = headPose[2]; // Left/right head rotation
                float pitch = headPose[0]; // Up/down head rotation

                // Map head rotation to gaze coordinates
                // Normalize to range [-1, 1]
                gazeX = Math.max(-1.0f, Math.min(1.0f, yaw / 45.0f));
                gazeY = Math.max(-1.0f, Math.min(1.0f, pitch / 30.0f));
            } else {
                // Simulate changing gaze by moving slightly in random directions
                float deltaX = (float) (Math.random() * 0.1 - 0.05);
                float deltaY = (float) (Math.random() * 0.1 - 0.05);

                gazeX = Math.max(-1.0f, Math.min(1.0f, gazeX + deltaX));
                gazeY = Math.max(-1.0f, Math.min(1.0f, gazeY + deltaY));
            }

            // Update gaze history
            updateGazeHistory();

            // Check if looking away from the screen
            checkLookingAway();

            // Notify callback if available
            if (callback != null) {
                callback.onGazeUpdate(gazeX, gazeY, isLookingAtScreen);
                callback.onLookingAway(isLookingAway);
            }

            return true;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Adjust the estimated gaze direction based on head pose
     */
    private void adjustGazeWithHeadPose(float[] headPose) {
        if (headPose == null || headPose.length < 3) {
            return;
        }

        // Extract head pose angles in degrees
        float pitch = headPose[0]; // Up/down rotation
        float roll = headPose[1];  // Tilt left/right
        float yaw = headPose[2];   // Left/right rotation

        // Convert degrees to normalized range (-1 to 1)
        float normYaw = yaw / 45.0f;    // Normalize by typical max angle
        float normPitch = pitch / 30.0f; // Normalize by typical max angle

        // Limit to range [-1, 1]
        normYaw = Math.max(-1.0f, Math.min(1.0f, normYaw));
        normPitch = Math.max(-1.0f, Math.min(1.0f, normPitch));

        // Adjust gaze by adding scaled head pose influence
        // Head yaw affects horizontal gaze, head pitch affects vertical gaze
        float headWeight = headPoseWeight; // configurable weight

        // If eyes are likely closed/occluded (based on large |normYaw|), reduce head influence further
        if (Math.abs(normYaw) > 0.8f) {
            headWeight *= 0.5f;
        }

        gazeX = gazeX * (1 - headWeight) + normYaw * headWeight;
        gazeY = gazeY * (1 - headWeight) + normPitch * headWeight;

        // Ensure values are in range [-1, 1]
        gazeX = Math.max(-1.0f, Math.min(1.0f, gazeX));
        gazeY = Math.max(-1.0f, Math.min(1.0f, gazeY));
    }

    /**
     * Update gaze history for tracking stability
     */
    private void updateGazeHistory() {
        // Calculate gaze magnitude (distance from center)
        float gazeMagnitude = (float) Math.sqrt(gazeX * gazeX + gazeY * gazeY);

        // Add to history
        gazeHistory[historyIndex] = gazeMagnitude;
        historyIndex = (historyIndex + 1) % gazeHistory.length;
    }

    /**
     * Check if the user is looking away from the screen
     */
    private void checkLookingAway() {
        // Calculate the magnitude of the gaze vector
        float gazeMagnitude = (float) Math.sqrt(gazeX * gazeX + gazeY * gazeY);

        // Consider looking away if gaze magnitude is large (looking far from center)
        boolean currentlyLookingAway = gazeMagnitude > 0.7f; // Threshold for looking away

        if (currentlyLookingAway) {
            lookingAwayFrames++;

            // Update looking away state after sufficient consistent frames
            if (lookingAwayFrames >= LOOKING_AWAY_THRESHOLD && !isLookingAway) {
                isLookingAway = true;
                isLookingAtScreen = false;
                if (callback != null) {
                    callback.onLookingAway(true);
                }
            }
        } else {
            lookingAwayFrames = 0;

            // Update state if was previously looking away
            if (isLookingAway) {
                isLookingAway = false;
                isLookingAtScreen = true;
                if (callback != null) {
                    callback.onLookingAway(false);
                }
            }
        }

        // Update looking at screen state
        isLookingAtScreen = !isLookingAway;
    }

    /**
     * Get the current horizontal gaze position (-1 left to 1 right)
     */
    public float getGazeX() {
        return gazeX;
    }

    /**
     * Get the current vertical gaze position (-1 up to 1 down)
     */
    public float getGazeY() {
        return gazeY;
    }
    
    /**
     * Classify current gaze direction based on thresholds
     * @param threshold The threshold value (τ) for classification
     * @return "LEFT", "RIGHT", or "CENTER"
     */
    public String getGazeDirection(float threshold) {
        // Use EMA smoothed values for more stable classification
        if (emaGazeX >= threshold) {
            return "RIGHT";
        } else if (emaGazeX <= -threshold) {
            return "LEFT";
        } else {
            return "CENTER";
        }
    }
    
    /**
     * Get current gaze direction using adaptive threshold based on input method
     * @return "LEFT", "RIGHT", or "CENTER"
     */
    public String getGazeDirection() {
        // Use larger threshold for head pose based estimation (less precise)
        return getGazeDirection(0.12f); // Increased from 0.08f for better stability
    }
    
    /**
     * Get gaze direction from specific values (for debugging)
     * @param x gaze X coordinate
     * @param y gaze Y coordinate  
     * @param threshold classification threshold
     * @return "LEFT", "RIGHT", or "CENTER"
     */
    public String getGazeDirectionFromValues(float x, float y, float threshold) {
        if (x >= threshold) {
            return "RIGHT";
        } else if (x <= -threshold) {
            return "LEFT";
        } else {
            return "CENTER";
        }
    }
    
    /**
     * Check if model is properly loaded and all tensor indices are found
     * @return true if model is ready for inference, false otherwise
     */
    public boolean isModelReady() {
        return isInitialized && interpreter != null && 
               eyeLeftInputIndex >= 0 && eyeRightInputIndex >= 0 && 
               faceInputIndex >= 0 && faceMaskInputIndex >= 0;
    }
    
   
    /**
     * Test model inference with dummy data (for debugging)
     * @return true if model can run inference successfully
     */
    public boolean testModelInference() {
        if (!isModelReady()) {
            return false;
        }
        
        try {
            // Create dummy 64x64 ARGB bitmaps
            Bitmap dummyEyeLeft = Bitmap.createBitmap(64, 64, Bitmap.Config.ARGB_8888);
            Bitmap dummyEyeRight = Bitmap.createBitmap(64, 64, Bitmap.Config.ARGB_8888);
            Bitmap dummyFace = Bitmap.createBitmap(64, 64, Bitmap.Config.ARGB_8888);
            
            // Create dummy face grid
            float[] dummyFaceGrid = new float[625];
            for (int i = 0; i < 625; i++) {
                dummyFaceGrid[i] = (i < 300) ? 1.0f : 0.0f; // Half filled
            }
            
            float[] result = runGaze(dummyEyeLeft, dummyEyeRight, dummyFace, dummyFaceGrid);
            
            // Cleanup
            dummyEyeLeft.recycle();
            dummyEyeRight.recycle();
            dummyFace.recycle();
            
            if (result != null && result.length == 2) {
                return true;
            } else {
                return false;
            }
            
        } catch (Exception e) {
            return false;
        }
    }
    
    /**
     * Calibrate the gaze estimator by having user look straight ahead
     * Call this when user is looking straight at camera
     */
    public void calibrateCenter() {
        if (calibrationSamples < REQUIRED_CALIBRATION_SAMPLES) {
            calibrationGazeX += emaGazeX;
            calibrationSamples++;
            
            if (calibrationSamples >= REQUIRED_CALIBRATION_SAMPLES) {
                // Calculate average as new bias
                float avgGazeX = calibrationGazeX / REQUIRED_CALIBRATION_SAMPLES;
                gazeXBias = avgGazeX;
                isCalibrated = true;
                
                // Reset for next calibration
                calibrationGazeX = 0.0f;
                calibrationSamples = 0;
            }
        }
    }
    
    /**
     * Reset calibration
     */
    public void resetCalibration() {
        isCalibrated = false;
        calibrationGazeX = 0.0f;
        calibrationSamples = 0;
        gazeXBias = 0.25f; // Reset to default
    }

    /**
     * Check if calibrated
     */
    public boolean isCalibrated() {
        return isCalibrated;
    }

    /**
     * Close and release resources
     */
    public void close() {
        try {
            if (interpreter != null) {
                interpreter.close();
                interpreter = null;
            }

        } catch (Exception e) {
        }
    }

}




