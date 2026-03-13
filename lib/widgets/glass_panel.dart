import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GlassPanel
// ─────────────────────────────────────────────────────────────────────────────
class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final bool borderGlow;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? backgroundColor;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 16.0,
    this.borderGlow = true,
    this.onTap,
    this.borderColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bc = borderColor ?? AppTheme.primary.withValues(alpha: 0.25);
    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.bgCard.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: bc, width: 1),
        boxShadow: borderGlow
            ? [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.1), blurRadius: 20, spreadRadius: 1)]
            : null,
      ),
      child: child,
    );

    content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: content,
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: content);
    }
    return content;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NeonGlowText
// ─────────────────────────────────────────────────────────────────────────────
class NeonGlowText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color color;

  const NeonGlowText(this.text,
      {super.key, this.style, this.color = AppTheme.primary});

  @override
  Widget build(BuildContext context) {
    final s = (style ?? const TextStyle()).copyWith(
      color: color,
      shadows: [
        Shadow(color: color.withValues(alpha: 0.9), blurRadius: 12),
        Shadow(color: color.withValues(alpha: 0.4), blurRadius: 24),
      ],
    );
    return Text(text, style: s);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NeonButton  – pulsing elevated button with glow shadow
// ─────────────────────────────────────────────────────────────────────────────
class NeonButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color color;
  final bool wide;

  const NeonButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.color = AppTheme.primary,
    this.wide = true,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween(begin: 1.0, end: 0.94).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (!_pressed) {
          _pressed = true;
          _ctrl.forward();
        }
      },
      onTapUp: (_) {
        _pressed = false;
        _ctrl.reverse().then((_) => widget.onTap?.call());
      },
      onTapCancel: () {
        _pressed = false;
        _ctrl.reverse();
      },
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: widget.wide ? double.infinity : null,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: widget.color.withValues(alpha: 0.55),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: widget.wide ? MainAxisSize.max : MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: Colors.black, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    letterSpacing: 1.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AnimatedStarRating – reveals stars one-by-one with bounce
// ─────────────────────────────────────────────────────────────────────────────
class AnimatedStarRating extends StatefulWidget {
  final int stars; // 0-3
  final double size;

  const AnimatedStarRating({super.key, required this.stars, this.size = 48});

  @override
  State<AnimatedStarRating> createState() => _AnimatedStarRatingState();
}

class _AnimatedStarRatingState extends State<AnimatedStarRating>
    with TickerProviderStateMixin {
  final List<AnimationController> _ctrls = [];
  final List<Animation<double>> _scales = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
      final ctrl = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 400));
      final scale = Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: ctrl, curve: Curves.elasticOut));
      _ctrls.add(ctrl);
      _scales.add(scale);
      if (i < widget.stars) {
        Future.delayed(Duration(milliseconds: 300 + i * 250), () {
          if (mounted) ctrl.forward();
        });
      }
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final earned = i < widget.stars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: ScaleTransition(
            scale: earned ? _scales[i] : AlwaysStoppedAnimation(1.0),
            child: Icon(
              earned ? Icons.star_rounded : Icons.star_outline_rounded,
              size: widget.size,
              color: earned ? AppTheme.warning : Colors.white12,
              shadows: earned
                  ? [
                      Shadow(
                          color: AppTheme.warning.withValues(alpha: 0.7),
                          blurRadius: 12)
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GradientBackground
// ─────────────────────────────────────────────────────────────────────────────
class GradientBackground extends StatelessWidget {
  final Widget child;
  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.bgDark, Color(0xFF0D1F2D), AppTheme.bgDark],
          stops: [0, 0.5, 1],
        ),
      ),
      child: child,
    );
  }
}
