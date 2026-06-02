import 'package:flutter/material.dart';

import '../../domain/entities/onboarding_item.dart';

/// Emoji mengambang di area biru atas (bukan bagian kartu putih).
class OnboardingIllustration extends StatelessWidget {
  const OnboardingIllustration({
    required this.type,
    super.key,
  });

  final OnboardingIllustrationType type;

  static const double _emojiSize = 88;

  @override
  Widget build(BuildContext context) {
    final emoji = switch (type) {
      OnboardingIllustrationType.welcome => null,
      OnboardingIllustrationType.complaints => '✏️',
      OnboardingIllustrationType.documents => '📋',
      OnboardingIllustrationType.rocket => '🚀',
    };

    if (emoji == null) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Text(
        emoji,
        style: const TextStyle(fontSize: _emojiSize, height: 1.1),
      ),
    );
  }
}
