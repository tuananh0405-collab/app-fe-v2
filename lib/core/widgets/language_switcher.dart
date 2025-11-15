import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../localization/app_localizations.dart';
import '../../flutter_flow/flutter_flow.dart';

class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = FlutterFlowTheme.of(context);
    final currentLocale = ref.watch(localeProvider);
    
    return PopupMenuButton<Locale>(
      icon: Icon(
        Icons.language,
        color: Colors.white,
      ),
      onSelected: (Locale locale) {
        ref.read(localeProvider.notifier).state = locale;
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<Locale>(
          value: const Locale('en'),
          child: Row(
            children: [
              Text('🇬🇧 ', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text('English'),
              if (currentLocale.languageCode == 'en')
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(Icons.check, color: theme.primaryColor, size: 20),
                ),
            ],
          ),
        ),
        PopupMenuItem<Locale>(
          value: const Locale('vi'),
          child: Row(
            children: [
              Text('🇻🇳 ', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text('Tiếng Việt'),
              if (currentLocale.languageCode == 'vi')
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(Icons.check, color: theme.primaryColor, size: 20),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
