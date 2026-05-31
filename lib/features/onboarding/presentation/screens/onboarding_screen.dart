import 'package:flutter/material.dart';

import '../../../auth/presentation/screens/login_screen.dart';
import '../../../home/presentation/screens/home_dashboard_screen.dart';
import '../../../../core/config/app_config.dart';
import '../../data/onboarding_dummy_data.dart';
import '../../../shared/widgets/parete_logo.dart';
import '../widgets/onboarding_background.dart';
import '../widgets/onboarding_page_content.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const String routeName = '/';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _introController;
  late final PageController _pageController;

  late final Animation<double> _whiteBg;
  late final Animation<double> _blueBg;
  late final Animation<double> _logoLightness;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoExit;
  late final Animation<double> _blobReveal;
  late final Animation<double> _welcomeReveal;

  int _currentIndex = 0;
  bool _introComplete = false;

  static const _introDuration = Duration(milliseconds: 4200);

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
    _introController = AnimationController(vsync: this, duration: _introDuration);

    _whiteBg = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 12),
      TweenSequenceItem(tween: ConstantTween(1), weight: 18),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 18),
      TweenSequenceItem(tween: ConstantTween(0), weight: 52),
    ]).animate(CurvedAnimation(parent: _introController, curve: Curves.easeInOut));

    _blueBg = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1), weight: 55),
    ]).animate(CurvedAnimation(parent: _introController, curve: Curves.easeInOut));

    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.75, end: 1)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 18,
      ),
      TweenSequenceItem(tween: ConstantTween(1), weight: 52),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0.85)
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 30,
      ),
    ]).animate(_introController);

    _logoLightness = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(0), weight: 30),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 1).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 18,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1), weight: 52),
    ]).animate(_introController);

    _logoExit = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(0), weight: 58),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 1).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 42,
      ),
    ]).animate(_introController);

    _blobReveal = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.38, 0.58, curve: Curves.easeOut),
    );

    _welcomeReveal = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.58, 1, curve: Curves.easeOutCubic),
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

  void _finishOnboarding() {
    final destination = AppConfig.authEnabled
        ? LoginScreen.routeName
        : HomeDashboardScreen.routeName;
    Navigator.pushReplacementNamed(context, destination);
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
    final showWelcome = _welcomeReveal.value > 0;
    final logoYOffset = -_logoExit.value * 120;
    final logoOpacity = (1 - _logoExit.value).clamp(0.0, 1.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        if (!showWelcome) ...[
          ColoredBox(color: Colors.white.withValues(alpha: _whiteBg.value)),
          Opacity(
            opacity: _blueBg.value,
            child: OnboardingBackground(
              showBlobs: true,
              blobOpacity: _blobReveal.value,
            ),
          ),
        ],
        if (logoOpacity > 0)
          IgnorePointer(
            child: Center(
              child: Transform.translate(
                offset: Offset(0, logoYOffset),
                child: Opacity(
                  opacity: logoOpacity,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: PareteLogoCrossfade(
                      lightness: _logoLightness.value,
                      height: 52,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOnboardingPages() {
    final items = OnboardingDummyData.items;
    final welcomeOpacity = _introComplete ? 1.0 : _welcomeReveal.value;

    return Opacity(
      opacity: welcomeOpacity.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, _introComplete ? 0 : (1 - _welcomeReveal.value) * 36),
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
