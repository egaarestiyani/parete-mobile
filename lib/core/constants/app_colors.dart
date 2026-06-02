import 'package:flutter/material.dart';

/// Palet resmi Parete (brand guideline).
class AppColors {
  const AppColors._();

  /// Navy gelap — judul, teks kontras (#1F3A60).
  static const Color darkBlueText = Color(0xFF1F3A60);

  /// Biru medium — tombol primer, header (#3582B8).
  static const Color primaryBlue = Color(0xFF3582B8);

  /// Biru langit — ujung gradien & gelembung (#85B6D6).
  static const Color primaryBlueLight = Color(0xFF85B6D6);

  /// Biru sangat pucat — latar layar & badge (#EDF3F6).
  static const Color lightBlueBg = Color(0xFFEDF3F6);

  /// Kuning/emas — indikator aktif, aksen (#F7CF59).
  static const Color yellow = Color(0xFFF7CF59);

  /// Abu teks sekunder / body.
  static const Color mutedText = Color(0xFF757575);

  static const Color white = Colors.white;
  static const Color border = Color(0xFFDDE3EE);
  static const Color cardShadow = Color(0x26000000);
  static const Color screenBackground = lightBlueBg;
  static const Color inputFill = Color(0xFFE8EEF2);
  static const Color iconMuted = Color(0xFF8C96AB);
  static const Color progressInactive = Color(0xFFD0D4DC);
  static const Color warningBg = Color(0xFFFFF5D9);
  static const Color warningText = Color(0xFF9F8625);
  static const Color green = Color(0xFF33B249);

  /// Gradien latar: #3582B8 → #85B6D6.
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, primaryBlueLight],
  );
}
