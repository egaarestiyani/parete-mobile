import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/services/auth_service.dart';
import '../features/auth/presentation/screens/change_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/home/presentation/screens/home_dashboard_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';

/// Menentukan layar awal: onboarding → login → beranda (sesuai sesi & data warga).
class AppStartGate extends StatelessWidget {
  const AppStartGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    if (!auth.initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!auth.onboardingCompleted) {
      return const OnboardingScreen();
    }

    if (!auth.isLoggedIn) {
      return const LoginScreen();
    }

    if (auth.warga?.harusGantiPassword == true) {
      return const ChangePasswordScreen();
    }

    return const HomeDashboardScreen();
  }
}
