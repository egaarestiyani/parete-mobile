import 'package:flutter/material.dart';

import '../../../app/main_tab_navigation.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import 'parete_segment_tabs.dart';

/// Header gradien biru + sudut bawah membulat (konsisten di Pengaduan, Informasi, Dokumen).
class PareteTabbedPageHeader extends StatelessWidget {
  const PareteTabbedPageHeader({
    required this.title,
    required this.tabLabels,
    required this.tabIndex,
    required this.onTabChanged,
    this.actions,
    super.key,
  });

  static const double bottomRadius = 28;

  final String title;
  final List<String> tabLabels;
  final int tabIndex;
  final ValueChanged<int> onTabChanged;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(bottomRadius)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xs,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg + 4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 44,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => MainTabNavigation.go(context, 0),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                      tooltip: 'Kembali ke beranda',
                    ),
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    if (actions != null && actions!.isNotEmpty)
                      Row(mainAxisSize: MainAxisSize.min, children: actions!)
                    else
                      const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              PareteSegmentTabs(
                labels: tabLabels,
                index: tabIndex,
                onChanged: onTabChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Header gradien untuk halaman tanpa tab (mis. Profil).
class PareteProfilePageHeader extends StatelessWidget {
  const PareteProfilePageHeader({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(PareteTabbedPageHeader.bottomRadius),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xs,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg + 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => MainTabNavigation.go(context, 0),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  tooltip: 'Kembali ke beranda',
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
