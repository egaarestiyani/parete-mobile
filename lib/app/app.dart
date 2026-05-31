import 'package:flutter/material.dart';

import '../features/auth/presentation/screens/change_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/complaints/presentation/screens/complaints_list_screen.dart';
import '../features/complaints/presentation/screens/create_complaint_screen.dart';
import '../features/documents/presentation/screens/document_submission_screen.dart';
import '../features/documents/presentation/screens/documents_screen.dart';
import '../features/home/presentation/screens/home_dashboard_screen.dart';
import '../features/information/presentation/screens/information_screen.dart';
import '../features/profile/presentation/screens/help_support_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import 'app_theme.dart';

class PareteApp extends StatelessWidget {
  const PareteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Parete App',
      theme: AppTheme.lightTheme,
      initialRoute: OnboardingScreen.routeName,
      routes: {
        OnboardingScreen.routeName: (_) => const OnboardingScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        ChangePasswordScreen.routeName: (_) => const ChangePasswordScreen(),
        HomeDashboardScreen.routeName: (_) => const HomeDashboardScreen(),
        ComplaintsListScreen.routeName: (_) => const ComplaintsListScreen(),
        CreateComplaintScreen.routeName: (_) => const CreateComplaintScreen(),
        DocumentsScreen.routeName: (_) => const DocumentsScreen(),
        DocumentSubmissionScreen.routeName: (_) => const DocumentSubmissionScreen(),
        InformationScreen.routeName: (_) => const InformationScreen(),
        ProfileScreen.routeName: (_) => const ProfileScreen(),
        HelpSupportScreen.routeName: (_) => const HelpSupportScreen(),
      },
    );
  }
}
