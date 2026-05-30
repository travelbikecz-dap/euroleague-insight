import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Logos with white/light lettering on transparency — dark pad in light mode.
const _lightBackdropLogos = {
  'assets/logos/lyon.png', // ASVEL
  'assets/logos/barcelona.png',
  'assets/logos/munich.png', // Bayern
};

class TeamLogo extends StatelessWidget {
  final String assetPath;
  final double width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final Widget? errorWidget;

  const TeamLogo({
    super.key,
    required this.assetPath,
    required this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.borderRadius = 8,
    this.errorWidget,
  });

  static bool needsLightBackdrop(String assetPath, Brightness brightness) {
    return brightness == Brightness.light &&
        _lightBackdropLogos.contains(assetPath);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final useBackdrop = needsLightBackdrop(assetPath, brightness);
    final h = height ?? width;

    final image = Image.asset(
      assetPath,
      width: useBackdrop ? width - 8 : width,
      height: useBackdrop ? h - 8 : h,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ??
            Icon(
              Icons.sports_basketball,
              size: width * 0.75,
              color: Theme.of(context).colorScheme.primary,
            );
      },
    );

    if (!useBackdrop) return image;

    return Container(
      width: width,
      height: h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.logoBackdropLight,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: image,
    );
  }
}
