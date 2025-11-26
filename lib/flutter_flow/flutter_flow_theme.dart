import 'package:flutter/material.dart';

const kThemeModeKey = '__theme_mode__';

abstract class FlutterFlowTheme {
  static FlutterFlowTheme of(BuildContext context) {
    return LightModeTheme();
  }

  // Convert all fields into abstract getters
  Color get primaryColor;
  Color get secondaryColor;
  Color get tertiaryColor;
  Color get alternate;
  Color get primaryBackground;
  Color get secondaryBackground;
  Color get primaryText;
  Color get secondaryText;

  Color get error;
  Color get success;
  Color get warning;
  Color get info;

  String get title1Family => typography.title1Family;
  TextStyle get title1 => typography.title1;
  String get title2Family => typography.title2Family;
  TextStyle get title2 => typography.title2;
  String get title3Family => typography.title3Family;
  TextStyle get title3 => typography.title3;
  String get subtitle1Family => typography.subtitle1Family;
  TextStyle get subtitle1 => typography.subtitle1;
  String get subtitle2Family => typography.subtitle2Family;
  TextStyle get subtitle2 => typography.subtitle2;
  String get bodyText1Family => typography.bodyText1Family;
  TextStyle get bodyText1 => typography.bodyText1;
  String get bodyText2Family => typography.bodyText2Family;
  TextStyle get bodyText2 => typography.bodyText2;

  ThemeTypography get typography => ThemeTypography(this);
}

class LightModeTheme extends FlutterFlowTheme {
  @override
  Color get primaryColor => const Color(0xFF3B82F6); // Blue 500
  @override
  Color get secondaryColor => const Color(0xFF6366F1); // Indigo 500
  @override
  Color get tertiaryColor => const Color(0xFF0EA5E9); // Sky 500
  @override
  Color get alternate => const Color(0xFFE5E7EB); // Gray 200

  @override
  Color get primaryBackground => const Color(0xFFF9FAFB); // Gray 50
  @override
  Color get secondaryBackground => const Color(0xFFFFFFFF);

  @override
  Color get primaryText => const Color(0xFF111827); // Gray 900
  @override
  Color get secondaryText => const Color(0xFF6B7280); // Gray 500

  @override
  Color get error => const Color(0xFFEF4444);
  @override
  Color get success => const Color(0xFF10B981);
  @override
  Color get warning => const Color(0xFFF59E0B);
  @override
  Color get info => const Color(0xFF3B82F6);
}


class DarkModeTheme extends FlutterFlowTheme {
  @override
  Color get primaryColor => const Color(0xFF4B39EF);
  @override
  Color get secondaryColor => const Color(0xFF39D2C0);
  @override
  Color get tertiaryColor => const Color(0xFFEE8B60);
  @override
  Color get alternate => const Color(0xFF262D34);
  @override
  Color get primaryBackground => const Color(0xFF1A1F24);
  @override
  Color get secondaryBackground => const Color(0xFF14181B);
  @override
  Color get primaryText => const Color(0xFFFFFFFF);
  @override
  Color get secondaryText => const Color(0xFF95A1AC);

  @override
  Color get error => const Color(0xFFFF5963);
  @override
  Color get success => const Color(0xFF249689);
  @override
  Color get warning => const Color(0xFFF9CF58);
  @override
  Color get info => const Color(0xFFFFFFFF);
}

class ThemeTypography {
  ThemeTypography(this.theme);

  final FlutterFlowTheme theme;

  String get title1Family => 'Poppins';
  TextStyle get title1 => TextStyle(
        fontFamily: 'Poppins',
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 24,
      );
  String get title2Family => 'Poppins';
  TextStyle get title2 => TextStyle(
        fontFamily: 'Poppins',
        color: theme.secondaryText,
        fontWeight: FontWeight.w500,
        fontSize: 22,
      );
  String get title3Family => 'Poppins';
  TextStyle get title3 => TextStyle(
        fontFamily: 'Poppins',
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 20,
      );
  String get subtitle1Family => 'Poppins';
  TextStyle get subtitle1 => TextStyle(
        fontFamily: 'Poppins',
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      );
  String get subtitle2Family => 'Poppins';
  TextStyle get subtitle2 => TextStyle(
        fontFamily: 'Poppins',
        color: theme.secondaryText,
        fontWeight: FontWeight.normal,
        fontSize: 16,
      );
  String get bodyText1Family => 'Poppins';
  TextStyle get bodyText1 => TextStyle(
        fontFamily: 'Poppins',
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 14,
      );
  String get bodyText2Family => 'Poppins';
  TextStyle get bodyText2 => TextStyle(
        fontFamily: 'Poppins',
        color: theme.secondaryText,
        fontWeight: FontWeight.normal,
        fontSize: 12,
      );
}

extension TextStyleHelper on TextStyle {
  TextStyle override({
    String? fontFamily,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    FontStyle? fontStyle,
    bool useGoogleFonts = true,
    TextDecoration? decoration,
    double? lineHeight,
  }) =>
      copyWith(
        fontFamily: fontFamily,
        color: color,
        fontSize: fontSize,
        letterSpacing: letterSpacing,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        decoration: decoration,
        height: lineHeight,
      );
}
