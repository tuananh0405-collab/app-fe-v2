//FaceSpoofDetector.java
package com.example.flutter_application_1.faceid.data.service;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.Rect;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.widget.Toast;


import org.tensorflow.lite.DataType;
import org.tensorflow.lite.Interpreter;
import org.tensorflow.lite.support.common.FileUtil;
import org.tensorflow.lite.support.common.ops.CastOp;
import org.tensorflow.lite.support.image.ImageProcessor;
import org.tensorflow.lite.support.image.TensorImage;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.io.File;
import java.io.FileOutputStream;
import java.nio.MappedByteBuffer;
import java.util.Arrays;
import java.util.Objects;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import lombok.Getter;
import com.example.flutter_application_1.faceid.util.InterpreterOptionsFactory;

public class FaceSpoofDetector {
    private static final String TAG = "FaceSpoofDetector";
    private static final String MODEL_FILE_1 = "spoof_model_scale_2_7.tflite";
    private static final String MODEL_FILE_2 = "spoof_model_scale_4_0.tflite";

    private static final float SCALE_1 = 2.7f;
    private static final float SCALE_2 = 4.0f;
    private static final int INPUT_IMAGE_DIM = 80;
    private static final int OUTPUT_DIM = 3;

    private final java.util.Queue<TemporalFrameData> frameHistory = new java.util.LinkedList<>();
    private static final boolean DEBUG_SPOOF = false; // Simplified debugging

    private Interpreter firstModelInterpreter;
    private Interpreter secondModelInterpreter;
    private ImageProcessor imageTensorProcessor;
    private boolean useMockDetection = false;
    private final Object interpreterLock = new Object();
    private final Executor executor = Executors.newSingleThreadExecutor();
    private final Handler mainHandler = new Handler(Looper.getMainLooper());

    private volatile boolean isInitialized = false;
    private final CountDownLatch initLatch = new CountDownLatch(1);


    /**
     * Class to track temporal data for analysis (kept for future use if needed)
     */
    private static class TemporalFrameData {
        final float[] combinedResult;
        final Rect faceRect;
        final long timestamp;
        
        TemporalFrameData(float[] combinedResult, Rect faceRect) {
            this.combinedResult = combinedResult.clone();
            this.faceRect = new Rect(faceRect);
            this.timestamp = System.currentTimeMillis();
        }
    }

    public static class SpoofResult {
        private final boolean isSpoof;
        @Getter
        private final float score;
        @Getter
        private final long timeMillis;

        public SpoofResult(boolean isSpoof, float score, long timeMillis) {
            this.isSpoof = isSpoof;
            this.score = score;
            this.timeMillis = timeMillis;
        }

        public boolean isSpoof() {
            return isSpoof;
        }

        public float getConfidence() {
            // The 'score' field already represents the confidence of the spoof detection.
            // This method provides a more explicit getter for it.
            return score;
        }
    }

    public FaceSpoofDetector(Context context) {
        // Initialize model asynchronously
        executor.execute(() -> {
            try {
                try {
                    // Initialize TFLiteInterpreter with OnDevice-like options (CPU, 4 threads)
                    Interpreter.Options interpreterOptions = new Interpreter.Options();
                    try { interpreterOptions.setNumThreads(4); } catch (Throwable ignore) {}
                    try { interpreterOptions.setUseXNNPACK(true); } catch (Throwable ignore) {}

                    // Load models from assets
                    MappedByteBuffer model1Buffer = FileUtil.loadMappedFile(context, MODEL_FILE_1);
                    MappedByteBuffer model2Buffer = FileUtil.loadMappedFile(context, MODEL_FILE_2);

                    // Create interpreters
                    firstModelInterpreter = new Interpreter(model1Buffer, interpreterOptions);
                    secondModelInterpreter = new Interpreter(model2Buffer, interpreterOptions);
                    try {
                        // Ensure expected input shape [1,80,80,3]
                        firstModelInterpreter.resizeInput(0, new int[]{1, INPUT_IMAGE_DIM, INPUT_IMAGE_DIM, 3});
                        secondModelInterpreter.resizeInput(0, new int[]{1, INPUT_IMAGE_DIM, INPUT_IMAGE_DIM, 3});
                    } catch (Throwable ignore) {}
                    try { firstModelInterpreter.allocateTensors(); } catch (Throwable ignore) {}
                    try { secondModelInterpreter.allocateTensors(); } catch (Throwable ignore) {}
                    // Warmup both models with NHWC 4D input shape
                    try {
                        float[][][][] dummy = new float[1][INPUT_IMAGE_DIM][INPUT_IMAGE_DIM][3];
                        int outDim1 = firstModelInterpreter.getOutputTensor(0).shape()[1];
                        int outDim2 = secondModelInterpreter.getOutputTensor(0).shape()[1];
                        int outDim = Math.min(outDim1, outDim2);
                        float[][] out1 = new float[1][outDim];
                        float[][] out2 = new float[1][outDim];
                        firstModelInterpreter.run(dummy, out1);
                        secondModelInterpreter.run(dummy, out2);
                    } catch (Throwable warm) {
                        Log.e(TAG, "Warmup ignored: " + warm.getMessage(), warm);
                    }

                    // Create image processor for preprocessing
                    imageTensorProcessor = new ImageProcessor.Builder()
                            .add(new CastOp(DataType.FLOAT32))
                            .build();

                    isInitialized = true;
                } catch (Exception e) {
                    Log.e(TAG, "Error initializing TensorFlow Lite model: " + e.getMessage(), e);
                    mainHandler.post(() ->
                            Toast.makeText(context, "Error loading spoof detection model: " + e.getMessage(), Toast.LENGTH_LONG).show()
                    );
                    useMockDetection = true;
                }
            } catch (Exception e) {
                Log.e(TAG, "Error checking model files: " + e.getMessage(), e);
                mainHandler.post(() ->
                        Toast.makeText(context, "Error checking spoof detection model: " + e.getMessage(), Toast.LENGTH_LONG).show()
                );
                useMockDetection = true;
            } finally {
                initLatch.countDown();
            }
        });
    }

