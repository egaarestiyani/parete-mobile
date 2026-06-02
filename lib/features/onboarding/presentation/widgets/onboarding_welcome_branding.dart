import 'package:flutter/material.dart';

import '../../../shared/widgets/parete_logo.dart';

/// Logo + sapaan + tagline (dipakai di intro & halaman onboarding pertama).
class OnboardingWelcomeBranding extends StatelessWidget {
  const OnboardingWelcomeBranding({
    required this.greeting,
    this.logoLightness = 1,
    this.logoScale = 1,
    this.logoOpacity = 1,
    this.greetingOpacity = 1,
    this.subtitleOpacity = 1,
    super.key,
  });

  final String greeting;

  /// 0 = logo gelap, 1 = logo putih (animasi splash).
  final double logoLightness;
  final double logoScale;
  final double logoOpacity;
  final double greetingOpacity;
  final double subtitleOpacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: logoOpacity.clamp(0, 1),
      child: Transform.scale(
        scale: logoScale.clamp(0.5, 1.2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PareteLogoCrossfade(
              lightness: logoLightness.clamp(0, 1),
              height: 52,
            ),
            const SizedBox(height: 12),
            Opacity(
              opacity: greetingOpacity.clamp(0, 1),
              child: Text(
                greeting,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 6),
            Opacity(
              opacity: subtitleOpacity.clamp(0, 1),
              child: Text(
                'Sistem Pelayanan & Informasi RT Digital',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.92),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
