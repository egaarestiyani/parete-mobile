import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Latar biru gradien + gelembung halus (selaras tampilan web).
class PareteBubbleBackground extends StatelessWidget {
  const PareteBubbleBackground({
    this.child,
    this.blobOpacity = 1,
    super.key,
  });

  final Widget? child;
  final double blobOpacity;

  static const gradient = AppColors.primaryGradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: gradient),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ..._bubbles(blobOpacity),
          ?child,
        ],
      ),
    );
  }

  List<Widget> _bubbles(double opacity) {
    Widget bubble({
      required double size,
      required Alignment alignment,
      required double alpha,
    }) {
      return Align(
        alignment: alignment,
        child: Opacity(
          opacity: opacity * alpha,
          child: Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryBlueLight,
            ),
          ),
        ),
      );
    }

    return [
      bubble(size: 200, alignment: const Alignment(1.15, -0.9), alpha: 0.28),
      bubble(size: 160, alignment: const Alignment(-1.1, 0.7), alpha: 0.22),
    ];
  }
}
