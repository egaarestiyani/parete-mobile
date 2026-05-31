import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'core/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  await authService.init();
  runApp(
    ChangeNotifierProvider<AuthService>.value(
      value: authService,
      child: const PareteApp(),
    ),
  );
}
