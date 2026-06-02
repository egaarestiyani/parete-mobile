import 'package:flutter/foundation.dart';

class ApiConfig {
  const ApiConfig._();

  /// URL backend Laravel (`php artisan serve`).
  ///
  /// - Windows / iOS simulator: `http://127.0.0.1:8000`
  /// - Android emulator: `http://10.0.2.2:8000`
  /// - HP fisik (Wi‑Fi sama): `http://<IP-Laptop>:8000`
  ///
  /// Override saat run:
  /// `flutter run --dart-define=PARETE_API_URL=http://10.0.2.2:8000`
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('PARETE_API_URL');
    if (fromEnv.isNotEmpty) {
      return fromEnv;
    }
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  static String get apiBase => '$baseUrl/api';
}
