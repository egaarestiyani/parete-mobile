enum OnboardingIllustrationType {
  welcome,
  complaints,
  documents,
  rocket,
}

class OnboardingItem {
  const OnboardingItem({
    required this.tag,
    required this.title,
    required this.description,
    required this.illustrationType,
    this.greeting,
    this.showTagStar = false,
  });

  final String tag;
  final String title;
  final String description;
  final OnboardingIllustrationType illustrationType;
  final String? greeting;
  final bool showTagStar;
}
