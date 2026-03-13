import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_theme.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final bool borderGlow;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 16.0,
    this.borderGlow = true,
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.backgroundDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: borderGlow
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.15),
                  blurRadius: 15,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      child: child,
    );

    content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: content,
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}

class NeonGlowText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color color;

  const NeonGlowText(
    this.text, {
    super.key,
    this.style,
    this.color = AppTheme.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: (style ?? const TextStyle()).copyWith(
        color: color,
        shadows: [
          Shadow(
            color: color.withValues(alpha: 0.8),
            blurRadius: 10,
          ),
          Shadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 20,
          ),
        ],
      ),
    );
  }
}
