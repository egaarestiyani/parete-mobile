class ApiConfig {
  const ApiConfig._();

  /// URL backend Laravel (`php artisan serve --host=0.0.0.0 --port=8000`).
  ///
  /// Default: IP laptop di jaringan lokal (bukan localhost).
  /// Override saat run:
  /// `flutter run --dart-define=PARETE_API_URL=http://192.168.0.142:8000`
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('PARETE_API_URL');
    if (fromEnv.isNotEmpty) {
      return fromEnv;
    }
    return 'http://192.168.0.142:8000';
  }

  /// Base path API: `http://192.168.0.142:8000/api`
  static String get apiBase => '$baseUrl/api';
}
