import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/routing/app_router.dart';
import 'core/di/injection_container.dart' as di;
import 'core/localization/app_localizations.dart';
import 'faceid_channel.dart';
import 'flutter_flow/flutter_flow.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  // Initialize native Face ID channel listener
  FaceIdChannel.init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);
    final ffTheme = FlutterFlowTheme.of(context);
    
    return MaterialApp.router(
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
    );
  }
}
