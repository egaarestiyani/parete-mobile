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
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 26 : 10,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppColors.yellow : const Color(0xFFD8D9DD),
            borderRadius: BorderRadius.circular(100),
          ),
        );
      }),
    );
  }
}
