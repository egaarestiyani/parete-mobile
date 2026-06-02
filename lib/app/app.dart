import 'package:flutter/material.dart';

import '../core/models/informasi_model.dart';
import '../core/models/pengaduan_model.dart';
import '../core/models/permohonan_model.dart';
import '../features/auth/presentation/screens/change_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/complaints/presentation/screens/complaints_list_screen.dart';
import '../features/complaints/presentation/screens/create_complaint_screen.dart';
import '../features/documents/presentation/screens/document_submission_screen.dart';
import '../features/documents/presentation/screens/documents_screen.dart';
import '../features/documents/presentation/screens/permohonan_list_screen.dart';
import '../features/home/presentation/screens/home_dashboard_screen.dart';
import '../features/information/presentation/screens/informasi_detail_screen.dart';
import '../features/information/presentation/screens/information_screen.dart';
import '../features/profile/presentation/screens/help_support_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/search/presentation/screens/search_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import 'app_start_gate.dart';
import 'app_theme.dart';

class PareteApp extends StatelessWidget {
  const PareteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Parete App',
      theme: AppTheme.lightTheme,
      home: const AppStartGate(),
      routes: {
        OnboardingScreen.routeName: (_) => const OnboardingScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        ChangePasswordScreen.routeName: (_) => const ChangePasswordScreen(),
        HomeDashboardScreen.routeName: (_) => const HomeDashboardScreen(),
        SearchScreen.routeName: (_) => const SearchScreen(),
        ComplaintsListScreen.routeName: (_) => const ComplaintsListScreen(),
        CreateComplaintScreen.routeName: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return CreateComplaintScreen(
            edit: args is PengaduanModel ? args : null,
          );
        },
        DocumentsScreen.routeName: (_) => const DocumentsScreen(),
        DocumentSubmissionScreen.routeName: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return DocumentSubmissionScreen(
            edit: args is PermohonanModel ? args : null,
          );
        },
        PermohonanListScreen.routeName: (_) => const PermohonanListScreen(),
        InformationScreen.routeName: (_) => const InformationScreen(),
        InformasiDetailScreen.routeName: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return InformasiDetailScreen(
            initial: args is InformasiModel ? args : null,
          );
        },
        ProfileScreen.routeName: (_) => const ProfileScreen(),
        HelpSupportScreen.routeName: (_) => const HelpSupportScreen(),
      },
    );
  }
}
