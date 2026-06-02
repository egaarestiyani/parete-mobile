import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/auth_service.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../home/presentation/screens/home_dashboard_screen.dart';
import '../../data/onboarding_dummy_data.dart';
import '../widgets/onboarding_background.dart';
import '../widgets/onboarding_page_content.dart';
import '../widgets/onboarding_welcome_branding.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const String routeName = '/onboarding';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _introController;
  late final PageController _pageController;

  late final Animation<double> _whiteBg;
  late final Animation<double> _blueBg;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoLightness;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _greetingOpacity;
  late final Animation<double> _subtitleOpacity;
  late final Animation<double> _blobReveal;
  late final Animation<double> _overlayFade;
  late final Animation<double> _pageReveal;

  int _currentIndex = 0;
  bool _introComplete = false;

  static const _introDuration = Duration(milliseconds: 3000);
  static const _welcomeGreeting = 'Halo, Warga!';

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
    _introController = AnimationController(vsync: this, duration: _introDuration);

    final curved = CurvedAnimation(parent: _introController, curve: Curves.easeInOut);

    _whiteBg = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 8),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 12),
      TweenSequenceItem(tween: ConstantTween(0), weight: 80),
    ]).animate(curved);

    _blueBg = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.05, 0.35, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.82, end: 1).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.1, 0.45, curve: Curves.easeOutBack),
      ),
    );

    _logoLightness = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeInOut),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.1, 0.4, curve: Curves.easeOut),
      ),
    );

    _greetingOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.42, 0.62, curve: Curves.easeOut),
      ),
    );

    _subtitleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.48, 0.68, curve: Curves.easeOut),
      ),
    );

    _blobReveal = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.15, 0.4, curve: Curves.easeOut),
    );

    _overlayFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.78, 1, curve: Curves.easeInOut),
      ),
    );

    _pageReveal = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.72, 1, curve: Curves.easeOutCubic),
      ),
    );

    _introController.forward().whenComplete(() {
      if (!mounted) return;
      setState(() => _introComplete = true);
    });
  }

  @override
  void dispose() {
    _introController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    final auth = context.read<AuthService>();
    await auth.completeOnboarding();
    if (!mounted) return;
    if (auth.isLoggedIn) {
      Navigator.pushReplacementNamed(context, HomeDashboardScreen.routeName);
    } else {
      Navigator.pushReplacementNamed(context, LoginScreen.routeName);
    }
  }

  void _onNext() {
    final lastIndex = OnboardingDummyData.items.length - 1;
    if (_currentIndex == lastIndex) {
      _finishOnboarding();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onSkip() {
    _finishOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _introController,
        builder: (context, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              _buildOnboardingPages(),
              if (!_introComplete) _buildIntroOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIntroOverlay() {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: Colors.white.withValues(alpha: _whiteBg.value)),
          Opacity(
            opacity: _blueBg.value,
            child: OnboardingBackground(
              showBlobs: true,
              blobOpacity: _blobReveal.value,
            ),
          ),
          Opacity(
            opacity: _overlayFade.value.clamp(0, 1),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: OnboardingWelcomeBranding(
                  greeting: _welcomeGreeting,
                  logoLightness: _logoLightness.value,
                  logoScale: _logoScale.value,
                  logoOpacity: _logoOpacity.value,
                  greetingOpacity: _greetingOpacity.value,
                  subtitleOpacity: _subtitleOpacity.value,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPages() {
    final items = OnboardingDummyData.items;
    final pageOpacity = _introComplete ? 1.0 : _pageReveal.value;

    return Opacity(
      opacity: pageOpacity.clamp(0, 1),
      child: Transform.translate(
        offset: Offset(0, _introComplete ? 0 : (1 - _pageReveal.value) * 20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const OnboardingBackground(showBlobs: true),
            SafeArea(
              bottom: false,
              child: PageView.builder(
                controller: _pageController,
                physics: _introComplete
                    ? const BouncingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  return _AnimatedOnboardingPage(
                    index: index,
                    pageController: _pageController,
                    child: OnboardingPageContent(
                      item: items[index],
                      isLast: index == items.length - 1,
                      pageIndex: index,
                      pageCount: items.length,
                      onNext: _onNext,
                      onSkip: _onSkip,
                      showWelcomeBranding: _introComplete || _pageReveal.value > 0.5,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedOnboardingPage extends StatelessWidget {
  const _AnimatedOnboardingPage({
    required this.index,
    required this.pageController,
    required this.child,
  });

  final int index;
  final PageController pageController;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pageController,
      builder: (context, child) {
        final page = pageController.hasClients
            ? (pageController.page ?? index.toDouble())
            : index.toDouble();
        final delta = (page - index).abs().clamp(0.0, 1.0);

        return Opacity(
          opacity: 1 - delta * 0.35,
          child: Transform.translate(
            offset: Offset(0, delta * 24),
            child: Transform.scale(
              scale: 1 - delta * 0.04,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}
