import 'package:flutter/material.dart';
import 'flutter_flow_theme.dart';

/// FlutterFlow Button Widget
class FFButton extends StatelessWidget {
  const FFButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.iconSize = 15,
    this.options,
  });

  final VoidCallback? onPressed;
  final String text;
  final Widget? icon;
  final double iconSize;
  final FFButtonOptions? options;

  @override
  Widget build(BuildContext context) {
    final buttonOptions = options ?? FFButtonOptions();
    final theme = FlutterFlowTheme.of(context);

    return Container(
      width: buttonOptions.width,
      height: buttonOptions.height,
      decoration: BoxDecoration(
        gradient: buttonOptions.gradient,
        boxShadow: buttonOptions.elevation != null
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 0,
                  blurRadius: buttonOptions.elevation!,
                  offset: Offset(0, buttonOptions.elevation! / 2),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              buttonOptions.color ?? theme.primaryColor,
          foregroundColor: buttonOptions.textStyle?.color ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
                buttonOptions.borderRadius ?? BorderRadius.circular(8),
            side: buttonOptions.borderSide ?? BorderSide.none,
          ),
          padding: buttonOptions.padding ?? const EdgeInsets.all(0),
          elevation: 0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon!,
              if (text.isNotEmpty) const SizedBox(width: 8),
            ],
            if (text.isNotEmpty)
              Text(
                text,
                style: buttonOptions.textStyle ?? theme.subtitle2,
              ),
          ],
        ),
      ),
    );
  }
}

class FFButtonOptions {
  const FFButtonOptions({
    this.textStyle,
    this.elevation,
    this.height,
    this.width,
    this.padding,
    this.color,
    this.disabledColor,
    this.disabledTextColor,
    this.splashColor,
    this.iconSize,
    this.iconColor,
    this.iconPadding,
    this.borderRadius,
    this.borderSide,
    this.gradient,
  });

  final TextStyle? textStyle;
  final double? elevation;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? disabledColor;
  final Color? disabledTextColor;
  final Color? splashColor;
  final double? iconSize;
  final Color? iconColor;
  final EdgeInsetsGeometry? iconPadding;
  final BorderRadius? borderRadius;
  final BorderSide? borderSide;
  final Gradient? gradient;
}

/// FlutterFlow Icon Button Widget
class FFIconButton extends StatelessWidget {
  const FFIconButton({
    super.key,
    required this.icon,
    this.borderColor,
    this.borderRadius,
    this.borderWidth,
    this.buttonSize,
    this.fillColor,
    this.disabledColor,
    this.disabledIconColor,
    this.hoverColor,
    this.hoverIconColor,
    this.onPressed,
    this.showLoadingIndicator = false,
  });

  final Widget icon;
  final Color? borderColor;
  final double? borderRadius;
  final double? borderWidth;
  final double? buttonSize;
  final Color? fillColor;
  final Color? disabledColor;
  final Color? disabledIconColor;
  final Color? hoverColor;
  final Color? hoverIconColor;
  final VoidCallback? onPressed;
  final bool showLoadingIndicator;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: fillColor ?? Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 0),
        side: BorderSide(
          color: borderColor ?? Colors.transparent,
          width: borderWidth ?? 0,
        ),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(borderRadius ?? 0),
        hoverColor: hoverColor,
        child: Container(
          width: buttonSize ?? 40,
          height: buttonSize ?? 40,
          alignment: Alignment.center,
          child: showLoadingIndicator
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : icon,
        ),
      ),
    );
  }
}

/// FlutterFlow Loading Indicator
class FFLoadingIndicator extends StatelessWidget {
  const FFLoadingIndicator({
    super.key,
    this.size = 50.0,
    this.color,
  });

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? FlutterFlowTheme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}
