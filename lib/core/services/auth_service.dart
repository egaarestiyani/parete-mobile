import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../api/auth_storage.dart';
import '../config/app_config.dart';
import '../models/warga_model.dart';

class AuthService extends ChangeNotifier {
  AuthService({
    ApiClient? apiClient,
    AuthStorage? storage,
  })  : _api = apiClient ?? ApiClient(),
        _storage = storage ?? AuthStorage();

  final ApiClient _api;
  final AuthStorage _storage;

  WargaModel? _warga;
  bool _initialized = false;
  bool _loading = false;

  static const WargaModel _guestWarga = WargaModel(
    id: 'guest',
    idKeluarga: 'RT05-2026-001',
    namaKepalaKeluarga: 'Warga Demo',
    nomorRumah: '1',
    alamatLengkap: 'RT 05 Malabar Ujung',
    nomorHp: '-',
    statusAkun: 'Aktif',
    harusGantiPassword: false,
  );

  WargaModel? get warga => _warga;
  bool get isLoggedIn => _warga != null;
  bool get initialized => _initialized;
  bool get loading => _loading;
  bool get authEnabled => AppConfig.authEnabled;
  ApiClient get api => _api;

  Future<String?> currentToken() => _storage.getToken();

  Future<void> init() async {
    if (!AppConfig.authEnabled) {
      _warga = _guestWarga;
      _initialized = true;
      notifyListeners();
      return;
    }

    final token = await _storage.getToken();
    if (token == null) {
      _initialized = true;
      notifyListeners();
      return;
    }
    _api.setToken(token);
    try {
      final res = await _api.get<Map<String, dynamic>>('/auth/me');
      final data = res.data?['warga'];
      if (data is Map<String, dynamic>) {
        _warga = WargaModel.fromJson(data);
      }
    } on DioException {
      await _storage.clear();
      _api.setToken(null);
    }
    _initialized = true;
    notifyListeners();
  }

  Future<WargaModel> login({
    required String idKeluarga,
    required String password,
  }) async {
    if (!AppConfig.authEnabled) {
      _warga = _guestWarga;
      notifyListeners();
      return _warga!;
    }

    _loading = true;
    notifyListeners();
    try {
      final res = await _api.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'id_keluarga': idKeluarga.trim(),
          'password': password,
        },
      );
      final token = res.data?['token']?.toString();
      final wargaJson = res.data?['warga'];
      if (token == null || wargaJson is! Map<String, dynamic>) {
        throw Exception('Respons login tidak valid.');
      }
      await _storage.saveToken(token);
      await _storage.saveIdKeluarga(idKeluarga.trim());
      _api.setToken(token);
      _warga = WargaModel.fromJson(wargaJson);
      if (res.data?['harus_ganti_password'] == true) {
        _warga = WargaModel(
          id: _warga!.id,
          idKeluarga: _warga!.idKeluarga,
          namaKepalaKeluarga: _warga!.namaKepalaKeluarga,
          nomorRumah: _warga!.nomorRumah,
          alamatLengkap: _warga!.alamatLengkap,
          nomorHp: _warga!.nomorHp,
          statusAkun: _warga!.statusAkun,
          harusGantiPassword: true,
        );
      }
      return _warga!;
    } on DioException catch (e) {
      throw Exception(_api.messageFromError(e));
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> changePassword({
    required String passwordBaru,
    String? nomorHp,
  }) async {
    if (!AppConfig.authEnabled) return;

    try {
      final res = await _api.post<Map<String, dynamic>>(
        '/auth/change-password',
        data: {
          'password_baru': passwordBaru,
          'password_baru_confirmation': passwordBaru,
          if (nomorHp != null && nomorHp.isNotEmpty) 'nomor_hp': nomorHp,
        },
      );
      final wargaJson = res.data?['warga'];
      if (wargaJson is Map<String, dynamic>) {
        _warga = WargaModel.fromJson(wargaJson);
        notifyListeners();
      }
    } on DioException catch (e) {
      throw Exception(_api.messageFromError(e));
    }
  }

  Future<void> logout() async {
    if (!AppConfig.authEnabled) {
      _warga = _guestWarga;
      notifyListeners();
      return;
    }

    try {
      await _api.post('/auth/logout');
    } catch (_) {}
    await _storage.clear();
    _api.setToken(null);
    _warga = null;
    notifyListeners();
  }
}
