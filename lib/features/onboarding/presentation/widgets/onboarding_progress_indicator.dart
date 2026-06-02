import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class OnboardingProgressIndicator extends StatelessWidget {
  const OnboardingProgressIndicator({
    required this.currentIndex,
    required this.itemCount,
    super.key,
  });

  final int currentIndex;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        final bool active = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppColors.yellow : AppColors.progressInactive,
            borderRadius: BorderRadius.circular(100),
          ),
        );
      }),
    );
  }
}
