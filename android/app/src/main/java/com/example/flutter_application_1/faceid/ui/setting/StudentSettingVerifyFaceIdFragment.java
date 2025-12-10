package com.example.flutter_application_1.faceid.ui.setting;

import android.Manifest;
import android.animation.ValueAnimator;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.Rect;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.method.ScrollingMovementMethod;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.LinearInterpolator;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.Fragment;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

import com.example.flutter_application_1.R;
import com.example.flutter_application_1.auth.AuthManager;
import com.example.flutter_application_1.databinding.FragmentStudentSettingVerifyFaceIdBinding;
import com.example.flutter_application_1.faceid.data.service.FaceIdConfig;
import com.example.flutter_application_1.faceid.data.service.FaceIdEnhancer;
import com.example.flutter_application_1.faceid.data.service.FaceIdService;
import com.example.flutter_application_1.faceid.data.service.FaceIdServiceManager;
import com.example.flutter_application_1.faceid.data.service.FaceProcessingState;
import com.example.flutter_application_1.faceid.data.service.FaceTracker;
import com.example.flutter_application_1.faceid.ui.components.CameraView;
import com.example.flutter_application_1.faceid.ui.components.OvalFaceOverlayView;
import com.example.flutter_application_1.faceid.ui.setting.controller.FaceVerificationUIController;
import com.example.flutter_application_1.faceid.ui.setting.detection.SpoofDetectionManager;
import com.example.flutter_application_1.faceid.ui.setting.state.FaceRegistrationState;
import com.example.flutter_application_1.faceid.ui.setting.state.FaceRegistrationStateManager;
import com.example.flutter_application_1.faceid.ui.setting.success.FaceIdSuccessActivity;
import com.example.flutter_application_1.faceid.data.service.FaceIdRequestManager;


public class StudentSettingVerifyFaceIdFragment extends Fragment implements FaceIdEnhancer.FaceIdEnhancerCallback {
    // BroadcastReceiver để nhận beacon
    private android.content.BroadcastReceiver beaconReceiver;
    private static final String TAG = "VerifyFaceIdFragment";
    private static final int CAMERA_PERMISSION_REQUEST_CODE = 100;
    private static final int SUCCESS_ACTIVITY_REQUEST_CODE = 200;

    // 🎯 CORE COMPONENTS (Clean Architecture)
    private FragmentStudentSettingVerifyFaceIdBinding binding;
    private FaceRegistrationStateManager stateManager;
    private SpoofDetectionManager spoofDetectionManager;
    private FaceVerificationUIController uiController;
    private FaceTracker faceTracker;
    private FaceIdService faceIdService;
    private FaceIdEnhancer faceIdEnhancer; // Add FaceIdEnhancer
    private boolean faceIdEnhancerInitialized = false;
    
    //  NEW: Face ID Request Manager để quản lý request lifecycle
    private FaceIdRequestManager requestManager;


    // 🔍 ERROR TRACKING
    private String lastDetailedErrorMessage = ""; // Store detailed error information
    private boolean hasDetailedError = false;
    private AlertDialog currentErrorDialog; // Track current error dialog to dismiss when needed
    private String lastStateMessage = ""; // Store the last state message for error display

    // 📷 CAMERA COMPONENTS
    private CameraView cameraView;
    private OvalFaceOverlayView faceOverlayView;
    private boolean isCameraStarted = false;

    // 💾 CURRENT DATA
    private Bitmap currentFrameBitmap;
    private Rect currentFaceRect;

    // 5-Second Analysis
    private final java.util.List<Float> frameScores = new java.util.ArrayList<>();
    private boolean isAnalyzing = false;
    private static final int ANALYSIS_DURATION_MS = 5000;
    private static final float MIN_AVERAGE_SCORE_FOR_REGISTRATION = 0.75f;
    // After liveness is verified, we trust the face is live and should not filter out frames as spoof
    private boolean livenessVerified = false;
    // Analysis stability gating
    private Rect lastAnalysisRect = null;
    private static final float MAX_CENTER_MOVE_RATIO = 0.03f; // 3% of face size
    private static final float MAX_SIZE_DELTA_RATIO = 0.02f;  // 2% size change

    // 🔄 HANDLERS
    private final Handler mainHandler = new Handler(Looper.getMainLooper());

    // 📍 LOCATION
    private LocationManager locationManager;
    private Location currentLocation;

    // 📡 BEACON DATA (stored as instance variables to avoid fragment lifecycle issues)
    private String beaconUuid;
    private int beaconMajor = -1;
    private int beaconMinor = -1;
    private int beaconRssi = -100;
    
    // ✅ SUCCESS FLAG - Prevent processing after successful verification
    private boolean verificationCompleted = false;

    // Verification window control
    private long verifyDeadlineMs = 0L;
    private final Runnable verifyCountdownRunnable = new Runnable() {
        @Override
        public void run() {
            if (!isAdded()) return;
            long remaining = verifyDeadlineMs - System.currentTimeMillis();
            if (remaining <= 0) {
                // Expired: auto close and block further actions
                handleVerificationExpired();
                return;
            }
            // Update status message countdown if visible
            if (binding != null && binding.tvStatusMessage != null) {
                int sec = (int) Math.ceil(remaining / 1000.0);
                binding.tvStatusMessage.setText("Verification window: " + sec + "s left");
            }
            mainHandler.postDelayed(this, 1000);
        }
    };

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater,
                             @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        binding = FragmentStudentSettingVerifyFaceIdBinding.inflate(inflater, container, false);
        return binding.getRoot();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        initializeComponents();
        setupClickListeners();

        // Đảm bảo biến analysisOverlay ban đầu là null để thiết lập UI phân tích khi cần
        analysisOverlay = null;

        Log.d(TAG, " Fragment initialized with clean architecture");

        // Setup verification window from deeplink/args
        setupVerificationWindowFromArgs();
        startVerificationCountdown();

        startVerificationCountdown();

        // Khởi động BeaconScanService - MOVED to checkRequiredPermissions to ensure permissions first

