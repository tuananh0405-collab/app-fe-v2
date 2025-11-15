import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:from_css_color/from_css_color.dart';

export 'package:page_transition/page_transition.dart';
export 'flutter_flow_theme.dart';
export 'lat_lng.dart';
export 'place.dart';
export 'uploaded_file.dart';

/// EXTENSIONS

extension FFStringExt on String {
  String maybeHandleOverflow({int? maxChars, String replacement = ''}) =>
      maxChars != null && length > maxChars
          ? replaceRange(maxChars, null, replacement)
          : this;
}

extension FFListExt<T> on List<T> {
  List<T> sortedList(int Function(T, T) compare) => [...this]..sort(compare);
}

extension FFNumExt on num {
  num get clamp0 => clamp(0, this);
}

/// URL LAUNCHER

Future<void> launchURL(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $url';
  }
}

/// DATE TIME

String dateTimeFormat(String format, DateTime? dateTime, {String? locale}) {
  if (dateTime == null) {
    return '';
  }
  if (format == 'relative') {
    return timeago.format(dateTime, locale: locale);
  }
  return DateFormat(format, locale).format(dateTime);
}

/// MEDIA SIZE

const kBreakpointSmall = 479.0;
const kBreakpointMedium = 767.0;
const kBreakpointLarge = 991.0;

enum MediaSize {
  mobile,
  tablet,
  desktop,
}

MediaSize getMediaSize(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width <= kBreakpointSmall) {
    return MediaSize.mobile;
  } else if (width <= kBreakpointMedium) {
    return MediaSize.tablet;
  }
  return MediaSize.desktop;
}

bool isWeb = kIsWeb;
bool isMobile = !kIsWeb && (Platform.isIOS || Platform.isAndroid);
bool isAndroid = !kIsWeb && Platform.isAndroid;
bool isIOS = !kIsWeb && Platform.isIOS;
bool isDesktop = !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

/// RESPONSIVE

T valueOrDefault<T>(T? value, T defaultValue) =>
    (value is String && value.isEmpty) || value == null ? defaultValue : value;

String dateTimeFromSecondsSinceEpoch(int seconds) {
  final dateTime = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  return dateTimeFormat('yMMMd', dateTime);
}

/// PLATFORM-SPECIFIC CHECKS

bool get isAndroidPlatform => !kIsWeb && Platform.isAndroid;
bool get isIOSPlatform => !kIsWeb && Platform.isIOS;
bool get isWebPlatform => kIsWeb;

/// SNACK BAR

void showSnackbar(
  BuildContext context,
  String message, {
  bool loading = false,
  int duration = 4,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (loading)
              const Padding(
                padding: EdgeInsetsDirectional.only(end: 10.0),
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            Expanded(child: Text(message)),
          ],
        ),
        duration: Duration(seconds: duration),
      ),
    );
}

/// FORMAT NUMBER

String formatNumber(
  num? number, {
  String? format,
  String? locale,
  bool? compact,
  String? currency,
}) {
  if (number == null) {
    return '';
  }
  
  if (compact ?? false) {
    return NumberFormat.compact(locale: locale).format(number);
  }
  
  if (currency != null) {
    return NumberFormat.simpleCurrency(
      locale: locale,
      name: currency,
    ).format(number);
  }
  
  if (format != null) {
    return NumberFormat(format, locale).format(number);
  }
  
  return NumberFormat.decimalPattern(locale).format(number);
}

/// DEVICE INFO

bool get isPhone {
  if (kIsWeb) return false;
  return Platform.isAndroid || Platform.isIOS;
}

bool get isTablet {
  if (kIsWeb) return false;
  // You might need to implement more sophisticated tablet detection
  return false;
}

/// COLOR UTILITIES

Color? colorFromCssString(String color, {Color? defaultColor}) {
  try {
    return fromCssColor(color);
  } catch (_) {
    return defaultColor;
  }
}
