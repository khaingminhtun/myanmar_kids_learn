import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/avatar_catalog.dart';
import 'safe_svg.dart';

class AvatarBadge extends StatelessWidget {
  const AvatarBadge({
    super.key,
    required this.avatarId,
    this.size = 72,
    this.selected = false,
    this.showBackground = true,
  });

  final String avatarId;
  final double size;
  final bool selected;
  final bool showBackground;

  @override
  Widget build(BuildContext context) {
    final avatar = AvatarCatalog.byId(avatarId);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.1),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: showBackground
            ? avatar.color.withValues(alpha: 0.34)
            : Colors.transparent,
        border: Border.all(
          color: selected ? AppColors.orangeDeep : Colors.white,
          width: selected ? 4 : 3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.09),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SafeSvg(
        avatar.assetPath,
        semanticsLabel: '${avatar.label} ပုံ',
      ),
    );
  }
}
