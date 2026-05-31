import 'package:flutter/material.dart';

class OnboardingBackground extends StatelessWidget {
  const OnboardingBackground({
    this.showBlobs = true,
    this.blobOpacity = 1,
    super.key,
  });

  final bool showBlobs;
  final double blobOpacity;

  static const gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF2990DE), Color(0xFF5CAFEA)],
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: gradient),
      child: showBlobs
          ? Stack(
              children: [
                Positioned(
                  top: -90,
                  right: -70,
                  child: Opacity(
                    opacity: blobOpacity * 0.35,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF7EC4F0),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 120,
                  left: -80,
                  child: Opacity(
                    opacity: blobOpacity * 0.28,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF7EC4F0),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : null,
    );
  }
}
