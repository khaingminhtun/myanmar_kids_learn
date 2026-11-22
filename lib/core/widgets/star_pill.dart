import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Warm star counter used on the home screen and inside lesson results.
class StarPill extends StatelessWidget {
  const StarPill({
    super.key,
    required this.stars,
    this.label,
    this.compact = false,
  });

  final int stars;
  final String? label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 16,
        vertical: compact ? 6 : 9,
      ),
      decoration: BoxDecoration(
        color: AppColors.sun.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.sun.withValues(alpha: 0.75)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            color: AppColors.orangeDeep,
            size: compact ? 20 : 26,
          ),
          const SizedBox(width: 6),
          Text(
            '$stars',
            style: TextStyle(
              fontFamily: 'NotoSansMyanmar',
              fontSize: compact ? 17 : 21,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          if (label != null) ...[
            const SizedBox(width: 6),
            Text(
              label!,
              style: TextStyle(
                fontFamily: 'NotoSansMyanmar',
                fontSize: compact ? 13 : 15,
                color: AppColors.inkSoft,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
