import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/app_assets.dart';
import '../../core/widgets/safe_svg.dart';

enum TeacherMood { idle, curious, retry, celebrate }

enum TeacherCharacter { mimi, jiji }

/// A guided cartoon teacher bar featuring Mimi Cat and Jiji Mouse.
/// Offers idle bobbing, gentle retry reactions, celebratory bounces,
/// Burmese speech bubble guidance, and an audio replay speaker button.
class GuidedTeacherBar extends StatefulWidget {
  const GuidedTeacherBar({
    super.key,
    required this.message,
    this.mood = TeacherMood.idle,
    this.character = TeacherCharacter.mimi,
    this.onReplayAudio,
    this.isPlayingAudio = false,
  });

  final String message;
  final TeacherMood mood;
  final TeacherCharacter character;
  final VoidCallback? onReplayAudio;
  final bool isPlayingAudio;

  @override
  State<GuidedTeacherBar> createState() => _GuidedTeacherBarState();
}

class _GuidedTeacherBarState extends State<GuidedTeacherBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _bobAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _bobAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutSine,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String get _characterSvg {
    switch (widget.mood) {
      case TeacherMood.celebrate:
        return AppAssets.mimiCelebrate;
      case TeacherMood.retry:
        return AppAssets.jijiOops;
      case TeacherMood.curious:
        return AppAssets.jijiCurious;
      case TeacherMood.idle:
        return widget.character == TeacherCharacter.mimi
            ? AppAssets.mimiTeacher
            : AppAssets.jijiCurious;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Animated Character
          AnimatedBuilder(
            animation: _bobAnimation,
            builder: (context, child) {
              double dy = 0.0;
              double dx = 0.0;
              double angle = 0.0;

              if (widget.mood == TeacherMood.celebrate) {
                dy = -10.0 * _bobAnimation.value;
                angle = (math.sin(_bobAnimation.value * math.pi * 2) * 0.06);
              } else if (widget.mood == TeacherMood.retry) {
                dx = math.sin(_bobAnimation.value * math.pi * 4) * 4.0;
              } else {
                dy = -5.0 * _bobAnimation.value;
              }

              return Transform.translate(
                offset: Offset(dx, dy),
                child: Transform.rotate(
                  angle: angle,
                  child: child,
                ),
              );
            },
            child: Semantics(
              label: widget.character == TeacherCharacter.mimi
                  ? 'ဆရာမလေး မီးမီး'
                  : 'ဂျီဂျီလေး',
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.mood == TeacherMood.celebrate
                      ? AppColors.sun.withValues(alpha: 0.3)
                      : widget.mood == TeacherMood.retry
                          ? AppColors.pink.withValues(alpha: 0.4)
                          : AppColors.card,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.ink.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(4),
                child: SafeSvg(
                  _characterSvg,
                  width: 60,
                  height: 60,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Speech Bubble
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border.all(
                  color: widget.mood == TeacherMood.retry
                      ? AppColors.orange
                      : widget.mood == TeacherMood.celebrate
                          ? AppColors.teal
                          : AppColors.orange.withValues(alpha: 0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ink.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        fontFamily: 'NotoSansMyanmar',
                        fontSize: 14.5,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.onReplayAudio != null) ...[
                    const SizedBox(width: 6),
                    Material(
                      color: widget.isPlayingAudio
                          ? AppColors.teal
                          : AppColors.cream,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: widget.onReplayAudio,
                        customBorder: const CircleBorder(),
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: Icon(
                            widget.isPlayingAudio
                                ? Icons.volume_up_rounded
                                : Icons.volume_down_rounded,
                            size: 26,
                            color: widget.isPlayingAudio
                                ? Colors.white
                                : AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
