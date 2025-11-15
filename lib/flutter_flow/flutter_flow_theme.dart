import 'package:flutter/material.dart';

const kThemeModeKey = '__theme_mode__';

abstract class FlutterFlowTheme {
  static FlutterFlowTheme of(BuildContext context) {
    return LightModeTheme();
  }

  late Color primaryColor;
  late Color secondaryColor;
  late Color tertiaryColor;
  late Color alternate;
  late Color primaryBackground;
  late Color secondaryBackground;
  late Color primaryText;
  late Color secondaryText;

  late Color error;
  late Color success;
  late Color warning;
  late Color info;

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
  Color primaryColor = const Color(0xFF4B39EF);
  @override
  Color secondaryColor = const Color(0xFF39D2C0);
  @override
  Color tertiaryColor = const Color(0xFFEE8B60);
  @override
  Color alternate = const Color(0xFFE0E3E7);
  @override
  Color primaryBackground = const Color(0xFFF1F4F8);
  @override
  Color secondaryBackground = const Color(0xFFFFFFFF);
  @override
  Color primaryText = const Color(0xFF14181B);
  @override
  Color secondaryText = const Color(0xFF57636C);

  @override
  Color error = const Color(0xFFFF5963);
  @override
  Color success = const Color(0xFF249689);
  @override
  Color warning = const Color(0xFFF9CF58);
  @override
  Color info = const Color(0xFFFFFFFF);
}

class DarkModeTheme extends FlutterFlowTheme {
  @override
  Color primaryColor = const Color(0xFF4B39EF);
  @override
  Color secondaryColor = const Color(0xFF39D2C0);
  @override
  Color tertiaryColor = const Color(0xFFEE8B60);
  @override
  Color alternate = const Color(0xFF262D34);
  @override
  Color primaryBackground = const Color(0xFF1A1F24);
  @override
  Color secondaryBackground = const Color(0xFF14181B);
  @override
  Color primaryText = const Color(0xFFFFFFFF);
  @override
  Color secondaryText = const Color(0xFF95A1AC);

  @override
  Color error = const Color(0xFFFF5963);
  @override
  Color success = const Color(0xFF249689);
  @override
  Color warning = const Color(0xFFF9CF58);
  @override
  Color info = const Color(0xFFFFFFFF);
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
