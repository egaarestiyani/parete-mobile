import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/onboarding_item.dart';

class OnboardingIllustration extends StatelessWidget {
  const OnboardingIllustration({
    required this.type,
    super.key,
  });

  final OnboardingIllustrationType type;

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      OnboardingIllustrationType.welcome => const _WelcomeIllustration(),
      OnboardingIllustrationType.complaints => const _ComplaintsIllustration(),
      OnboardingIllustrationType.documents => const _DocumentsIllustration(),
      OnboardingIllustrationType.rocket => const _RocketIllustration(),
    };
  }
}

class _WelcomeIllustration extends StatelessWidget {
  const _WelcomeIllustration();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Text('👋', style: TextStyle(fontSize: 64)),
      ),
    );
  }
}

class _ComplaintsIllustration extends StatelessWidget {
  const _ComplaintsIllustration();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          const Text('✏️', style: TextStyle(fontSize: 72)),
          Positioned(
            top: 64,
            left: 0,
            right: 0,
            child: Column(
              children: [
                _FloatingCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '#ADU-011',
                            style: TextStyle(
                              color: AppColors.mutedText.withValues(alpha: 0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          _StatusChip(label: 'Selesai', color: AppColors.green),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Kebisingan di Malam Hari',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppColors.darkBlueText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Keamanan · 1 Feb 2024 · Gang Melati',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.mutedText.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: const Offset(16, -8),
                  child: _FloatingCard(
                    opacity: 0.92,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '#ADU-031',
                                style: TextStyle(
                                  color: AppColors.mutedText.withValues(alpha: 0.8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Lampu Jalan Gang Mawar Mati',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: AppColors.darkBlueText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Infrastruktur',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.mutedText.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _StatusChip(label: 'Diproses', color: AppColors.primaryBlue),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentsIllustration extends StatelessWidget {
  const _DocumentsIllustration();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          const Text('📣', style: TextStyle(fontSize: 72)),
          Positioned(
            top: 58,
            left: 0,
            right: 0,
            child: Column(
              children: [
                _FileCard(
                  icon: '📊',
                  iconBg: const Color(0xFFE8F5E9),
                  title: 'Data Warga RT 05',
                  subtitle: 'XLS · 245 KB',
                ),
                const SizedBox(height: 8),
                _FileCard(
                  icon: '📄',
                  iconBg: const Color(0xFFFFEBEE),
                  title: 'Formulir Surat Keterangan Domisili',
                  subtitle: 'PDF · 186 KB',
                ),
                const SizedBox(height: 8),
                _FloatingCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Mengunduh...',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: AppColors.darkBlueText,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '68%',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.mutedText.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: LinearProgressIndicator(
                          value: 0.68,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFE8EDF5),
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '186 KB / 245 KB · Estimasi 2 detik',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.mutedText.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RocketIllustration extends StatelessWidget {
  const _RocketIllustration();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            const Text('🚀', style: TextStyle(fontSize: 88)),
            Positioned(
              bottom: -8,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _FlameDot(color: const Color(0xFFFF9800)),
                  const SizedBox(width: 4),
                  _FlameDot(color: const Color(0xFFFFC107)),
                  const SizedBox(width: 4),
                  _FlameDot(color: const Color(0xFFFF5722)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FlameDot extends StatelessWidget {
  const _FlameDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}

class _FloatingCard extends StatelessWidget {
  const _FloatingCard({
    required this.child,
    this.opacity = 1,
  });

  final Widget child;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _FileCard extends StatelessWidget {
  const _FileCard({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
  });

  final String icon;
  final Color iconBg;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return _FloatingCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(icon, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.darkBlueText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.mutedText.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.download_rounded, size: 20, color: AppColors.primaryBlue.withValues(alpha: 0.8)),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
