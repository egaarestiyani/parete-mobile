import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

/// Nama rute tab utama — harus konsisten dengan `routeName` di masing-masing layar.
abstract class AppRouteNames {
  static const String home = '/home';
  static const String information = '/information';
  static const String complaints = '/complaints';
  static const String documents = '/documents';
  static const String profile = '/profile';
}

/// Navigasi konsisten untuk bottom bar di seluruh aplikasi.
class MainTabNavigation {
  MainTabNavigation._();

  static void go(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRouteNames.home,
          (route) => false,
        );
        return;
      case 1:
        _pushIfNotCurrent(context, AppRouteNames.information);
        return;
      case 2:
        _pushIfNotCurrent(context, AppRouteNames.complaints);
        return;
      case 3:
        _pushIfNotCurrent(context, AppRouteNames.documents);
        return;
      case 4:
        _pushIfNotCurrent(context, AppRouteNames.profile);
        return;
      default:
        return;
    }
  }

  static void _pushIfNotCurrent(BuildContext context, String routeName) {
    if (ModalRoute.of(context)?.settings.name == routeName) return;
    Navigator.of(context).pushNamed(routeName);
  }
}

/// Bottom navigation pill seperti di beranda / pengaduan / dokumen.
class MainBottomNavBar extends StatelessWidget {
  const MainBottomNavBar({
    super.key,
    required this.selectedIndex,
    this.onWillNavigate,
  });

  /// 0 Beranda, 1 Informasi, 2 Pengaduan, 3 Dokumen, 4 Profil
  final int selectedIndex;

  /// Dipanggil sebelum navigasi (mis. memperbarui highlight di beranda).
  final ValueChanged<int>? onWillNavigate;

  @override
  Widget build(BuildContext context) {
    final items = <IconData>[
      Icons.home_rounded,
      Icons.calendar_month_outlined,
      Icons.edit_note_outlined,
      Icons.description_outlined,
      Icons.person_outline_rounded,
    ];

    return Material(
      elevation: 12,
      shadowColor: AppColors.cardShadow,
      borderRadius: BorderRadius.circular(28),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (i) {
            final selected = i == selectedIndex;
            return InkWell(
              onTap: () {
                onWillNavigate?.call(i);
                MainTabNavigation.go(context, i);
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Icon(
                  items[i],
                  size: 26,
                  color: selected ? AppColors.primaryBlue : const Color(0xFF9AA3B5),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