        // Đăng ký receiver để nhận beacon
        beaconReceiver = new android.content.BroadcastReceiver() {
            @Override
            public void onReceive(android.content.Context context, Intent intent) {
                try {
                    // Check if Fragment is still attached and state is not saved
                    if (!isAdded() || isStateSaved()) {
                        Log.d(TAG, "Fragment not attached or state saved, ignoring beacon broadcast");
                        return;
                    }
                    
                    if ("com.example.flutter_application_1.BEACON_FOUND".equals(intent.getAction())) {
                        String uuid = intent.getStringExtra("beaconUuid");
                        int major = intent.getIntExtra("beaconMajor", -1);
                        int minor = intent.getIntExtra("beaconMinor", -1);
                        int rssi = intent.getIntExtra("rssi", -100);
                        
                        // Store beacon data in instance variables instead of modifying arguments
                        // This prevents "Fragment already added and state has been saved" crash
                        beaconUuid = uuid;
                        beaconMajor = major;
                        beaconMinor = minor;
                        beaconRssi = rssi;
                    }
                } catch (Exception e) {
                    Log.e(TAG, "Error processing beacon broadcast: " + e.getMessage(), e);
                }
            }
        };
        android.content.IntentFilter filter = new android.content.IntentFilter("com.example.flutter_application_1.BEACON_FOUND");
        requireActivity().registerReceiver(beaconReceiver, filter);
    }

    private void setupVerificationWindowFromArgs() {
        long now = System.currentTimeMillis();
        long deadline = 0L;
        String requestId = null;
        String sessionId = null;
        
        Bundle args = getArguments();
        if (args != null) {
            // Get requestId and sessionId from deeplink
            requestId = args.getString("requestId", null);
            sessionId = args.getString("sessionId", null);
            
            // Get expiration time
            if (args.containsKey("verify_deadline_ms")) {
                deadline = args.getLong("verify_deadline_ms", 0L);
            } else if (args.containsKey("expires_in_sec")) {
                int sec = args.getInt("expires_in_sec", 0);
                if (sec > 0) deadline = now + sec * 1000L;
            } else if (args.containsKey("durationMinutes")) {
                int min = args.getInt("durationMinutes", 0);
                if (min > 0) deadline = now + min * 60_000L;
            } else if (args.containsKey("expires_at")) {
                String iso = args.getString("expires_at");
                try {
                    // Use SimpleDateFormat instead of java.time.Instant for API 24 compatibility
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US);
                    sdf.setTimeZone(java.util.TimeZone.getTimeZone("UTC"));
                    Date date = sdf.parse(iso);
                    deadline = date.getTime();
                } catch (ParseException e) {
                    // Try alternative format without milliseconds
                    try {
                        SimpleDateFormat sdf2 = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.US);
                        sdf2.setTimeZone(java.util.TimeZone.getTimeZone("UTC"));
                        Date date2 = sdf2.parse(iso);
                        deadline = date2.getTime();
                    } catch (ParseException ignored) {
                        Log.w(TAG, "Failed to parse ISO timestamp: " + iso);
                    }
                }
            }
        }
        
        if (deadline == 0L) {
            // Fallback default 5 minutes
            deadline = now + 5 * 60_000L;
        }
        
        verifyDeadlineMs = deadline;
        Log.d(TAG, "Verify deadline set to: " + verifyDeadlineMs + " (in " + ((verifyDeadlineMs - now) / 1000) + "s)");
        
        //  NEW: Initialize FaceIdRequestManager nếu có requestId
        if (requestId != null && sessionId != null) {
            Log.d(TAG, " Initializing Face ID request: " + requestId + " for session: " + sessionId);
            requestManager.initializeRequest(requestId, sessionId, deadline);
        } else {
            Log.d(TAG, "⚠️ No requestId/sessionId found, using legacy verification mode");
        }
    }

    private void startVerificationCountdown() {
        mainHandler.removeCallbacks(verifyCountdownRunnable);
        if (verifyDeadlineMs > System.currentTimeMillis()) {
            mainHandler.post(verifyCountdownRunnable);
        } else {
            handleVerificationExpired();
        }
    }

    private String getRequestIdFromArgs() {
        // 1) Try fragment arguments
        Bundle args = getArguments();
        String id = null;
        if (args != null) {
            id = args.getString("requestId", null);
            if (id != null && !id.isEmpty()) return id;
        }

        // 2) Try activity intent extras (Verify Activity passes these)
        try {
            if (isAdded()) {
                android.content.Intent intent = requireActivity().getIntent();
                if (intent != null) {
                    String fromExtra = intent.getStringExtra("requestId");
                    if (fromExtra != null && !fromExtra.isEmpty()) return fromExtra;

                    // 3) Try deeplink URI query param directly if present
                    android.net.Uri data = intent.getData();
                    if (data != null && "zentry".equals(data.getScheme()) && "face-verify".equals(data.getHost())) {
                        String fromUri = data.getQueryParameter("requestId");
                        if (fromUri != null && !fromUri.isEmpty()) return fromUri;
                    }
                }
            }
        } catch (Exception ignored) {}

        // 4) Fallback to pending args stored by MainActivity (still sourced from deeplink)
        try {
            if (isAdded()) {
                android.content.SharedPreferences prefs = requireActivity().getSharedPreferences("face_verification", android.content.Context.MODE_PRIVATE);
                String fromPrefs = prefs.getString("pending_request_id", null);
                if (fromPrefs != null && !fromPrefs.isEmpty()) return fromPrefs;
            }
        } catch (Exception ignored) {}

        return null;
    }

    private boolean isVerificationWindowActive() {
        return System.currentTimeMillis() < verifyDeadlineMs;
    }

    private void handleVerificationExpired() {
        if (!isAdded()) return;
        mainHandler.removeCallbacks(verifyCountdownRunnable);
        // Stop camera and exit with message
        stopCameraSafe();
        Toast.makeText(requireContext(), "Verification window expired.", Toast.LENGTH_LONG).show();
        requireActivity().onBackPressed();
    }

    private void stopCameraSafe() {
        try {
            if (cameraView != null) cameraView.stopCamera();
        } catch (Exception ignored) {}
    }

    /**
     * 🏗️ Initialize all core components
     */
    private void initializeComponents() {
        // 1. State Manager with callback
        stateManager = new FaceRegistrationStateManager();
        stateManager.setStateChangeListener(this::onStateChanged);

        // 2. Camera and Overlay
        setupCameraAndOverlay();

        // 3. UI Controller
        uiController = new FaceVerificationUIController(binding, faceOverlayView);
        uiController.showScreen(FaceVerificationUIController.UIScreenState.SETUP);

        // 4. Face Tracker with optimized settings for stability
        faceTracker = new FaceTracker(10); // Increased from 8 to 10 frames for better stability (~ 0.33 seconds)

        //  NEW: Initialize FaceIdRequestManager
        requestManager = new FaceIdRequestManager(requireContext());
        
        //  NEW: Setup request manager callbacks
        setupRequestManagerCallbacks();
        
        Log.d(TAG, "📦 All components initialized successfully");
    }

    private void setupCameraAndOverlay() {
        cameraView = new CameraView(requireContext());
        binding.flStudentSettingVerifyFaceIdCameraContainer.addView(cameraView);

        faceOverlayView = new OvalFaceOverlayView(requireContext());
        binding.flStudentSettingVerifyFaceIdCameraContainer.addView(faceOverlayView);
    }

    private void setupClickListeners() {
        binding.ivStudentSettingVerifyFaceIdBack.setOnClickListener(v ->
                requireActivity().onBackPressed());

        binding.ivCameraBack.setOnClickListener(v -> {
            if (uiController.getCurrentScreenState() == FaceVerificationUIController.UIScreenState.CAMERA) {
                backToSetup();
            } else {
                requireActivity().onBackPressed();
            }
        });

        binding.btnGetStarted.setOnClickListener(v -> startFaceRegistration());
        binding.btnNotNow.setOnClickListener(v -> requireActivity().onBackPressed());
    }

    /**
     * 🔄 State change callback from StateManager
     */
    private void onStateChanged(FaceRegistrationState state, String message) {
        if (!isAdded() || binding == null) {
            Log.w(TAG, "⚠️ Fragment not valid for state change: " + state);
            return;
        }

        // Store the message for error display
        lastStateMessage = message;

        // Update UI
        uiController.updateForState(state, message);

        // Handle state-specific actions
        handleStateActions(state);

        // Cập nhật UI overlay theo màu sắc dựa vào trạng thái
        updateOverlayColor(state);
    }

    /**
     * Cập nhật màu sắc overlay dựa vào trạng thái
     */
    private void updateOverlayColor(FaceRegistrationState state) {
        if (faceOverlayView == null || !isAdded()) return;

        int color;
        switch (state) {
            case FACE_REAL:
            case FACE_STABLE:
                color = ContextCompat.getColor(requireContext(), R.color.success_green);
                break;

            case FACE_DETECTED:
            case FACE_STABILIZING:
            case FACE_WARNING:
                color = ContextCompat.getColor(requireContext(), R.color.warning_yellow);
                break;

            case FACE_SPOOFED:
            case FACE_OUT_OF_BOUNDS:
            case FAILED_SPOOF:
            case MULTIPLE_FACES:
                color = ContextCompat.getColor(requireContext(), R.color.error_red);
                break;

            case NO_FACE:
            case READY:
                color = ContextCompat.getColor(requireContext(), R.color.white);
                break;

            case LIVENESS_CHALLENGE:
                color = ContextCompat.getColor(requireContext(), R.color.primary);
                break;

            case ANALYZING:
            case PROCESSING:
                color = ContextCompat.getColor(requireContext(), R.color.processing_blue);
                break;

            default:
                color = ContextCompat.getColor(requireContext(), R.color.white);
                break;
        }

        faceOverlayView.setOvalColor(color);
    }

    /**
     * Handle actions for specific states
     */
    private void handleStateActions(FaceRegistrationState state) {
        // Kiểm tra xem fragment có còn hoạt động không
        if (!isAdded() || getActivity() == null) {
            Log.w(TAG, "⚠️ Fragment not valid for state action: " + state);
            return;
        }

        // Ghi log cho trạng thái
        // Log.d(TAG, "Xử lý trạng thái: " + state);

        // Cập nhật tvStatusMessage (Thêm vào để luôn cập nhật thông báo trạng thái)
        if (binding != null && binding.tvStatusMessage != null) {
            String message = state.getDefaultMessage();
            binding.tvStatusMessage.setText(message);
        }

        // Cập nhật UI loading nếu đang trong trạng thái xử lý
        if (state.isProcessingState()) {
            if (uiController != null) {
                uiController.showLoadingIndicator(true);
            }
        } else {
            if (uiController != null) {
                uiController.showLoadingIndicator(false);
            }
        }

        switch (state) {
            case SUCCESS:
                handleSuccessState();
                break;

            case FAILED_SPOOF:
            case FAILED_NETWORK:
            case FAILED_OTHER:
            case TIMEOUT_DETECTION:
            case TIMEOUT_REGISTRATION:
                handleErrorState(state);
                break;

            case FACE_STABLE:
                if (!isAnalyzing) {
                    // Hiển thị UI thông báo
                    Log.d(TAG, "Face stabilized, starting analysis...");
                    stateManager.transitionTo(FaceRegistrationState.ANALYZING,
                            "Analyzing face...");

                    // Cập nhật UI để người dùng biết đang phân tích
                    if (binding != null && binding.tvStatusMessage != null) {
                        binding.tvStatusMessage.setText("Analyzing face...");
                    }

                    // Bắt đầu phân tích
                    startAnalysis();
                }
                break;

            case FACE_DETECTED:
                // Cập nhật UI khi phát hiện khuôn mặt
                if (faceOverlayView != null) {
                    faceOverlayView.setOvalColor(ContextCompat.getColor(requireContext(), R.color.warning_yellow));
                }
                break;

            case NO_FACE:
                // Cập nhật UI khi không phát hiện khuôn mặt
                if (faceOverlayView != null) {
                    faceOverlayView.setOvalColor(ContextCompat.getColor(requireContext(), R.color.white));
                }
                break;

            case ANALYZING:
                // Đảm bảo UI phân tích được hiển thị
                if (analysisOverlay != null && analysisOverlay.getVisibility() != View.VISIBLE) {
                    analysisOverlay.setVisibility(View.VISIBLE);
                }
                break;

            case LIVENESS_CHALLENGE:
                // Hiển thị UI cho liveness challenge
                Log.d(TAG, "🔄 Activating Liveness Challenge");
                if (binding != null && binding.tvStatusMessage != null) {
                    binding.tvStatusMessage.setText("Look at the camera and blink");
                }
                if (faceOverlayView != null) {
                    faceOverlayView.setOvalColor(ContextCompat.getColor(requireContext(), R.color.primary));
                }

                // Initialize FaceIdEnhancer if not already done
                initializeFaceIdEnhancer();

                // Reset liveness state in spoof manager to start a fresh challenge
                if (spoofDetectionManager != null) {
                    spoofDetectionManager.resetLivenessState();
                }

                // Ensure liveness overlay is visible and above camera
                if (binding != null && binding.llLivenessProgress != null) {
                    binding.llLivenessProgress.setVisibility(View.VISIBLE);
                    binding.llLivenessProgress.bringToFront();
                }
                break;

            case FACE_OUT_OF_BOUNDS:
                // Cập nhật UI khi khuôn mặt nằm ngoài khung hình
                if (faceOverlayView != null) {
                    faceOverlayView.setOvalColor(ContextCompat.getColor(requireContext(), R.color.error_red));
                }
                break;

            case READY:
                // Đảm bảo UI được đặt lại ở trạng thái sẵn sàng
                if (faceOverlayView != null) {
                    faceOverlayView.setOvalColor(ContextCompat.getColor(requireContext(), R.color.white));
                }
                break;

            case INITIALIZING:
                // Hiển thị UI loading khi đang khởi tạo
                if (uiController != null) {
                    uiController.showLoadingOverlay(true);
                }
                break;

            case FACE_REAL:
                //  Liveness verified! Auto-transition to capture and verify
                Log.d(TAG, "🎉 Face is REAL - Starting automatic capture and verification");
                livenessVerified = true;
                
                // Update overlay color to success
                if (faceOverlayView != null) {
                    faceOverlayView.setOvalColor(ContextCompat.getColor(requireContext(), R.color.success_green));
                }
                
                // Auto-capture and verify after a short delay (let user see the success state)
                mainHandler.postDelayed(() -> {
                    if (isAdded() && stateManager.getCurrentState() == FaceRegistrationState.FACE_REAL) {
                        Log.d(TAG, "⭐ Triggering automatic face capture and verification");
                        captureAndVerifyFace();
                    }
                }, 800); // 800ms delay for user feedback
                break;
                
            case FACE_STABILIZING:
                // Cập nhật UI cho trạng thái ổn định khuôn mặt
                if (faceOverlayView != null) {
                    faceOverlayView.setOvalColor(ContextCompat.getColor(requireContext(), R.color.warning_yellow));
                }
                break;

            case FACE_SPOOFED:
                // Cập nhật UI khi phát hiện giả mạo
                if (faceOverlayView != null) {
                    faceOverlayView.setOvalColor(ContextCompat.getColor(requireContext(), R.color.error_red));
                }
                break;

            case PROCESSING:
                // Hiển thị UI đang xử lý
                if (uiController != null) {
                    uiController.showLoadingIndicator(true);
                }
                // Đảm bảo ẩn overlay phân tích
                if (analysisOverlay != null) {
                    analysisOverlay.setVisibility(View.GONE);
                }
                break;
        }
    }

    /**
     *  Start face registration process
     */
    private void startFaceRegistration() {
        Log.d(TAG, " Starting face registration process");

        // Dismiss any existing error dialog before starting camera
        if (currentErrorDialog != null && currentErrorDialog.isShowing()) {
            Log.d(TAG, "Dismissing existing error dialog before starting registration");
            currentErrorDialog.dismiss();
            currentErrorDialog = null;
        }

        // Ensure we have a clean state
        stopCamera();
        resetComponents();

        // Show camera screen
        uiController.showScreen(FaceVerificationUIController.UIScreenState.CAMERA);

        // Proceed with initialization
        initializeFaceIdService();
    }

    /**
     * Initialize FaceIdService and related components
     */
    private void initializeFaceIdService() {
        stateManager.transitionTo(FaceRegistrationState.INITIALIZING, "Loading AI models...");

        // Check if already initialized to prevent duplicate initializations
        if (FaceIdServiceManager.getInstance().isInitialized() && faceIdService != null) {

            // Đánh dấu đã khởi tạo thành công
            faceIdServiceInitialized = true;

            initializeSpoofDetection();

            // Đảm bảo chuyển sang trạng thái READY trước khi khởi động camera
            stateManager.transitionTo(FaceRegistrationState.READY, "Position your face in the oval");

            checkRequiredPermissions();
            return;
        }

        FaceIdServiceManager.getInstance().initialize(requireContext(), new FaceIdServiceManager.InitCallback() {
            @Override
            public void onInitialized(FaceIdService service) {
                if (!isAdded()) return;

                faceIdService = service;
                faceIdServiceInitialized = true;

                // 🔧 NEW: Set registration scenario for more lenient validation
                faceIdService.setScenario(FaceIdConfig.Scenario.REGISTRATION);

                // Initialize SpoofDetectionManager with FaceSpoofDetector
                initializeSpoofDetection();

                // Đảm bảo chuyển sang trạng thái READY trước khi khởi động camera
                stateManager.transitionTo(FaceRegistrationState.READY, "Position your face in the oval");

                checkRequiredPermissions();
                Log.d(TAG, " FaceIdService initialized with REGISTRATION scenario");
            }

            @Override
            public void onError(String message) {
                if (!isAdded()) return;

                Log.e(TAG, " FaceIdService error: " + message);
                stateManager.transitionTo(FaceRegistrationState.FAILED_OTHER,
                        "Failed to initialize: " + message);
            }
        });
    }

    /**
     * Initialize spoof detection with FaceSpoofDetector
     */
    private void initializeSpoofDetection() {
        if (faceIdService != null && faceIdService.getFaceSpoofDetector() != null) {
            spoofDetectionManager = new SpoofDetectionManager(faceIdService.getFaceSpoofDetector(), requireContext());
            // Set the oval boundary for enhanced security validation
            if (faceOverlayView != null) {
                spoofDetectionManager.setOvalBoundary(faceOverlayView.getOvalRect());
            }
            Log.d(TAG, " SpoofDetectionManager initialized with oval boundary");
        } else {
            Log.w(TAG, "⚠️ FaceSpoofDetector not available, using fallback detection");
        }
    }

    private void checkRequiredPermissions() {
        java.util.List<String> permissionsNeeded = new java.util.ArrayList<>();

        // Camera Permission
        if (ContextCompat.checkSelfPermission(requireContext(), Manifest.permission.CAMERA)
                != PackageManager.PERMISSION_GRANTED) {
            permissionsNeeded.add(Manifest.permission.CAMERA);
        }

        // Location Permissions (Required for Beacon scanning on Android < 12)
        if (ContextCompat.checkSelfPermission(requireContext(), Manifest.permission.ACCESS_FINE_LOCATION)
                != PackageManager.PERMISSION_GRANTED) {
            permissionsNeeded.add(Manifest.permission.ACCESS_FINE_LOCATION);
        }
        if (ContextCompat.checkSelfPermission(requireContext(), Manifest.permission.ACCESS_COARSE_LOCATION)
                != PackageManager.PERMISSION_GRANTED) {
            permissionsNeeded.add(Manifest.permission.ACCESS_COARSE_LOCATION);
        }

        // Bluetooth Permissions (Required for Beacon scanning on Android 12+)
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
            if (ContextCompat.checkSelfPermission(requireContext(), Manifest.permission.BLUETOOTH_SCAN)
                    != PackageManager.PERMISSION_GRANTED) {
                permissionsNeeded.add(Manifest.permission.BLUETOOTH_SCAN);
            }
            if (ContextCompat.checkSelfPermission(requireContext(), Manifest.permission.BLUETOOTH_CONNECT)
                    != PackageManager.PERMISSION_GRANTED) {
                permissionsNeeded.add(Manifest.permission.BLUETOOTH_CONNECT);
            }
        }

        if (!permissionsNeeded.isEmpty()) {
            // Request all missing permissions
            requestPermissions(permissionsNeeded.toArray(new String[0]),
                    CAMERA_PERMISSION_REQUEST_CODE);
        } else {
            // All permissions granted
            startCamera();
            startBeaconService();
        }
    }

    private void startBeaconService() {
        try {
            Log.d(TAG, "Starting BeaconScanService...");
            Intent intent = new Intent(requireContext(), com.example.flutter_application_1.attendance.data.service.BeaconScanService.class);
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                requireActivity().startForegroundService(intent);
            } else {
                requireActivity().startService(intent);
            }
        } catch (Exception e) {
            Log.e(TAG, "Failed to start BeaconScanService", e);
        }
    }

    /**
     * Stop the BeaconScanService if it's running.
     */
    private void stopBeaconService() {
        try {
            if (!isAdded() || requireActivity() == null) {
                Log.w(TAG, "Fragment not added - cannot stop BeaconScanService safely");
                return;
            }
            Intent intent = new Intent(requireContext(), com.example.flutter_application_1.attendance.data.service.BeaconScanService.class);
            boolean stopped = requireActivity().stopService(intent);
            Log.d(TAG, "BeaconScanService stop requested, result=" + stopped);
            // Also send an explicit STOP action to the service so it can self-terminate reliably
            try {
                Intent stopIntent = new Intent(requireContext(), com.example.flutter_application_1.attendance.data.service.BeaconScanService.class);
                stopIntent.setAction(com.example.flutter_application_1.attendance.data.service.BeaconScanService.ACTION_STOP);
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                    requireActivity().startForegroundService(stopIntent);
                } else {
                    requireActivity().startService(stopIntent);
                }
            } catch (Exception e) {
                Log.w(TAG, "Failed to send explicit stop action to BeaconScanService", e);
            }

            // Unregister receiver immediately to avoid receiving further broadcasts
            if (beaconReceiver != null) {
                try {
                    requireActivity().unregisterReceiver(beaconReceiver);
                    beaconReceiver = null;
                    Log.d(TAG, "Beacon receiver unregistered during stopBeaconService");
                } catch (Exception e) {
                    Log.w(TAG, "Could not unregister beaconReceiver during stopBeaconService", e);
                }
            }
        } catch (Exception e) {
            Log.e(TAG, "Failed to stop BeaconScanService", e);
        }
    }

    /**
     * 📷 Start camera and begin processing
     */
    private void startCamera() {
        // First check if fragment is still attached
        if (!isAdded()) {
            Log.w(TAG, "Fragment not attached, cannot start camera");
            return;
        }

        // Make sure camera is stopped first to prevent duplicate instances
        stopCamera();

        // Show loading state for camera initialization
        uiController.showLoadingOverlay(true);

        // Add a small delay to ensure camera is properly released
        mainHandler.postDelayed(() -> {
            // Check again if fragment is still attached before proceeding
            if (!isAdded() || cameraView == null) {
                Log.w(TAG, "Fragment not attached or camera view is null after delay");
                return;
            }

            // Ensure we are still on CAMERA screen before starting camera
            if (uiController == null || uiController.getCurrentScreenState() != FaceVerificationUIController.UIScreenState.CAMERA) {
                Log.w(TAG, "Not in CAMERA screen anymore, aborting camera start");
                return;
            }

            try {
                Log.d(TAG, "Starting camera after delay...");
                cameraView.startCamera(getViewLifecycleOwner(), this::processFrame);
                isCameraStarted = true;

                // Check again before updating UI
                if (!isAdded()) {
                    Log.w(TAG, "Fragment detached after starting camera");
                    return;
                }

                // Hide loading and show camera view
                uiController.showLoadingOverlay(false);

                Log.d(TAG, " Camera started successfully");
                stateManager.transitionTo(FaceRegistrationState.READY,
                        "Position your face in the oval");
            } catch (Exception e) {
                // Check if fragment is still attached before updating state
                if (!isAdded()) {
                    Log.w(TAG, "Fragment detached during camera error handling");
                    return;
                }

                Log.e(TAG, " Error starting camera: " + e.getMessage(), e);
                stateManager.transitionTo(FaceRegistrationState.FAILED_CAMERA,
                        "Failed to start camera: " + e.getMessage());
            }
        }, 500); // Small delay to ensure previous camera is fully released
    }

    /**
     * 🔍 Process camera frame with enhanced security logic
     */
    private void processFrame(Bitmap bitmap) {
        if (!isVerificationWindowActive()) {
            Log.w(TAG, "Verification window expired; ignoring frames");
            return;
        }
        currentFrameBitmap = bitmap;

        // Kiểm tra xem FaceIdService đã khởi tạo chưa
        if (faceIdService == null || !faceIdServiceInitialized) {
            Log.w(TAG, "FaceIdService not initialized yet, skipping frame processing");
            return;
        }

        // Special handling for LIVENESS_CHALLENGE state
        if (stateManager.getCurrentState() == FaceRegistrationState.LIVENESS_CHALLENGE) {
            // Process frame using FaceIdService first to get face rect
            faceIdService.processContinuousFrame(bitmap, faceOverlayView.getOvalRect(),
                    new FaceIdService.ContinuousProcessingCallback() {
                        @Override
                        public void onFaceDetected(Rect boundingBox, boolean isSpoof, float spoofScore) {
                            currentFaceRect = boundingBox;

                            // 🚨 IMMEDIATE SPOOF DETECTION - Always check spoof first, even during liveness challenge
                            if (isSpoof) {
                                Log.w(TAG, "🚫 SPOOF DETECTED during LIVENESS_CHALLENGE! isSpoof=" + isSpoof + ", score=" + spoofScore + " - Stopping pipeline");
                                
                                // Set face spoof state immediately - this will override liveness challenge
                                stateManager.transitionTo(FaceRegistrationState.FACE_SPOOFED, 
                                        "Spoof detected! Please use a real face.");
                                
                                // Update oval to red color immediately  
                                if (faceOverlayView != null) {
                                    faceOverlayView.updateState(FaceProcessingState.FACE_SPOOFED, 
                                            "Spoof detected! Please use a real face.");
                                }
                                
                                // Stop all processing - no liveness challenge for spoofed face
                                return;
                            }

                            // Update face position in overlay
                            if (faceOverlayView != null) {
                                android.graphics.Rect overlayRect = boundingBox;
                                try {
                                    android.graphics.RectF viewRectF = com.example.flutter_application_1.faceid.util.CoordinateMapper  
                                                                                                       .getInstance()
                                                                                                       .mapBitmapRectToView(new android.graphics.RectF(boundingBox));
                                    if (viewRectF != null) {
                                        overlayRect = new android.graphics.Rect(
                                                Math.round(viewRectF.left),
                                                Math.round(viewRectF.top),
                                                Math.round(viewRectF.right),
                                                Math.round(viewRectF.bottom)
                                        );
                                    }
                                } catch (Exception ignored) {}
                                boolean isGoodPosition = faceOverlayView.updateFacePosition(overlayRect);
                                if (!isGoodPosition) {
                                    // While in liveness challenge, do NOT change global state.
                                    // Only provide UI guidance and keep challenge active.
                                    if (binding != null && binding.tvInstructionMessage != null) {
                                        binding.tvInstructionMessage.setText("Position your face properly in the oval");
                                    }
                                    if (faceOverlayView != null) {
                                        faceOverlayView.setOvalColor(ContextCompat.getColor(requireContext(), R.color.error_red));
                                    }
                                    return; // Skip processing until position good
                                } else {
                                    // Restore liveness color to indicate ready to proceed
                                    if (faceOverlayView != null) {
                                        faceOverlayView.setOvalColor(ContextCompat.getColor(requireContext(), R.color.primary));
                                    }
                                }
                            }

                            // Process the frame for liveness challenges
                            processFrameForLivenessChallenge(bitmap, boundingBox);
                        }

                        @Override
                        public void onNoFaceDetected() {
                            currentFaceRect = null;
                            stateManager.transitionTo(FaceRegistrationState.NO_FACE, "Look at the camera");
                        }

                        @Override
                        public void onMultipleFacesDetected() {
                            // Handle multiple faces
                            stateManager.transitionTo(FaceRegistrationState.MULTIPLE_FACES, "Only one person should be visible");
                        }

                        @Override
                        public void onError(String errorMessage) {
                            Log.e(TAG, "Error processing frame: " + errorMessage);
                        }
                    });

            return; // Skip normal processing
        }

        if (isAnalyzing) {
            faceIdService.processContinuousFrame(bitmap, faceOverlayView.getOvalRect(), new FaceIdService.ContinuousProcessingCallback() {
                @Override
                public void onFaceDetected(Rect boundingBox, boolean isSpoof, float spoofScore) {
                    // During analysis, only accept frames that are sufficiently stable to avoid high variance
                    if (lastAnalysisRect != null) {
                        float cxPrev = lastAnalysisRect.exactCenterX();
                        float cyPrev = lastAnalysisRect.exactCenterY();
                        float cx = boundingBox.exactCenterX();
                        float cy = boundingBox.exactCenterY();
                        float faceSize = Math.max(boundingBox.width(), boundingBox.height());
                        float moveRatio = (float) (Math.hypot(cx - cxPrev, cy - cyPrev) / Math.max(1f, faceSize));
                        float sizeDelta = Math.abs((boundingBox.width() * boundingBox.height()) - (lastAnalysisRect.width() * lastAnalysisRect.height()));
                        float sizeRatio = sizeDelta / Math.max(1f, (boundingBox.width() * boundingBox.height()));
                        if (moveRatio > MAX_CENTER_MOVE_RATIO || sizeRatio > MAX_SIZE_DELTA_RATIO) {
                            // Skip unstable frame
                            lastAnalysisRect = new Rect(boundingBox);
                            return;
                        }
                    }
                    lastAnalysisRect = new Rect(boundingBox);

                    // Normalize to realness probability for analysis
                    if (!isSpoof || livenessVerified) {
                        float realness = isSpoof ? Math.max(0f, 1f - spoofScore) : Math.min(1f, spoofScore);
                        frameScores.add(realness);
                    }
                }

                @Override
                public void onNoFaceDetected() {}

                @Override
                public void onMultipleFacesDetected() {}

                @Override
                public void onError(String errorMessage) {}
            });
            return;
        }

        // Skip if not ready
        if (faceIdService == null) {
            return;
        }

        // Skip if already in final state
        if (stateManager.getCurrentState().isFinalState()) {
            return;
        }

        // Process frame with oval boundary validation
        faceIdService.processContinuousFrame(bitmap, faceOverlayView.getOvalRect(),
                new FaceIdService.ContinuousProcessingCallback() {
                    @Override
                    public void onFaceDetected(Rect boundingBox, boolean isSpoof, float spoofScore) {
                        currentFaceRect = boundingBox;

                        // 🚨 IMMEDIATE SPOOF DETECTION - Stop pipeline if spoof detected
                        if (isSpoof) {
                            Log.w(TAG, "🚫 SPOOF DETECTED! isSpoof=" + isSpoof + ", score=" + spoofScore + " - Stopping pipeline");
                            
                            // Set face spoof state immediately
                            stateManager.transitionTo(FaceRegistrationState.FACE_SPOOFED, 
                                    "Spoof detected! Please use a real face.");
                            
                            // Update oval to red color immediately  
                            if (faceOverlayView != null) {
                                faceOverlayView.updateState(FaceProcessingState.FACE_SPOOFED, 
                                        "Spoof detected! Please use a real face.");
                            }
                            
                            // Update UI message immediately
                            if (binding != null && binding.tvStatusMessage != null) {
                                binding.tvStatusMessage.setText("Spoof detected! Please use a real face.");
                            }
                            
                            // Reset face tracker and stop processing
                            resetFaceTracker();
                            return; // 🛑 STOP PIPELINE HERE - No further processing
                        }

                        // Update face position in overlay for user guidance
                        if (faceOverlayView != null) {
                            android.graphics.Rect overlayRect = boundingBox;
                            try {
                android.graphics.RectF viewRectF = com.example.flutter_application_1.faceid.util.CoordinateMapper
                    .getInstance()
                    .mapBitmapRectToView(new android.graphics.RectF(boundingBox));
                                if (viewRectF != null) {
                                    overlayRect = new android.graphics.Rect(
                                            Math.round(viewRectF.left),
                                            Math.round(viewRectF.top),
                                            Math.round(viewRectF.right),
                                            Math.round(viewRectF.bottom)
                                    );
                                }
                            } catch (Exception ignored) {}
                            boolean isGoodPosition = faceOverlayView.updateFacePosition(overlayRect);

                            // If position is bad, don't proceed with further processing
                            if (!isGoodPosition && stateManager.getCurrentState() != FaceRegistrationState.FACE_OUT_OF_BOUNDS) {
                                stateManager.transitionTo(FaceRegistrationState.FACE_OUT_OF_BOUNDS,
                                        "Position your face properly in the oval");
                                // Cập nhật UI ngay lập tức
                                if (faceOverlayView != null) {
                                    faceOverlayView.setOvalColor(ContextCompat.getColor(requireContext(), R.color.error_red));
                                }
                                return;
                            } else if (isGoodPosition && stateManager.getCurrentState() == FaceRegistrationState.FACE_OUT_OF_BOUNDS) {
                                // Khi vị trí đã tốt nhưng trạng thái vẫn là out of bounds, cập nhật trạng thái
                                stateManager.transitionTo(FaceRegistrationState.FACE_DETECTED, "Face detected");
                                // Cập nhật UI ngay lập tức
                                if (faceOverlayView != null) {
                                    faceOverlayView.setOvalColor(ContextCompat.getColor(requireContext(), R.color.warning_yellow));
                                }
                            }
                        }

                        // 🔧 Use enhanced spoof detection if available
                        if (spoofDetectionManager != null) {
                            spoofDetectionManager.analyzeFrame(bitmap, boundingBox, result -> {
                                handleEnhancedSpoofResult(result, boundingBox);
                            });
                        } else {
                            // Fallback to basic logic
                            handleBasicSpoofResult(isSpoof, spoofScore, boundingBox);
                        }
                    }

                    @Override
                    public void onNoFaceDetected() {
                        currentFaceRect = null;
                        stateManager.transitionTo(FaceRegistrationState.NO_FACE, "Look at the camera");

                        // Cập nhật UI ngay lập tức
                        if (faceOverlayView != null) {
                            faceOverlayView.setOvalColor(ContextCompat.getColor(requireContext(), R.color.white));
                        }

                        // Cập nhật thông báo trạng thái
                        if (binding != null && binding.tvStatusMessage != null) {
                            binding.tvStatusMessage.setText("Look at the camera");
                        }

                        resetFaceTracker();
                    }

                    @Override
                    public void onMultipleFacesDetected() {
                        currentFaceRect = null;
                        stateManager.transitionTo(FaceRegistrationState.MULTIPLE_FACES,
                                "Only one face should be visible");

                        // Cập nhật UI ngay lập tức
                        if (faceOverlayView != null) {
                            faceOverlayView.setOvalColor(ContextCompat.getColor(requireContext(), R.color.error_red));
                        }

                        // Cập nhật thông báo trạng thái
                        if (binding != null && binding.tvStatusMessage != null) {
                            binding.tvStatusMessage.setText("Only one face should be visible");
                        }

                        resetFaceTracker();
                    }

                    @Override
                    public void onError(String errorMessage) {
                        Log.e(TAG, " Frame processing error: " + errorMessage);
                        stateManager.transitionTo(FaceRegistrationState.FAILED_OTHER,
                                "Detection error: " + errorMessage);
                    }
                });
    }

    /**
     * Enhanced spoof result handling with better real face detection
     */
    private void handleEnhancedSpoofResult(SpoofDetectionManager.SpoofDetectionResult result, Rect boundingBox) {
        // If we are in a liveness challenge, ignore spoof-driven transitions from any in-flight callbacks
        if (stateManager.getCurrentState() == FaceRegistrationState.LIVENESS_CHALLENGE) {
            Log.d(TAG, "Ignoring spoof result during active liveness challenge");
            return;
        }
        if (!isAdded() || stateManager.getCurrentState().isFinalState()) {
            return;
        }

        if (result.triggerLivenessChallenge) {
            stateManager.transitionTo(FaceRegistrationState.LIVENESS_CHALLENGE, result.explanation);
            return;
        }

        if (result.isSpoof) {
            stateManager.transitionTo(FaceRegistrationState.FACE_SPOOFED, result.explanation);
            resetFaceTracker();
            return;
        }

        if (result.shouldProceed) {
            stateManager.transitionTo(FaceRegistrationState.FACE_STABLE, result.explanation);
        } else {
            // Use a FACE_SUSPICIOUS state to provide feedback without failing
            if (result.explanation.contains("Suspicious")) {
                stateManager.transitionTo(FaceRegistrationState.FACE_SUSPICIOUS, result.explanation);
            } else {
                stateManager.transitionTo(FaceRegistrationState.FACE_STABILIZING, result.explanation);
            }
            trackFaceStability(boundingBox);
        }
    }

    /**
     * Fallback basic spoof handling (improved for better real face detection)
     */
    private void handleBasicSpoofResult(boolean isSpoof, float spoofScore, Rect boundingBox) {
        Log.d(TAG, "🔧 Using basic spoof detection: isSpoof=" + isSpoof + ", score=" + spoofScore);

        // Interpret 'spoofScore' as confidence of predicted class; convert to realness in [0..1]
        float realness = isSpoof ? Math.max(0f, 1f - spoofScore) : Math.min(1f, spoofScore);

        // After liveness is verified, never flip to spoof. Provide guidance only.
        if (livenessVerified) {
            if (realness >= 0.50f) {
                stateManager.transitionTo(FaceRegistrationState.FACE_REAL, "Real face detected");
                trackFaceStability(boundingBox);
            } else {
                stateManager.transitionTo(FaceRegistrationState.FACE_WARNING,
                        "Improve lighting and hold still");
                resetFaceTracker();
            }
            return;
        }

        // Pre-liveness thresholds (symmetric band)
        if (realness >= 0.60f) {
            stateManager.transitionTo(FaceRegistrationState.FACE_REAL, "Real face detected");
            trackFaceStability(boundingBox);
        } else if (realness <= 0.30f) {
            stateManager.transitionTo(FaceRegistrationState.FACE_SPOOFED,
                    "Spoof detected! Please use a real face.");
            resetFaceTracker();
        } else {
            stateManager.transitionTo(FaceRegistrationState.FACE_WARNING,
                    "Uncertain detection. Please improve lighting and position.");
            resetFaceTracker();
        }
    }

    /**
     * Track face stability with enhanced metrics
     */
    private void trackFaceStability(Rect boundingBox) {
        if (faceTracker != null) {
            faceTracker.trackFace(boundingBox, new FaceTracker.FaceStabilityCallback() {
                @Override
                public void onFaceStabilizing(float progress) {
                    if (!isAdded()) return;

                    int percentage = Math.round(progress * 100);
                    stateManager.transitionTo(FaceRegistrationState.FACE_STABILIZING,
                            "Hold still... " + percentage + "%");

                    // Update progress animation in overlay
                    if (faceOverlayView != null && percentage > 0) {
                        // Cập nhật màu sắc oval để phản hồi trực quan
                        faceOverlayView.setOvalColor(ContextCompat.getColor(requireContext(), R.color.warning_yellow));
                        faceOverlayView.startProgressAnimation(3000); // 3 second animation
                    }
//
//                    // Cập nhật thông báo trạng thái
//                    if (binding != null && binding.tvStatusMessage != null) {
//                        binding.tvStatusMessage.setText("Hold still... " + percentage + "%");
//                    }
                }

                @Override
                public void onFaceStable(Rect stableFaceRect) {
                    if (!isAdded()) return;

                    currentFaceRect = stableFaceRect;
                    stateManager.transitionTo(FaceRegistrationState.FACE_STABLE, "Perfect!");

                    // Cập nhật màu oval khi khuôn mặt ổn định
                    if (faceOverlayView != null) {
                        faceOverlayView.setOvalColor(ContextCompat.getColor(requireContext(), R.color.success_green));
                    }

                    // Cập nhật thông báo trạng thái
                    if (binding != null && binding.tvStatusMessage != null) {
                        binding.tvStatusMessage.setText("Perfect! Processing...");
                    }
                }

                @Override
                public void onFaceUnstable() {
                    if (!isAdded()) return;

                    stateManager.transitionTo(FaceRegistrationState.FACE_REAL,
                            "Keep your face steady");

                    // Stop progress animation
                    if (faceOverlayView != null) {
                        // Đặt lại màu oval
                        faceOverlayView.setOvalColor(ContextCompat.getColor(requireContext(), R.color.warning_yellow));
                        faceOverlayView.stopProgressAnimation();
                    }

                    // Cập nhật thông báo trạng thái
                    if (binding != null && binding.tvStatusMessage != null) {
                        binding.tvStatusMessage.setText("Keep your face steady");
                    }
                }
            });
        }
    }

    /**
     * 📸 Capture and verify face with enhanced security validation
     */
    private void captureAndVerifyFace() {
        // Check if verification has already completed successfully
        if (verificationCompleted) {
            Log.w(TAG, "⚠️ Verification already completed, ignoring duplicate request");
            return;
        }
        
        // Check if fragment is still attached
        if (!isAdded()) {
            Log.w(TAG, "Fragment not attached, cannot capture and register face");
            return;
        }

        if (currentFrameBitmap == null || currentFaceRect == null) {
            Log.w(TAG, "⚠️ Cannot capture - no frame or face rect");
            stateManager.transitionTo(FaceRegistrationState.FAILED_OTHER,
                    "Capture failed - no data available");
            return;
        }

        stateManager.transitionTo(FaceRegistrationState.PROCESSING, "Processing face data...");

        // Check again if fragment is still attached
        if (!isAdded()) {
            Log.w(TAG, "Fragment detached during face registration process");
            return;
        }

        String userId;
        try {
            AuthManager authManager = AuthManager.getInstance(requireContext());
            // Use employeeId instead of userId as requested
            String tempUserId = authManager.getEmployeeId();
            Log.d(TAG, "================= getEmployeeId: " + authManager.getEmployeeId());
            Log.d(TAG, "================= tempUserId: " + authManager.getCurrentUserId());

            if (tempUserId == null || tempUserId.isEmpty()) {
                // Try to get from intent if not in AuthManager
                if (getActivity() != null && getActivity().getIntent() != null) {
                    String intentEmployeeId = getActivity().getIntent().getStringExtra("employeeId");
                    if (intentEmployeeId != null && !intentEmployeeId.isEmpty()) {
                        tempUserId = intentEmployeeId;
                        // Also save to AuthManager for future use
                        authManager.setEmployeeId(tempUserId);
                    }
                }
            }

            if (tempUserId == null || tempUserId.isEmpty()) {
                Log.e(TAG, " No employee ID available");
                stateManager.transitionTo(FaceRegistrationState.FAILED_OTHER, "User not logged in (missing employee ID)");
                return;
            }

            userId = tempUserId;

        } catch (IllegalStateException e) {
            Log.e(TAG, " Fragment not attached when getting user ID", e);
            return;
        }

        // Stop camera before registration to prevent infinite loop on error
        stopCamera();

        // Capture local copies for use in callback
        final Bitmap capturedBitmap = currentFrameBitmap;
        final Rect capturedFaceRect = currentFaceRect;
        final String finalUserId = userId;

        // 🔧 NEW: Show progress updates
        stateManager.transitionTo(FaceRegistrationState.PROCESSING, "Generating face embedding...");

        // Kiểm tra và ẩn overlay phân tích nếu đang hiển thị
        if (analysisOverlay != null && analysisOverlay.getVisibility() == View.VISIBLE) {
            analysisOverlay.setVisibility(View.GONE);
        }

        // 🎯 ALWAYS use full 3-step Attendance Check-In Flow
        // User requirement: "luôn dùng full 3 bước, và trong 3 bước đấy cũng không dùng requestId"
        Log.d(TAG, " Always using full attendance check-in flow (3 steps: Beacon -> GPS -> Face)");
        
        // Note: The 3-step flow generates its own attendance_check_id in Step 2,
        // so we do not need/use the requestId from arguments.
        performAttendanceCheckIn(capturedBitmap);
    }
    
    /**
     * 📍 Lấy tọa độ GPS hiện tại của thiết bị
     */
    private void getCurrentLocation() {
        try {
            if (locationManager == null) {
                locationManager = (LocationManager) requireContext().getSystemService(android.content.Context.LOCATION_SERVICE);
            }
            
            // Kiểm tra permission
            if (ContextCompat.checkSelfPermission(requireContext(), Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED &&
                ContextCompat.checkSelfPermission(requireContext(), Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                Log.w(TAG, "⚠️ Location permission not granted");
                return;
            }
            
            // Lấy last known location từ GPS provider
            Location gpsLocation = locationManager.getLastKnownLocation(LocationManager.GPS_PROVIDER);
            Location networkLocation = locationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER);
            
            // Chọn location tốt nhất (GPS ưu tiên hơn Network)
            if (gpsLocation != null && networkLocation != null) {
                currentLocation = gpsLocation.getTime() > networkLocation.getTime() ? gpsLocation : networkLocation;
            } else if (gpsLocation != null) {
                currentLocation = gpsLocation;
            } else if (networkLocation != null) {
                currentLocation = networkLocation;
            }
            
        
        } catch (Exception e) {
            Log.e(TAG, "❌ Error getting current location", e);
        }
    }
    
    
    /**
     *  Perform attendance check-in using AttendanceService (3-step flow)
     */
    private void performAttendanceCheckIn(Bitmap faceImage) {
        if (!isAdded()) return;

        Log.d(TAG, "Starting attendance check-in flow (stepwise from fragment)");

        // Get attendance data from instance variables (not arguments to avoid lifecycle issues)
        // Beacon data is populated by the BroadcastReceiver
        String beaconUuidLocal = this.beaconUuid;
        int beaconMajorLocal = this.beaconMajor;
        int beaconMinorLocal = this.beaconMinor;
        int rssiLocal = this.beaconRssi;

        if ((beaconUuidLocal == null || beaconUuidLocal.isEmpty()) && beaconMajorLocal == -1 && beaconMinorLocal == -1) {
            Log.e(TAG, "Beacon data not available or invalid: uuid=" + beaconUuidLocal + ", major=" + beaconMajorLocal + ", minor=" + beaconMinorLocal);
            stateManager.transitionTo(FaceRegistrationState.FAILED_OTHER, "Beacon data not available. Please wait for beacon scan.");
            return;
        }

        // 📍 Lấy tọa độ GPS hiện tại thay vì dùng giá trị fix cứng
        getCurrentLocation();
        
        final double latitude = (currentLocation != null) ? currentLocation.getLatitude() : 10.762622;
        final double longitude = (currentLocation != null) ? currentLocation.getLongitude() : 106.660172;
        final double accuracy = (currentLocation != null) ? currentLocation.getAccuracy() : 15.0;
        
        if (currentLocation != null) {
            Log.d(TAG, "📍 Using current GPS location: lat=" + latitude + ", lng=" + longitude + ", accuracy=" + accuracy);
        } else {
            Log.w(TAG, "⚠️ GPS location not available, using default coordinates");
        }

        final String deviceId = android.provider.Settings.Secure.getString(requireContext().getContentResolver(), android.provider.Settings.Secure.ANDROID_ID);

        // Initialize AttendanceService
        com.example.flutter_application_1.attendance.data.service.AttendanceService attendanceService = new com.example.flutter_application_1.attendance.data.service.AttendanceService(requireContext());

        // Step 1: Validate Beacon
        stateManager.transitionTo(FaceRegistrationState.PROCESSING, "Validating beacon...");
        attendanceService.validateBeacon(beaconUuidLocal, beaconMajorLocal, beaconMinorLocal, rssiLocal, new com.example.flutter_application_1.attendance.data.service.AttendanceService.AttendanceCallback<com.example.flutter_application_1.attendance.data.model.response.ValidateBeaconResponse>() {
            @Override
            public void onSuccess(com.example.flutter_application_1.attendance.data.model.response.ValidateBeaconResponse beaconResult) {
                if (!isAdded()) return;
                Log.d(TAG, "Step 1 ✅ - Beacon validated, session_token: " + beaconResult.getSession_token());

                // 🔍 Generate face embedding from captured image
                stateManager.transitionTo(FaceRegistrationState.PROCESSING, "Generating face embedding...");
                
                String faceEmbeddingBase64 = faceIdService.extractFaceEmbeddingBase64(faceImage);
                if (faceEmbeddingBase64 == null) {
                    Log.e(TAG, "❌ Failed to generate face embedding");
                    stateManager.transitionTo(FaceRegistrationState.FAILED_OTHER, "Failed to generate face embedding");
                    return;
                }
                
                Log.d(TAG, "✅ Face embedding generated: " + faceEmbeddingBase64.length() + " chars");

                // Step 2: Request Face Verification WITH face embedding
                // Backend will verify face via RabbitMQ event → Face Service
                stateManager.transitionTo(FaceRegistrationState.PROCESSING, "Submitting face verification...");
                attendanceService.requestFaceVerification("check_in", latitude, longitude, accuracy, deviceId, faceEmbeddingBase64,
                    new com.example.flutter_application_1.attendance.data.service.AttendanceService.AttendanceCallback<com.example.flutter_application_1.attendance.data.model.response.RequestFaceVerificationResponse>() {
                        @Override
                        public void onSuccess(com.example.flutter_application_1.attendance.data.model.response.RequestFaceVerificationResponse verifyResult) {
                            if (!isAdded()) return;
                            Log.d(TAG, "Step 2 ✅ - AttendanceCheckId: " + verifyResult.getAttendance_check_id());
                            Log.d(TAG, "Step 2 ✅ - ShiftId: " + verifyResult.getShift_id());
                            Log.d(TAG, "✅ Face verification submitted! Waiting for backend processing via RabbitMQ...");

                            // ✅ DONE! Backend will handle verification via event-driven flow:
                            // Attendance Service → RabbitMQ → Face Service → Verify → Publish event → Update check_in_time
                            stateManager.transitionTo(FaceRegistrationState.SUCCESS, 
                                "Face verification submitted successfully! Check-in time will be updated shortly.");
                        }

                        @Override
                        public void onFailure(String error) {
                            if (!isAdded()) return;
                            Log.e(TAG, "❌ Step 2 failed: " + error);
                            lastDetailedErrorMessage = "Request face verification failed:\n" + error;
                            hasDetailedError = true;
                            stateManager.transitionTo(FaceRegistrationState.FAILED_OTHER, "Step 2 failed: " + error);
                        }
                    });
            }
            
            @Override
            public void onFailure(String error) {
                if (!isAdded()) return;
                Log.e(TAG, "❌ Step 1 failed: " + error);
                stateManager.transitionTo(FaceRegistrationState.FAILED_OTHER, "Step 1 failed: " + error);
            }
        });
    }

    /**
     * 🎉 Handle success - Navigate to Success Activity
     */
    private void handleSuccessState() {
        // Check if fragment is still attached before proceeding
        if (!isAdded()) {
            Log.w(TAG, "Fragment not attached, cannot handle success state");
            return;
        }
        
        // Set flag to prevent duplicate processing
        verificationCompleted = true;
        Log.d(TAG, "✅ Verification completed flag set");

        try {
            stopCamera();

            // Save bitmap for background sync
            String bitmapPath = saveBitmapToTempFile(currentFrameBitmap);
            String userId = AuthManager.getInstance(requireContext()).getEmployeeId();
            String successMessage = "Face ID verified successfully!";

            // Double-check fragment is still attached before starting activity
            if (!isAdded()) {
                Log.w(TAG, "Fragment detached during success handling");
                return;
            }

            //  Launch Success Activity
            //  NEW: Sử dụng Intent mới với userName
            Intent successIntent = FaceIdSuccessActivity.createVerifySuccessIntent(
                requireContext(),
                userId,
                AuthManager.getInstance(requireContext()).getCurrentUserName()
            );
            // Ensure beacon scanning is stopped once verification is successful
            stopBeaconService();
            startActivity(successIntent);
            
            // Finish the parent activity to prevent it from staying in the back stack
            // This ensures no duplicate requests when user clicks Continue
            requireActivity().finish();

            Log.d(TAG, "🎉 Navigating to Success Activity and finishing parent activity");

        } catch (Exception e) {
            Log.e(TAG, " Error handling success", e);

            // Check if fragment is still attached before showing toast
            if (isAdded()) {
                Toast.makeText(requireContext(), "Registration completed!", Toast.LENGTH_LONG).show();

                // Check again before calling onBackPressed
                if (isAdded()) {
                    requireActivity().onBackPressed();
                }
            }
        }
    }

    /**
     * Handle network errors with retry option
     */
    private void handleNetworkError(String errorMessage) {
        if (!isAdded()) return;

        // Create alert dialog with retry option
        AlertDialog dialog = new AlertDialog.Builder(requireContext())
                .setTitle("Network Connection Issue")
                .setMessage("Cannot connect to the server. Please check your internet connection and try again.")
                .setPositiveButton("Try Again", (d, which) -> {
                    // Check if fragment is still attached before proceeding
                    if (!isAdded()) {
                        Log.w(TAG, "Fragment not attached, cannot retry registration");
                        return;
                    }

                    // Dismiss dialog and reset
                    currentErrorDialog = null;
                    resetComponents();
                    startFaceRegistration();
                })
                .setNegativeButton("Cancel", (d, which) -> {
                    // Check if fragment is still attached before proceeding
                    if (!isAdded()) {
                        Log.w(TAG, "Fragment not attached, cannot handle cancel");
                        return;
                    }

                    // Dismiss dialog and go back
                    currentErrorDialog = null;
                    requireActivity().onBackPressed();
                })
                .setCancelable(false)
                .create();
                
        // Store reference and show dialog
        currentErrorDialog = dialog;
        dialog.show();
    }

    /**
     *  Handle error states with retry
     */
    private void handleErrorState(FaceRegistrationState state) {
        // Ensure camera is stopped to prevent infinite loop
        stopCamera();

        // Check if fragment is still attached
        if (!isAdded()) {
            Log.w(TAG, "Fragment not attached, cannot show error dialog");
            return;
        }

        // Handle all errors in a unified way - no longer using separate handler for network errors

        // Prepare error message based on state
        String title = "Registration Failed";
        String message;

        // Set appropriate message based on error type
        if (state == FaceRegistrationState.FAILED_NETWORK) {
            title = "Network Connection Issue";
            message = "Cannot connect to the server. Please check your internet connection and try again.";
        } else if (state == FaceRegistrationState.FAILED_SPOOF) {
            message = "Spoof detection triggered. Please ensure you're using a real face and not a photo or video.\n\nWould you like to try again?";
        } else {
            // Use the actual message from state transition instead of default message
            // This ensures specific error messages like "Beacon data not available" are displayed
            message = (lastStateMessage != null && !lastStateMessage.isEmpty()) 
                    ? lastStateMessage + "\n\nWould you like to try again?"
                    : state.getDefaultMessage() + "\n\nWould you like to try again?";
        }

        // Add detailed error information if available
        final String detailedMessage = hasDetailedError ?
                message + "\n\n--- DETAILED ERROR INFORMATION ---\n" + lastDetailedErrorMessage : message;

        // Log the detailed error for debugging
        // Log.e(TAG, "Detailed error information: " + detailedMessage);

        // For other errors, show regular retry dialog with detailed information
        AlertDialog.Builder builder = new AlertDialog.Builder(requireContext())
                .setTitle(title)
                .setMessage(detailedMessage)
                .setPositiveButton("Retry", (dialog, which) -> {
                    // Check if fragment is still attached before proceeding
                    if (!isAdded()) {
                        Log.w(TAG, "Fragment not attached, cannot retry");
                        return;
                    }

                    // Reset error tracking
                    hasDetailedError = false;
                    lastDetailedErrorMessage = "";
                    lastStateMessage = "";
                    
                    // Dismiss dialog
                    currentErrorDialog = null;

                    // Make sure everything is fully reset before retry
                    resetComponents();
                    // Small delay to ensure complete reset
                    new Handler(Looper.getMainLooper()).postDelayed(() -> {
                        // Check again if fragment is attached before starting camera
                        if (!isAdded()) {
                            Log.w(TAG, "Fragment not attached, cannot start registration");
                            return;
                        }
                        startFaceRegistration();
                    }, 500);
                })
                // No neutral button - removed offline mode and copy error options
                .setNegativeButton("Cancel", (dialog, which) -> {
                    // Check if fragment is still attached before proceeding
                    if (!isAdded()) {
                        Log.w(TAG, "Fragment not attached, cannot handle cancel");
                        return;
                    }

                    // Reset error tracking
                    hasDetailedError = false;
                    lastDetailedErrorMessage = "";
                    lastStateMessage = "";
                    
                    // Dismiss dialog
                    currentErrorDialog = null;
                    
                    requireActivity().onBackPressed();
                })
                .setCancelable(false);

        // Create and show the dialog
        AlertDialog dialog = builder.create();
        
        // Store reference before showing
        currentErrorDialog = dialog;
        dialog.show();

        // Make the message scrollable for long detailed errors
        TextView messageView = dialog.findViewById(android.R.id.message);
        if (messageView != null) {
            messageView.setMovementMethod(new ScrollingMovementMethod());
        }
    }

    /**
     * Save bitmap to temp file for background sync
     */
    private String saveBitmapToTempFile(Bitmap bitmap) throws IOException {
        // Check if fragment is still attached
        if (!isAdded()) {
            throw new IllegalStateException("Fragment not attached, cannot save bitmap");
        }

        File tempDir = new File(requireContext().getCacheDir(), "face_registration");
        if (!tempDir.exists()) {
            tempDir.mkdirs();
        }

        File tempFile = new File(tempDir, "face_" + System.currentTimeMillis() + ".jpg");

        try (FileOutputStream fos = new FileOutputStream(tempFile)) {
            bitmap.compress(Bitmap.CompressFormat.JPEG, 90, fos);
        }

        return tempFile.getAbsolutePath();
    }

    /**
     * Back to setup screen
     */
    private void backToSetup() {
        // Check if fragment is still attached
        if (!isAdded()) {
            Log.w(TAG, "Fragment not attached, cannot go back to setup");
            return;
        }

        // Stop camera and fully reset to cancel any pending operations
        stopCameraSafe();
        if (mainHandler != null) {
            mainHandler.removeCallbacksAndMessages(null);
        }
        resetComponents();

        if (uiController != null) {
            uiController.showScreen(FaceVerificationUIController.UIScreenState.SETUP);
        }
        //  REMOVED: Không cần hiện navbar vì đang chạy trong Activity riêng biệt
    }

    /**
     * Stop camera
     */
    private void stopCamera() {
        try {
            // Make sure camera is fully stopped
            if (cameraView != null) {
                cameraView.stopCamera();
                Log.d(TAG, "Camera stopped");
            }
        } catch (Exception e) {
            Log.e(TAG, "Error stopping camera: " + e.getMessage(), e);
        } finally {
            // Mark as stopped regardless of exceptions
            isCameraStarted = false;
            resetFaceTracker();
        }
    }

    private void resetFaceTracker() {
        if (faceTracker != null) {
            faceTracker.reset();
        }
    }

    /**
     * Initialize the FaceIdEnhancer for liveness challenges
     */
    private void initializeFaceIdEnhancer() {
        if (faceIdEnhancerInitialized) {
            // Already initialized, just reset it
            if (faceIdEnhancer != null) {
                faceIdEnhancer.reset();
            }
            return;
        }

        if (getContext() == null) {
            Log.e(TAG, "Cannot initialize FaceIdEnhancer: Context is null");
            return;
        }

        try {
            // Initialize the FaceIdEnhancer
            faceIdEnhancer = new FaceIdEnhancer(getContext(), this); // enhancer updates liveness context internally
            // Only require gaze (RIGHT -> LEFT) to match current UX and avoid blocking on blink
            faceIdEnhancer.setChallengeType(FaceIdEnhancer.ChallengeType.GAZE_ONLY);
            faceIdEnhancerInitialized = true;
            Log.d(TAG, "FaceIdEnhancer initialized successfully");
        } catch (Exception e) {
            Log.e(TAG, "Error initializing FaceIdEnhancer", e);
        }
    }

    /**
     * Update the frame processing to use FaceIdEnhancer when in LIVENESS_CHALLENGE state
     */
    private void processFrameForLivenessChallenge(Bitmap bitmap, Rect faceRect) {
        if (faceIdEnhancer != null && faceIdEnhancerInitialized) {
            faceIdEnhancer.processFaceFrame(bitmap, faceRect);
        } else {
            Log.w(TAG, "Attempted to process liveness frame but FaceIdEnhancer not initialized");
        }
    }

    //------------------------------------------------------------------------------
    // FaceIdEnhancer.FaceIdEnhancerCallback Implementation
    //------------------------------------------------------------------------------

    @Override
    public void onStateChanged(FaceIdEnhancer.AuthState newState) {
        if (!isAdded()) return;

        Log.d(TAG, "FaceIdEnhancer state changed: " + newState);

        // Show liveness progress indicators when face is detected
        if (newState == FaceIdEnhancer.AuthState.FACE_DETECTED ||
                newState == FaceIdEnhancer.AuthState.ANALYZING) {
            showLivenessProgressIndicators();
        }

        // Update UI based on FaceIdEnhancer state
        if (newState == FaceIdEnhancer.AuthState.BLINK_VERIFIED) {
            // User blinked successfully
            if (binding != null) {
                // Update status message
                binding.tvStatusMessage.setText("Blink detected!");
                binding.tvInstructionMessage.setText("Now look at different directions");

                // Update progress indicators
                binding.ivBlinkIndicator.setColorFilter(
                        ContextCompat.getColor(requireContext(), R.color.success_green),
                        android.graphics.PorterDuff.Mode.SRC_IN);
            }
        } else if (newState == FaceIdEnhancer.AuthState.GAZE_VERIFIED) {
            // User completed gaze challenge
            if (binding != null) {
                // Update status message
                binding.tvStatusMessage.setText("Gaze verified! ✓");
                binding.tvInstructionMessage.setText("Look straight at the camera");

                // Update progress indicators
                binding.ivGazeIndicator.setColorFilter(
                        ContextCompat.getColor(requireContext(), R.color.success_green),
                        android.graphics.PorterDuff.Mode.SRC_IN);
            }
            // Kick off verification complete quickly to avoid getting stuck on this screen
            // Let FaceIdEnhancer emit VERIFIED promptly after completing the sequence
        } else if (newState == FaceIdEnhancer.AuthState.VERIFIED) {
            // All liveness challenges completed
            Log.d(TAG, "Liveness verification complete!");
            // Mark local liveness flag to relax spoof gating during analysis
            livenessVerified = true;
            // Transition to the next state in registration
            stateManager.transitionTo(FaceRegistrationState.FACE_REAL, "Liveness verified!");
            // Mark success and hide liveness overlay
            if (spoofDetectionManager != null) {
                spoofDetectionManager.markLivenessSuccess();
            }
            if (binding != null && binding.llLivenessProgress != null) {
                binding.llLivenessProgress.setVisibility(View.GONE);
            }

            // Immediately show success color and kick off stability → analysis flow
            if (faceOverlayView != null) {
                faceOverlayView.setOvalColor(ContextCompat.getColor(requireContext(), R.color.success_green));
            }

            // Move quickly to FACE_STABLE if we already have a current face rect
            if (currentFaceRect != null) {
                stateManager.transitionTo(FaceRegistrationState.FACE_STABLE, "Perfect! Processing...");
                // Start the 5-second analysis immediately
                if (!isAnalyzing) {
                    startAnalysis();
                }
            } else {
                // If no rect (rare), fall back to FACE_DETECTED to continue normal processing
                stateManager.transitionTo(FaceRegistrationState.FACE_DETECTED, "Face detected");
            }
        }
    }

    /**
     * Show liveness challenge progress indicators
     */
    private void showLivenessProgressIndicators() {
        if (binding != null && binding.llLivenessProgress != null &&
                binding.llLivenessProgress.getVisibility() != View.VISIBLE) {

            // Show progress indicators
            binding.llLivenessProgress.setVisibility(View.VISIBLE);
            // Ensure the liveness progress overlay is above camera and face overlay
            binding.llLivenessProgress.bringToFront();
            binding.llLivenessProgress.requestLayout();
            binding.llLivenessProgress.invalidate();

            // Update instruction text
            binding.tvStatusMessage.setText("Liveness Challenge");
            binding.tvInstructionMessage.setText("Please blink your eyes");
        }
    }

    @Override
    public void onBlinkDetected() {
        if (!isAdded()) return;

        Log.d(TAG, " Blink detected!");
        // Update UI to show blink was detected with visual feedback
        if (binding != null) {
            // Update status message with clear instructions
            binding.tvStatusMessage.setText("Blink detected! ✓");
            binding.tvInstructionMessage.setText("Now look left, right, and up");

            // Update progress indicator
            binding.ivBlinkIndicator.setColorFilter(
                    ContextCompat.getColor(requireContext(), R.color.success_green),
                    android.graphics.PorterDuff.Mode.SRC_IN);

            // Add animation for visual feedback
            binding.ivBlinkIndicator.animate()
                    .scaleX(1.2f).scaleY(1.2f)
                    .setDuration(200)
                    .withEndAction(() -> {
                        binding.ivBlinkIndicator.animate()
                                .scaleX(1.0f).scaleY(1.0f)
                                .setDuration(200);
                    });
        }
    }

    @Override
    public void onGazeDirectionChanged(float x, float y) {
        if (!isAdded()) return;
        // Keep lightweight; used for real-time gaze visualization
        Log.d(TAG, "👀 Gaze direction: x=" + x + ", y=" + y);
    }
    
    @Override
    public void onGazeDirectionCompleted(String direction) {
        if (!isAdded() || binding == null) return;
        
        Log.d(TAG, " Head direction completed: " + direction);
        
        // Update UI based on completed direction
        switch (direction) {
            case "LEFT":
                binding.tvStatusMessage.setText("Left turn verified! ✓");
                break;
            case "RIGHT":
                binding.tvStatusMessage.setText("Right turn verified! ✓");
                break;
            case "CENTER":
                binding.tvStatusMessage.setText("Looking at camera verified! ✓");
                break;
        }
    }

    @Override
    public void onChallengeGenerated(String challengeText) {
        if (!isAdded() || binding == null) return;
        
        Log.d(TAG, "💫 Challenge generated: " + challengeText);
        // Update UI with challenge instruction  
        binding.tvStatusMessage.setText(challengeText);
    }

    @Override
    public void onLivenessVerified(boolean isLive) {
        if (!isAdded()) return;

        Log.d(TAG, "🔐 Liveness verification result: " + (isLive ? "LIVE" : "NOT LIVE"));
        if (isLive) {
            // Proceed with face registration
            stateManager.transitionTo(FaceRegistrationState.FACE_REAL, "Liveness verified!");
        }
    }

    @Override
    public void onVerificationComplete(boolean success) {
        if (!isAdded()) return;

        Log.d(TAG, " Verification complete: " + (success ? "SUCCESS" : "FAILED"));
        if (success) {
            // Proceed with face registration
            stateManager.transitionTo(FaceRegistrationState.FACE_REAL, "Verification complete!");
        }
    }

    /**
     * Reset all components
     */
    private void resetComponents() {
        // Stop camera first
        stopCamera();

        // Reset all managers and state
        if (stateManager != null) {
            stateManager.reset();
        }

        if (spoofDetectionManager != null) {
            spoofDetectionManager.reset();
        }

        resetFaceTracker();

        if (faceOverlayView != null) {
            faceOverlayView.clear();
            // Đặt lại màu của oval để biểu thị trạng thái mới
            faceOverlayView.setOvalColor(ContextCompat.getColor(requireContext(), R.color.white));
        }

        // Clear data
        currentFrameBitmap = null;
        currentFaceRect = null;
        livenessVerified = false;

        // Đặt lại biến phân tích
        isAnalyzing = false;
        frameScores.clear();

        // Ẩn overlay phân tích nếu đang hiển thị
        if (analysisOverlay != null) {
            analysisOverlay.setVisibility(View.GONE);
        }

        // Hide liveness overlay if visible
        if (binding != null && binding.llLivenessProgress != null) {
            binding.llLivenessProgress.setVisibility(View.GONE);
        }

        // Clear any pending handlers/callbacks
        if (mainHandler != null) {
            mainHandler.removeCallbacksAndMessages(null);
        }

        Log.d(TAG, "🔄 All components reset");
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions,
                                           @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == CAMERA_PERMISSION_REQUEST_CODE) {
            boolean allGranted = true;
            for (int result : grantResults) {
                if (result != PackageManager.PERMISSION_GRANTED) {
                    allGranted = false;
                    break;
                }
            }

            if (allGranted) {
                startCamera();
                // Start beacon service now that permissions are granted
                startBeaconService();
            } else {
                stateManager.transitionTo(FaceRegistrationState.FAILED_PERMISSION,
                        "Camera, Location, and Bluetooth permissions are required");
            }
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == SUCCESS_ACTIVITY_REQUEST_CODE) {
            // Success Activity finished, go back
            requireActivity().onBackPressed();
        }
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();

        //  REMOVED: Không cần hiện navbar vì đang chạy trong Activity riêng biệt

        stopCameraSafe();

        // Hủy đăng ký receiver khi destroy view
        if (beaconReceiver != null) {
            try {
                requireActivity().unregisterReceiver(beaconReceiver);
                Log.d(TAG, "✅ BroadcastReceiver unregistered successfully");
            } catch (IllegalArgumentException e) {
                // Receiver was not registered or already unregistered
                Log.w(TAG, "BroadcastReceiver was not registered: " + e.getMessage());
            }
            beaconReceiver = null;
        }

        //  NEW: Cleanup FaceIdRequestManager
        if (requestManager != null) {
            requestManager.cleanup();
        }

        // Cleanup components
        if (stateManager != null) {
            stateManager.cleanup();
        }

        if (uiController != null) {
            uiController.cleanup();
        }

        if (faceIdEnhancer != null) {
            faceIdEnhancer.close();
            faceIdEnhancer = null;
            faceIdEnhancerInitialized = false;
        }

        // Close FaceIdService to properly release MediaPipeFaceLandmarkExtractor
        if (faceIdService != null) {
            faceIdService.close();
            faceIdService = null;
        }

        mainHandler.removeCallbacksAndMessages(null);
        
        // Dismiss any error dialogs
        if (currentErrorDialog != null && currentErrorDialog.isShowing()) {
            currentErrorDialog.dismiss();
            currentErrorDialog = null;
        }

        // Clear references
        cameraView = null;
        faceOverlayView = null;
        binding = null;

        Log.d(TAG, "🧹 Fragment cleaned up");
    }
    // Thêm các biến UI cần thiết
    private ProgressBar analysisProgressBar;
    private TextView analysisCountdownText;
    private View analysisOverlay;

    // Thêm biến theo dõi xem faceIdService đã khởi tạo thành công chưa
    private boolean faceIdServiceInitialized = false;

    /**
     * Start a 5-second analysis of face quality before proceeding with registration
     * Collects frame scores to ensure consistent high-quality face detection
     */
    private void startAnalysis() {
        // Kiểm tra nếu đã đang phân tích
        if (isAnalyzing) {
            Log.d(TAG, "Already analyzing, ignoring new request");
            return;
        }

        isAnalyzing = true;
        frameScores.clear();

        // Kiểm tra fragment tồn tại
        if (!isAdded() || binding == null) return;

        // Khởi tạo và hiển thị UI phân tích nếu chưa tồn tại
        setupAnalysisUI();

        // Hiện overlay phân tích
        if (analysisOverlay != null) {
            analysisOverlay.setVisibility(View.VISIBLE);
        }

        // Start with initial analyzing state message
        stateManager.transitionTo(FaceRegistrationState.ANALYZING, "Analyzing... Hold still");

        // Hiển thị và cập nhật progressBar
        if (analysisProgressBar != null) {
            analysisProgressBar.setVisibility(View.VISIBLE);
            analysisProgressBar.setMax(ANALYSIS_DURATION_MS);
            analysisProgressBar.setProgress(0);

            // Animator để cập nhật progress một cách mượt mà
            final ValueAnimator progressAnimator = ValueAnimator.ofInt(0, ANALYSIS_DURATION_MS);
            progressAnimator.setDuration(ANALYSIS_DURATION_MS);
            progressAnimator.setInterpolator(new LinearInterpolator());
            progressAnimator.addUpdateListener(animation -> {
                if (analysisProgressBar != null && isAdded()) {
                    analysisProgressBar.setProgress((Integer) animation.getAnimatedValue());
                }
            });
            progressAnimator.start();
        }

        // Start countdown feedback
        final int[] secondsLeft = {ANALYSIS_DURATION_MS / 1000};
        final int countdownInterval = 1000; // 1 second

        // Countdown handler to update UI every second
        final Handler countdownHandler = new Handler(Looper.getMainLooper());
        final Runnable countdownRunnable = new Runnable() {
            @Override
            public void run() {
                if (!isAdded() || !isAnalyzing) return;

                secondsLeft[0]--;
                if (secondsLeft[0] > 0) {
                    // Update countdown message and UI
                    String message = "Analyzing... " + secondsLeft[0] + "s";
                    stateManager.transitionTo(FaceRegistrationState.ANALYZING, message);

                    // Cập nhật text đếm ngược
                    if (analysisCountdownText != null) {
                        analysisCountdownText.setText(message);
                    }

                    countdownHandler.postDelayed(this, countdownInterval);
                }
            }
        };

        // Start countdown updates
        countdownHandler.postDelayed(countdownRunnable, countdownInterval);

        // Schedule analysis completion
        mainHandler.postDelayed(() -> {
            // Stop analyzing
            isAnalyzing = false;
            countdownHandler.removeCallbacks(countdownRunnable);

            // Ẩn overlay phân tích
            if (analysisOverlay != null && isAdded()) {
                analysisOverlay.setVisibility(View.GONE);
            }

            // Check if fragment is still valid
            if (!isAdded()) {
                Log.w(TAG, "Fragment not attached during analysis completion");
                return;
            }
            // Calculate statistics (robustness: trim top/bottom 10% outliers when liveness is verified)
            float sum = 0;
            float min = Float.MAX_VALUE;
            float max = Float.MIN_VALUE;

            java.util.List<Float> scores = new java.util.ArrayList<>(frameScores);
            if (livenessVerified && scores.size() >= 10) {
                java.util.Collections.sort(scores);
                int trim = Math.max(1, Math.round(scores.size() * 0.1f));
                scores = scores.subList(trim, scores.size() - trim);
            }
            for (float score : scores) {
                sum += score;
                min = Math.min(min, score);
                max = Math.max(max, score);
            }

            float averageScore = sum / scores.size();
            float variance = calculateVariance(scores, averageScore);
            
            // Quality assessment
            // Relax variance threshold after liveness due to natural gaze recovery
            boolean isConsistent = variance < (livenessVerified ? 0.06f : 0.03f);
            // After liveness, relax thresholds slightly and require realness >= 0.5
            float minAvg = MIN_AVERAGE_SCORE_FOR_REGISTRATION;
            if (livenessVerified) {
                minAvg = Math.max(0.6f, MIN_AVERAGE_SCORE_FOR_REGISTRATION - 0.1f);
            }
            boolean isHighQuality = averageScore >= minAvg;
            boolean isAcceptableQuality = averageScore >= (minAvg - 0.05f);

            // Log detailed quality information
            // String qualityLog = String.format(Locale.US,
            //         "Face Analysis Results - Frames: %d, Average Score: %.3f, Min: %.3f, Max: %.3f, Variance: %.5f, " +
            //                 "isConsistent: %b, isHighQuality: %b, isAcceptableQuality: %b",
            //         frameScores.size(), averageScore, min, max, variance,
            //         isConsistent, isHighQuality, isAcceptableQuality);
            // Log.d(TAG, qualityLog);

            // Different paths based on quality assessment
            if (isHighQuality && isConsistent) {
                // High quality and consistent - proceed with registration
                stateManager.transitionTo(FaceRegistrationState.PROCESSING,
                        "Quality check passed. Verifying...");
                captureAndVerifyFace();
            } else if (isAcceptableQuality) {
                // Acceptable but not ideal - warn user but proceed
                stateManager.transitionTo(FaceRegistrationState.PROCESSING,
                        "Acceptable quality. Proceeding with verification...");
                captureAndVerifyFace();
            } else {
                // Low quality - provide specific feedback based on issues
                String feedbackMessage = generateQualityFeedback(averageScore, variance);
                // lastDetailedErrorMessage = qualityLog + "\n\nDetailed Analysis: " + feedbackMessage;
                hasDetailedError = true;
                // Log.e(TAG, " Analysis failed: " + lastDetailedErrorMessage);
                stateManager.transitionTo(FaceRegistrationState.FAILED_OTHER, feedbackMessage);
            }
        }, ANALYSIS_DURATION_MS);
    }

    /**
     * Thiết lập UI cho phân tích
     */
    private void setupAnalysisUI() {
        if (binding == null || !isAdded()) return;

        // Kiểm tra nếu đã tạo UI trước đó
        if (analysisOverlay != null) {
            // Đảm bảo hiển thị UI chính xác
            analysisOverlay.setVisibility(View.VISIBLE);
            return;
        }

        // Tạo overlay cho phân tích
        analysisOverlay = LayoutInflater.from(requireContext())
                .inflate(R.layout.overlay_face_analysis, binding.flStudentSettingVerifyFaceIdCameraContainer, false);

        // Thêm vào container
        binding.flStudentSettingVerifyFaceIdCameraContainer.addView(analysisOverlay);

        // Lấy reference đến các thành phần UI
        analysisProgressBar = analysisOverlay.findViewById(R.id.progressBarAnalysis);
        analysisCountdownText = analysisOverlay.findViewById(R.id.tvAnalysisCountdown);

        // Đảm bảo progressBar ở trạng thái mặc định ban đầu
        if (analysisProgressBar != null) {
            analysisProgressBar.setProgress(0);
        }

        // Đặt text ban đầu cho countdown
        if (analysisCountdownText != null) {
            analysisCountdownText.setText("Analyzing...");
        }

        // Hiển thị UI
        analysisOverlay.setVisibility(View.VISIBLE);

        Log.d(TAG, "Analysis UI initialized and shown");
    }

    /**
     * Calculate variance of collected scores to assess consistency
     */
    private float calculateVariance(java.util.List<Float> scores, float mean) {
        float sumSquaredDiff = 0;
        for (float score : scores) {
            float diff = score - mean;
            sumSquaredDiff += diff * diff;
        }
        return sumSquaredDiff / scores.size();
    }

    /**
     * Generate specific feedback based on detected quality issues
     */
    private String generateQualityFeedback(float averageScore, float variance) {
        StringBuilder feedback = new StringBuilder();

        if (variance > 0.05) {
            feedback.append("Detected unstable face. Please hold your face steadier and try again.");
            feedback.append("\n\nDetails: Variance = ").append(String.format(Locale.US, "%.5f", variance));
            feedback.append(" (exceeds threshold 0.05)");
        } else if (averageScore < 0.4f) {
            feedback.append("Very low detection quality. Please try again with better lighting.");
            feedback.append("\n\nDetails: Average score = ").append(String.format(Locale.US, "%.3f", averageScore));
            feedback.append(" (below minimum 0.4)");
        } else if (averageScore < 0.6f) {
            feedback.append("Low detection quality. Improve lighting and reduce face movement.");
            feedback.append("\n\nDetails: Average score = ").append(String.format(Locale.US, "%.3f", averageScore));
            feedback.append(" (below recommended 0.6)");
        } else {
            feedback.append("Unable to capture a clear image. Please try again with better lighting and positioning.");
            feedback.append("\n\nDetails: Combination of detection score and stability did not meet requirements");
        }

        return feedback.toString();
    }

    /**
     *  NEW: Setup callbacks cho FaceIdRequestManager
     */
    private void setupRequestManagerCallbacks() {
        requestManager.setStatusCallback(new FaceIdRequestManager.RequestStatusCallback() {
            @Override
            public void onRequestStatusUpdated(FaceIdRequestManager.RequestState state, 
                                            com.example.flutter_application_1.faceid.data.model.response.FaceIdRequestStatusResponse response) {
                if (!isAdded()) return;
                
                Log.d(TAG, "🔄 Request status updated: " + state);
                
                switch (state) {
                    case VERIFIED:
                        handleRequestVerified();
                        break;
                    case EXPIRED:
                        handleRequestExpired();
                        break;
                    case CANCELLED:
                        handleRequestCancelled();
                        break;
                    case FAILED:
                        handleRequestFailed("Request verification failed");
                        break;
                }
            }
            
            @Override
            public void onRequestExpired() {
                if (!isAdded()) return;
                handleRequestExpired();
            }
            
            @Override
            public void onRequestCancelled() {
                if (!isAdded()) return;
                handleRequestCancelled();
            }
            
            @Override
            public void onRequestFailed(String error) {
                if (!isAdded()) return;
                handleRequestFailed(error);
            }
        });
        
        requestManager.setExpiredCallback(() -> {
            if (!isAdded()) return;
            handleRequestExpired();
        });
    }
    
    /**
     *  NEW: Handle request verified successfully
     */
    private void handleRequestVerified() {
        Log.d(TAG, " Request verified successfully");
        stopCameraSafe();
        
        // Navigate to success screen
        String userId = AuthManager.getInstance(requireContext()).getEmployeeId();
        String userName = AuthManager.getInstance(requireContext()).getCurrentUserName();
        
        Intent successIntent = FaceIdSuccessActivity.createVerifySuccessIntent(
            requireContext(),
            userId,
            userName
        );
        // Stop beacon scanning when a remote request is verified as well
        stopBeaconService();
        startActivity(successIntent);
        requireActivity().finish();
    }
    
    /**
     *  NEW: Handle request expired
     */
    private void handleRequestExpired() {
        Log.d(TAG, "⏰ Request expired");
        stopCameraSafe();
        
        // Show expired message
        Toast.makeText(requireContext(), "Verification window expired", Toast.LENGTH_LONG).show();
        
        // Go back to previous screen
        requireActivity().onBackPressed();
    }
    
    /**
     *  NEW: Handle request cancelled
     */
    private void handleRequestCancelled() {
        Log.d(TAG, " Request cancelled");
        stopCameraSafe();
        
        // Show cancelled message
        Toast.makeText(requireContext(), "Verification request was cancelled", Toast.LENGTH_LONG).show();
        
        // Go back to previous screen
        requireActivity().onBackPressed();
    }
    
    /**
     *  NEW: Handle request failed
     */
    private void handleRequestFailed(String error) {
        Log.e(TAG, " Request failed: " + error);
        
        // Show error message
        Toast.makeText(requireContext(), "Verification failed: " + error, Toast.LENGTH_LONG).show();
        
        // Allow retry if not expired
        if (!requestManager.isExpired()) {
            // Reset state for retry
            resetComponents();
            startFaceRegistration();
        } else {
            // Request expired, go back
            requireActivity().onBackPressed();
        }
    }
    
}



