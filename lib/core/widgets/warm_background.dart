import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class WarmBackground extends StatelessWidget {
  const WarmBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFF8EE),
            Color(0xFFFFF1DF),
            Color(0xFFFFE9D2),
          ],
        ),
      ),
      child: child,
    );
  }
}

class OfflineBadge extends StatelessWidget {
  const OfflineBadge({super.key, this.dark = false});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final color = dark ? Colors.white : AppColors.teal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: dark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            '၁၀၀% အော့ဖ်လိုင်း',
            style: TextStyle(
              fontFamily: 'NotoSansMyanmar',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
