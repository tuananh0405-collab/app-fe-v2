import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'core/routing/app_router.dart';
import 'core/di/injection_container.dart' as di;
import 'core/localization/app_localizations.dart';
import 'core/services/push_notification_providers.dart';
import 'core/services/push_notification_service.dart';
import 'faceid_channel.dart';
import 'flutter_flow/flutter_flow.dart';
import 'features/face_id/face_id_success_handler.dart';

import 'core/providers/common_providers.dart';

// Global key for navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  
  // Initialize Firebase only once to avoid duplicate app errors
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (!e.toString().contains('already exists')) {
      rethrow;
    }
  }
  
  // ✅ CRITICAL FIX: Register background message handler BEFORE runApp()
  // This allows app to handle messages even when killed/terminated
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Initialize DI
  await di.init();
  
  // Initialize Face ID channel
  FaceIdChannel.init();

  runApp(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
    ],
    child: const PushNotificationInitializer(
      child: MyApp(),
    ),
  ));
}

/// Widget to initialize push notifications
class PushNotificationInitializer extends ConsumerStatefulWidget {
  final Widget child;
  
  const PushNotificationInitializer({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<PushNotificationInitializer> createState() => _PushNotificationInitializerState();
}

class _PushNotificationInitializerState extends ConsumerState<PushNotificationInitializer> {
  @override
  void initState() {
    super.initState();
    // Initialize push notifications after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPushNotifications();
    });
  }

  Future<void> _initPushNotifications() async {
    try {
      final manager = ref.read(pushNotificationManagerProvider);
      
      // Initialize with callbacks
      await manager.initialize(
        onNotificationTapped: (message) {
          debugPrint('📱 Notification tapped: ${message.messageId}');
          debugPrint('📱 Title: ${message.notification?.title}');
          debugPrint('📱 Body: ${message.notification?.body}');
          debugPrint('📱 Data: ${message.data}');
          
          // TODO: Handle navigation based on notification data
          // Example: 
          // if (message.data['type'] == 'leave_request') {
          //   navigatorKey.currentState?.pushNamed('/leave-detail', arguments: message.data['id']);
          // }
        },
        onForegroundMessage: (message) {
          debugPrint('📬 Foreground message received: ${message.messageId}');
          debugPrint('📬 Title: ${message.notification?.title}');
          debugPrint('📬 Body: ${message.notification?.body}');
          debugPrint('📬 Data: ${message.data}');
          
          // Local notification will be shown automatically by the service
        },
      );
      
      // Register token if notifications are enabled
      await manager.registerCurrentToken();
      
      debugPrint(' Push notifications initialized successfully');
    } catch (e) {
      debugPrint(' Error initializing push notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);
    final ffTheme = FlutterFlowTheme.of(context);
    
    return FaceIdSuccessHandler(
      child: MaterialApp.router(
        title: 'Employee App',
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English
          Locale('vi', ''), // Vietnamese
        ],
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: ffTheme.primaryColor,
          scaffoldBackgroundColor: ffTheme.primaryBackground,
          textTheme: TextTheme(
            displayLarge: ffTheme.title1,
            displayMedium: ffTheme.title2,
            displaySmall: ffTheme.title3,
            headlineMedium: ffTheme.subtitle1,
            titleMedium: ffTheme.subtitle2,
            bodyLarge: ffTheme.bodyText1,
            bodyMedium: ffTheme.bodyText2,
          ),
        ),
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
