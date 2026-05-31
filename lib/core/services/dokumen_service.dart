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

  Future<List<int>> downloadBytes(String downloadPath) async {
    final uri = Uri.parse(downloadPath);
    final path = uri.path.replaceFirst(ApiConfig.baseUrl, '');
    final apiPath = path.startsWith('/api') ? path.substring(4) : path;
    try {
      final res = await _api.download(apiPath);
      return res.data ?? [];
    } on DioException catch (e) {
      throw Exception(_api.messageFromError(e));
    }
  }
}
