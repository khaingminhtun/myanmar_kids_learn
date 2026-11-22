import 'package:flutter/material.dart';

import 'app_assets.dart';

/// A bundled animal avatar. No photo, email or account is ever required.
class AvatarOption {
  const AvatarOption({
    required this.id,
    required this.label,
    required this.assetPath,
    required this.color,
  });

  final String id;
  final String label;
  final String assetPath;
  final Color color;
}

abstract final class AvatarCatalog {
  static const List<AvatarOption> all = [
    AvatarOption(
      id: 'elephant',
      label: 'ဆင်',
      assetPath: '${AppAssets.avatarDirectory}/elephant.svg',
      color: Color(0xFF7FC8F8),
    ),
    AvatarOption(
      id: 'owl',
      label: 'ဇီးကွက်',
      assetPath: '${AppAssets.avatarDirectory}/owl.svg',
      color: Color(0xFFB99AF2),
    ),
    AvatarOption(
      id: 'rabbit',
      label: 'ယုန်',
      assetPath: '${AppAssets.avatarDirectory}/rabbit.svg',
      color: Color(0xFFFFB6D0),
    ),
    AvatarOption(
      id: 'tiger',
      label: 'ကျား',
      assetPath: '${AppAssets.avatarDirectory}/tiger.svg',
      color: Color(0xFFFFC95C),
    ),
    AvatarOption(
      id: 'turtle',
      label: 'လိပ်',
      assetPath: '${AppAssets.avatarDirectory}/turtle.svg',
      color: Color(0xFF8FE3AE),
    ),
    AvatarOption(
      id: 'cat',
      label: 'ကြောင်',
      assetPath: '${AppAssets.avatarDirectory}/cat.svg',
      color: Color(0xFFFFD97D),
    ),
  ];

  static AvatarOption byId(String? id) {
    for (final avatar in all) {
      if (avatar.id == id) return avatar;
    }
    return all.first;
  }

  static String labelFor(String? id) => byId(id).label;
}
