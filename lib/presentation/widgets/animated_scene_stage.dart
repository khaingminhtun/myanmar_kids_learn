import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Reusable stage container for scene illustrations and cards.
/// Provides subtle breathing animation, tap-to-bounce action, and gentle
/// retry wiggling without scary red indicators.
class AnimatedSceneStage extends StatefulWidget {
  const AnimatedSceneStage({
    super.key,
    required this.child,
    this.onTap,
    this.isWiggling = false,
    this.backgroundColor,
    this.borderColor,
    this.padding = const EdgeInsets.all(12),
    this.borderRadius = 24.0,
    this.enableBreathing = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool isWiggling;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool enableBreathing;

  @override
  State<AnimatedSceneStage> createState() => _AnimatedSceneStageState();
}

class _AnimatedSceneStageState extends State<AnimatedSceneStage>
    with TickerProviderStateMixin {
  late final AnimationController _breatheController;
  late final Animation<double> _breatheAnimation;

  late final AnimationController _wiggleController;
  late final Animation<double> _wiggleAnimation;

  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    // Subtle breathing animation
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _breatheAnimation = Tween<double>(begin: 1.0, end: 1.018).animate(
      CurvedAnimation(
        parent: _breatheController,
        curve: Curves.easeInOutSine,
      ),
    );
    if (widget.enableBreathing) {
      _breatheController.repeat(reverse: true);
    }

    // Gentle wiggle animation for gentle retries
    _wiggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _wiggleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _wiggleController,
        curve: Curves.easeInOut,
      ),
    );

    // Tap bounce animation
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.easeOut,
      ),
    );

    if (widget.isWiggling) {
      _wiggleController.forward(from: 0.0);
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedSceneStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isWiggling && !oldWidget.isWiggling) {
      _wiggleController.forward(from: 0.0);
    }
    if (widget.enableBreathing != oldWidget.enableBreathing) {
      if (widget.enableBreathing) {
        _breatheController.repeat(reverse: true);
      } else {
        _breatheController.stop();
      }
    }
  }

  @override
  void dispose() {
    _breatheController.dispose();
    _wiggleController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onTap == null) return;
    _bounceController.forward().then((_) {
      if (mounted) _bounceController.reverse();
    });
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _breatheAnimation,
        _wiggleAnimation,
        _bounceAnimation,
      ]),
      builder: (context, child) {
        // Calculate wiggle offset
        final wiggleProgress = _wiggleAnimation.value;
        final wiggleDx = wiggleProgress > 0.0 && wiggleProgress < 1.0
            ? math.sin(wiggleProgress * math.pi * 4) * 8.0 * (1.0 - wiggleProgress)
            : 0.0;

        final totalScale = _breatheAnimation.value * _bounceAnimation.value;

        return Transform.translate(
          offset: Offset(wiggleDx, 0),
          child: Transform.scale(
            scale: totalScale,
            child: child,
          ),
        );
      },
      child: Material(
        color: widget.backgroundColor ?? AppColors.card,
        elevation: 2,
        shadowColor: AppColors.ink.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap != null ? _handleTap : null,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Container(
            padding: widget.padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: widget.borderColor ?? AppColors.orange.withValues(alpha: 0.25),
                width: 2,
              ),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
