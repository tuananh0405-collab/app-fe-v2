import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'core/routing/app_router.dart';
import 'core/di/injection_container.dart' as di;
import 'core/localization/app_localizations.dart';
import 'core/services/push_notification_providers.dart';
import 'core/services/push_notification_providers.dart';
import 'faceid_channel.dart';
import 'flutter_flow/flutter_flow.dart';
import 'features/face_id/face_id_success_handler.dart';

import 'core/providers/common_providers.dart';

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
  
  // Initialize DI
  await di.init();
  
  // Initialize Face ID channel
  FaceIdChannel.init();

  runApp(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
    ],
    child: const MyApp(),
  ));
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
