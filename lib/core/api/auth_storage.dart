import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _tokenKey = 'parete_api_token';
  static const _idKeluargaKey = 'parete_id_keluarga';
  static const _onboardingDoneKey = 'parete_onboarding_done';
  static const _passwordReadyPrefix = 'parete_pwd_siap_';

  String _passwordReadyKey(String idKeluarga) =>
      '$_passwordReadyPrefix${idKeluarga.trim().toUpperCase()}';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveIdKeluarga(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_idKeluargaKey, id);
  }

  Future<String?> getIdKeluarga() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_idKeluargaKey);
  }

  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingDoneKey) ?? false;
  }

  Future<void> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingDoneKey, true);
  }

  /// Setelah warga berhasil ganti password (atau login dengan sandi baru).
  Future<void> markPasswordReady(String idKeluarga) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_passwordReadyKey(idKeluarga), true);
  }

  Future<bool> isPasswordReady(String idKeluarga) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_passwordReadyKey(idKeluarga)) ?? false;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_idKeluargaKey);
  }
}
