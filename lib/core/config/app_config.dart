/// Konfigurasi fitur aplikasi.
class AppConfig {
  const AppConfig._();

  /// Set `true` untuk login API sungguhan. `false` = halaman login tetap ada,
  /// tombol Masuk bisa diklik tanpa mengisi ID/password (akun demo).
  static const bool authEnabled = true;
}
