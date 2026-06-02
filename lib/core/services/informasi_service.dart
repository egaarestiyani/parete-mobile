import 'package:dio/dio.dart';

import '../api/api_client.dart';
import '../models/informasi_model.dart';

class InformasiService {
  InformasiService(this._api);

  final ApiClient _api;

  Future<List<InformasiModel>> fetch({InformasiJenis? jenis}) async {
    try {
      final res = await _api.get<Map<String, dynamic>>(
        '/informasi',
        queryParameters: jenis != null
            ? {
                'jenis': jenis == InformasiJenis.kegiatan ? 'kegiatan' : 'pengumuman',
              }
            : null,
      );
      final list = res.data?['data'];
      if (list is! List) return [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(InformasiModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(_api.messageFromError(e));
    }
  }

  Future<InformasiModel> fetchById(String id) async {
    try {
      final res = await _api.get<Map<String, dynamic>>('/informasi/$id');
      final raw = res.data?['data'] ?? res.data?['informasi'] ?? res.data;
      if (raw is! Map<String, dynamic>) {
        throw Exception('Data informasi tidak valid.');
      }
      return InformasiModel.fromJson(raw);
    } on DioException catch (e) {
      throw Exception(_api.messageFromError(e));
    }
  }
}
