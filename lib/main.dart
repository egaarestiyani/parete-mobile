import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'core/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  final authService = AuthService();
  await authService.init();
  runApp(
    ChangeNotifierProvider<AuthService>.value(
      value: authService,
      child: const PareteApp(),
    ),
  );
}
