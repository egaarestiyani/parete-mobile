import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _tokenKey = 'parete_api_token';
  static const _idKeluargaKey = 'parete_id_keluarga';

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

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_idKeluargaKey);
  }
}
