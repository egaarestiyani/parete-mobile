import 'package:dio/dio.dart';

import '../api/api_client.dart';
import '../config/api_config.dart';
import '../models/dokumen_model.dart';

class DokumenService {
  DokumenService(this._api);

  final ApiClient _api;

  Future<({List<DokumenModel> docs, DokumenStats stats})> fetch({String? kategori}) async {
    try {
      final res = await _api.get<Map<String, dynamic>>(
        '/dokumen',
        queryParameters: kategori != null ? {'kategori': kategori.toLowerCase()} : null,
      );
      final list = res.data?['data'];
      final statsJson = res.data?['stats'];
      final docs = list is List
          ? list.whereType<Map<String, dynamic>>().map(DokumenModel.fromJson).toList()
          : <DokumenModel>[];
      final stats = statsJson is Map<String, dynamic>
          ? DokumenStats.fromJson(statsJson)
          : const DokumenStats(total: 0, baruBulanIni: 0, totalUnduhan: 0);
      return (docs: docs, stats: stats);
    } on DioException catch (e) {
      throw Exception(_api.messageFromError(e));
    }
  }

  /// Unduh lewat API (mencatat statistik warga di MongoDB).
  Future<List<int>> downloadById(String dokumenId) async {
    try {
      final res = await _api.download('/dokumen/$dokumenId/unduh');
      return res.data ?? [];
    } on DioException catch (e) {
      throw Exception(_api.messageFromError(e));
    }
  }

  @Deprecated('Gunakan downloadById agar unduhan tercatat')
  Future<List<int>> downloadBytes(String downloadPath) async {
    final uri = Uri.parse(downloadPath);
    var path = uri.path;
    if (path.startsWith('http')) {
      final apiBase = Uri.parse(ApiConfig.apiBase);
      final idx = path.indexOf(apiBase.path);
      if (idx >= 0) {
        path = path.substring(idx + apiBase.path.length);
      }
    }
    final apiPath = path.startsWith('/') ? path : '/$path';
    try {
      final res = await _api.download(apiPath);
      return res.data ?? [];
    } on DioException catch (e) {
      throw Exception(_api.messageFromError(e));
    }
  }
}
