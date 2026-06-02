import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../domain/entities/onboarding_item.dart';
import 'onboarding_illustration.dart';
import 'onboarding_progress_indicator.dart';
import 'onboarding_welcome_branding.dart';

class OnboardingPageContent extends StatelessWidget {
  const OnboardingPageContent({
    required this.item,
    required this.isLast,
    required this.pageIndex,
    required this.pageCount,
    required this.onNext,
    required this.onSkip,
    this.showWelcomeBranding = true,
    super.key,
  });

  final OnboardingItem item;
  final bool isLast;
  final int pageIndex;
  final int pageCount;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final bool showWelcomeBranding;

  @override
  Widget build(BuildContext context) {
    final cardHeight = MediaQuery.sizeOf(context).height * 0.42;

    final isWelcome = item.greeting != null;

    return Column(
      children: [
        Expanded(
          child: isWelcome
              ? (showWelcomeBranding
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: OnboardingWelcomeBranding(
                          greeting: item.greeting!,
                        ),
                      ),
                    )
                  : const SizedBox.shrink())
              : Center(
                  child: OnboardingIllustration(type: item.illustrationType),
                ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
          height: cardHeight.clamp(280, 420),
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: OnboardingProgressIndicator(
                  currentIndex: pageIndex,
                  itemCount: pageCount,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _TagBadge(label: item.tag, showStar: item.showTagStar),
              const SizedBox(height: AppSpacing.md),
              Text(
                item.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: Text(
                  item.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14),
                ),
              ),
              if (isLast)
                PrimaryButton(
                  label: 'Mulai Sekarang',
                  expanded: true,
                  backgroundColor: AppColors.yellow,
                  foregroundColor: AppColors.darkBlueText,
                  onPressed: onNext,
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onSkip,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 52),
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Lewati',
                          style: TextStyle(
                            color: AppColors.mutedText,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: PrimaryButton(
                        label: 'Lanjut',
                        expanded: true,
                        onPressed: onNext,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TagBadge extends StatelessWidget {
  const _TagBadge({required this.label, required this.showStar});

  final String label;
  final bool showStar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.lightBlueBg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        showStar ? '✦ $label' : label,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
