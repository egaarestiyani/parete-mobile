import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/onboarding_item.dart';

class OnboardingPageContent extends StatelessWidget {
  const OnboardingPageContent({
    required this.item,
    required this.isLast,
    super.key,
  });

  final OnboardingItem item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final illustrationSize = size.width * 0.28;

    return Column(
      children: [
        SizedBox(height: size.height * 0.12),
        Container(
          width: illustrationSize,
          height: illustrationSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: Text(item.emoji, style: TextStyle(fontSize: illustrationSize * 0.54)),
        ),
        const Spacer(),
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F5FF),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  item.tag,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(item.title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(item.description, style: Theme.of(context).textTheme.bodyLarge),
              if (isLast) ...[
                const SizedBox(height: AppSpacing.xl),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
