import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../data/onboarding_dummy_data.dart';
import '../widgets/onboarding_page_content.dart';
import '../widgets/onboarding_progress_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const String routeName = '/';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    final lastIndex = OnboardingDummyData.items.length - 1;
    if (_currentIndex == lastIndex) {
      Navigator.pushReplacementNamed(context, LoginScreen.routeName);
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLast = _currentIndex == OnboardingDummyData.items.length - 1;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2990DE), Color(0xFF5CAFEA)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: OnboardingDummyData.items.length,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  return OnboardingPageContent(
                    item: OnboardingDummyData.items[index],
                    isLast: index == OnboardingDummyData.items.length - 1,
                  );
                },
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 130,
                child: OnboardingProgressIndicator(
                  currentIndex: _currentIndex,
                  itemCount: OnboardingDummyData.items.length,
                ),
              ),
              Positioned(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: AppSpacing.xl,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!isLast)
                      OutlinedButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, LoginScreen.routeName),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(110, 52),
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Lewati'),
                      ),
                    if (!isLast) const SizedBox(width: AppSpacing.md),
                    PrimaryButton(
                      label: isLast ? 'Mulai Sekarang' : 'Lanjut',
                      backgroundColor: isLast ? AppColors.yellow : AppColors.primaryBlue,
                      foregroundColor: isLast ? AppColors.darkBlueText : AppColors.white,
                      onPressed: _onNext,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
