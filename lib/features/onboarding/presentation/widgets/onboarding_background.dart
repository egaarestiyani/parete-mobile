import 'package:flutter/material.dart';

import '../../../shared/widgets/parete_bubble_background.dart';

class OnboardingBackground extends StatelessWidget {
  const OnboardingBackground({
    this.showBlobs = true,
    this.blobOpacity = 1,
    super.key,
  });

  final bool showBlobs;
  final double blobOpacity;

  static const gradient = PareteBubbleBackground.gradient;

  @override
  Widget build(BuildContext context) {
    if (!showBlobs) {
      return const DecoratedBox(
        decoration: BoxDecoration(gradient: gradient),
      );
    }
    return PareteBubbleBackground(blobOpacity: blobOpacity);
  }
}