    public boolean isInitialized() {
        return isInitialized && firstModelInterpreter != null && secondModelInterpreter != null;
    }

    public void awaitInitialization(long timeoutMs) throws InterruptedException {
        initLatch.await(timeoutMs, TimeUnit.MILLISECONDS);
    }

    /**
     * Detect if a face is spoofed asynchronously with oval boundary validation
     *
     * @param frameImage Original frame image
     * @param faceRect   Face bounding box
     * @param ovalRect   Oval guide boundaries (optional, can be null)
     * @param callback   Callback for result
     */
    public void detectSpoofAsync(Bitmap frameImage, Rect faceRect, android.graphics.RectF ovalRect, SpoofCallback callback) {
        executor.execute(() -> {
            try {
                // Ensure model is initialized
                if (!isInitialized()) {
                    try {
                        awaitInitialization(5000);
                    } catch (InterruptedException e) {
                        Log.e(TAG, "Model initialization interrupted", e);
                    }
                }

                SpoofResult result = detectSpoof(frameImage, faceRect, ovalRect);
                mainHandler.post(() -> callback.onResult(result));
            } catch (Exception e) {
                Log.e(TAG, "Error in spoof detection", e);
                mainHandler.post(() -> callback.onResult(new SpoofResult(true, 0.75f, 0))); // Default to spoof on error for security
            }
        });
    }

    /**
     * Callback interface for spoof detection
     */
    public interface SpoofCallback {
        void onResult(SpoofResult result);
    }

    private static void ensureAllocatedSafe(Interpreter i) {
        try { if (i != null) i.allocateTensors(); } catch (Throwable ignore) {}
    }

    public SpoofResult detectSpoof(Bitmap frameImage, Rect faceRect, android.graphics.RectF ovalRect) {
        long startTime = System.currentTimeMillis();

        // If using mock detection or interpreter not initialized, always return not spoof
        if (useMockDetection || firstModelInterpreter == null || secondModelInterpreter == null || imageTensorProcessor == null) {
            return new SpoofResult(false, 0.95f, System.currentTimeMillis() - startTime);
        }

        try {
            // Validate face rect
            if (faceRect.width() <= 0 || faceRect.height() <= 0) {
                Log.e(TAG, "Invalid face rect size: " + faceRect);
                return new SpoofResult(false, 0.5f, System.currentTimeMillis() - startTime);
            }

            // Crop and scale face image with the two given constants (exactly like OnDevice)
            Bitmap croppedImage1 = crop(
                    frameImage,
                    faceRect,
                    SCALE_1,
                    INPUT_IMAGE_DIM,
                    INPUT_IMAGE_DIM
            );

            // Convert RGB to BGR (exactly like OnDevice)
            Bitmap bgrImage1 = convertRgbToBgr(croppedImage1);

            Bitmap croppedImage2 = crop(
                    frameImage,
                    faceRect,
                    SCALE_2,
                    INPUT_IMAGE_DIM,
                    INPUT_IMAGE_DIM
            );

            // Convert RGB to BGR (exactly like OnDevice)
            Bitmap bgrImage2 = convertRgbToBgr(croppedImage2);

            // Process images (exactly like OnDevice: only CastOp)
            TensorImage tensorImage1 = imageTensorProcessor.process(TensorImage.fromBitmap(bgrImage1));
            TensorImage tensorImage2 = imageTensorProcessor.process(TensorImage.fromBitmap(bgrImage2));

            // Get buffers from TensorImages
            ByteBuffer input1 = tensorImage1.getBuffer();
            ByteBuffer input2 = tensorImage2.getBuffer();

            // Use fixed OUTPUT_DIM like OnDevice instead of dynamic detection
            float[][] output1 = new float[1][OUTPUT_DIM];
            float[][] output2 = new float[1][OUTPUT_DIM];

            // Run inference
            synchronized (interpreterLock) {
                ensureAllocatedSafe(firstModelInterpreter);
                ensureAllocatedSafe(secondModelInterpreter);
                firstModelInterpreter.run(input1, output1);
                secondModelInterpreter.run(input2, output2);
            }

            // Apply softmax to outputs (exactly like OnDevice)
            float[] softmax1 = softMax(output1[0]);
            float[] softmax2 = softMax(output2[0]);

            // Combine probabilities by summation (exactly like OnDevice)
            float[] combined = new float[OUTPUT_DIM];
            for (int i = 0; i < OUTPUT_DIM; i++) {
                combined[i] = softmax1[i] + softmax2[i];
            }
            
            // Find max index (exactly like OnDevice)
            int label = 0;
            float maxVal = combined[0];
            for (int i = 1; i < OUTPUT_DIM; i++) {
                if (combined[i] > maxVal) {
                    maxVal = combined[i];
                    label = i;
                }
            }

            // Decision logic: index 1 is real, others are spoof (exactly like OnDevice)
            boolean isSpoof = label != 1;
            float score = combined[label] / 2.0f;

            long timeMillis = System.currentTimeMillis() - startTime;
            return new SpoofResult(isSpoof, score, timeMillis);

        } catch (Throwable e) {
            Log.e(TAG, "Error in spoof detection: " + e.getMessage(), e);
            return new SpoofResult(true, 0.85f, System.currentTimeMillis() - startTime);
        }
    }


