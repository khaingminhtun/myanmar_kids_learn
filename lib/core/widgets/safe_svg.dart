import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';

/// SVG renderer with a friendly fallback, so a missing illustration can never
/// break a screen.
class SafeSvg extends StatelessWidget {
  const SafeSvg(
    this.assetPath, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.semanticsLabel,
  });

  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      semanticsLabel: semanticsLabel,
      placeholderBuilder: (context) => _fallback(loading: true),
      errorBuilder: (context, error, stackTrace) => _fallback(),
    );
  }

  Widget _fallback({bool loading = false}) {
    return SizedBox(
      width: width,
      height: height,
      child: Center(
        child: loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : const Icon(
                Icons.pets_rounded,
                size: 40,
                color: AppColors.orange,
              ),
      ),
    );
  }
}
