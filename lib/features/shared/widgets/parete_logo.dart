import 'package:flutter/material.dart';

enum PareteLogoVariant {
  /// Navy blue text — for light/white backgrounds.
  dark,

  /// White text — for blue/dark backgrounds.
  light,
}

class PareteLogo extends StatelessWidget {
  const PareteLogo({
    this.variant = PareteLogoVariant.dark,
    this.height = 48,
    super.key,
  });

  final PareteLogoVariant variant;
  final double height;

  static const String darkAsset = 'assets/images/logo_dark.png';
  static const String lightAsset = 'assets/images/logo_white.png';

  String get _asset => switch (variant) {
        PareteLogoVariant.dark => darkAsset,
        PareteLogoVariant.light => lightAsset,
      };

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _asset,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      gaplessPlayback: true,
      excludeFromSemantics: true,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
  }
}

/// Crossfades between dark and light logo assets (splash transition).
class PareteLogoCrossfade extends StatelessWidget {
  const PareteLogoCrossfade({
    required this.lightness,
    this.height = 52,
    super.key,
  });

  /// 0 = dark logo fully visible, 1 = light logo fully visible.
  final double lightness;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: (1 - lightness).clamp(0, 1),
            child: PareteLogo(variant: PareteLogoVariant.dark, height: height),
          ),
          Opacity(
            opacity: lightness.clamp(0, 1),
            child: PareteLogo(variant: PareteLogoVariant.light, height: height),
          ),
        ],
      ),
    );
  }
}