    /**
     * Convert RGB image to BGR
     */
    private Bitmap convertRgbToBgr(Bitmap input) {
        Bitmap output = input.copy(input.getConfig(), true);

        for (int i = 0; i < output.getWidth(); i++) {
            for (int j = 0; j < output.getHeight(); j++) {
                int pixel = output.getPixel(i, j);
                output.setPixel(i, j, Color.rgb(
                        Color.blue(pixel),
                        Color.green(pixel),
                        Color.red(pixel)
                ));
            }
        }

        return output;
    }

    /**
     * Apply softmax to array
     */
    private float[] softMax(float[] x) {
        float[] exp = new float[x.length];
        float sum = 0.0f;

        // Calculate exp and sum
        for (int i = 0; i < x.length; i++) {
            exp[i] = (float) Math.exp(x[i]);
            sum += exp[i];
        }

        // Normalize
        for (int i = 0; i < exp.length; i++) {
            exp[i] = exp[i] / sum;
        }

        return exp;
    }

    /**
     * Crop and scale face region
     */
    private Bitmap crop(Bitmap origImage, Rect bbox, float bboxScale, int targetWidth, int targetHeight) {
        int srcWidth = origImage.getWidth();
        int srcHeight = origImage.getHeight();

        // Scale bounding box
        Rect scaledBox = getScaledBox(srcWidth, srcHeight, bbox, bboxScale);

        // Crop image
        Bitmap croppedBitmap = Bitmap.createBitmap(
                origImage,
                scaledBox.left,
                scaledBox.top,
                scaledBox.width(),
                scaledBox.height()
        );

        // Resize to target dimensions
        Bitmap resizedBitmap = Bitmap.createScaledBitmap(croppedBitmap, targetWidth, targetHeight, true);
        return resizedBitmap;
    }

    /**
     * Scale bounding box
     */
    private Rect getScaledBox(int imgWidth, int imgHeight, Rect box, float bboxScale) {
        int x = box.left;
        int y = box.top;
        int w = box.width();
        int h = box.height();


        // Calculate scale around center, clamp to image bounds – no artificial cap
        float scale = Math.min(Math.min((imgHeight - 1f) / h, (imgWidth - 1f) / w), bboxScale);

        float newWidth = w * scale;
        float newHeight = h * scale;
        float centerX = w / 2f + x;
        float centerY = h / 2f + y;

        float topLeftX = centerX - newWidth / 2f;
        float topLeftY = centerY - newHeight / 2f;
        float bottomRightX = centerX + newWidth / 2f;
        float bottomRightY = centerY + newHeight / 2f;

        // Ensure box is within image bounds
        if (topLeftX < 0) {
            bottomRightX -= topLeftX;
            topLeftX = 0;
        }
        if (topLeftY < 0) {
            bottomRightY -= topLeftY;
            topLeftY = 0;
        }
        if (bottomRightX > imgWidth - 1) {
            topLeftX -= (bottomRightX - (imgWidth - 1));
            bottomRightX = imgWidth - 1;
        }
        if (bottomRightY > imgHeight - 1) {
            topLeftY -= (bottomRightY - (imgHeight - 1));
            bottomRightY = imgHeight - 1;
        }

        Rect result = new Rect((int) topLeftX, (int) topLeftY, (int) bottomRightX, (int) bottomRightY);
        return result;
    }

    /**
     * Release resources
     */
    public void close() {
        if (firstModelInterpreter != null) {
            firstModelInterpreter.close();
        }
        if (secondModelInterpreter != null) {
            secondModelInterpreter.close();
        }
    }
}
