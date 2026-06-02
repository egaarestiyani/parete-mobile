import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

import '../api/api_client.dart';
import '../models/pengaduan_model.dart';

class PengaduanService {
  PengaduanService(this._api);

  final ApiClient _api;

  Future<List<PengaduanModel>> fetch({String? status}) async {
    try {
      final res = await _api.get<Map<String, dynamic>>(
        '/pengaduan',
        queryParameters: status != null ? {'status': status} : null,
      );
      final list = res.data?['data'];
      if (list is! List) return [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(PengaduanModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(_api.messageFromError(e));
    }
  }

  Future<PengaduanModel> create({
    required String topik,
    required String judul,
    required String deskripsi,
    required String lokasi,
    List<PlatformFile> attachments = const [],
  }) async {
    try {
      final formData = FormData.fromMap({
        'topik': topik,
        'judul_pengaduan': judul,
        'deskripsi': deskripsi,
        'lokasi_kejadian': lokasi,
      });

      for (var i = 0; i < attachments.length; i++) {
        final file = attachments[i];
        formData.files.add(await _fileEntry('lampiran[]', file));
      }

      final res = await _api.post<Map<String, dynamic>>(
        '/pengaduan',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final data = res.data?['data'];
      if (data is! Map<String, dynamic>) {
        throw Exception('Gagal membuat pengaduan.');
      }
      return PengaduanModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_api.messageFromError(e));
    }
  }

  Future<PengaduanModel> update({
    required String id,
    required String topik,
    required String judul,
    required String deskripsi,
    required String lokasi,
    List<PlatformFile> attachments = const [],
    bool gantiLampiran = false,
  }) async {
    try {
      final formData = FormData.fromMap({
        'topik': topik,
        'judul_pengaduan': judul,
        'deskripsi': deskripsi,
        'lokasi_kejadian': lokasi,
        if (gantiLampiran) 'ganti_lampiran': '1',
      });

      for (final file in attachments) {
        formData.files.add(await _fileEntry('lampiran[]', file));
      }

      final res = await _api.put<Map<String, dynamic>>(
        '/pengaduan/$id',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final data = res.data?['data'];
      if (data is! Map<String, dynamic>) {
        throw Exception('Gagal memperbarui pengaduan.');
      }
      return PengaduanModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_api.messageFromError(e));
    }
  }

  Future<void> batalkan(String id) async {
    try {
      await _api.post('/pengaduan/$id/batalkan');
    } on DioException catch (e) {
      throw Exception(_api.messageFromError(e));
    }
  }

  Future<MapEntry<String, MultipartFile>> _fileEntry(String key, PlatformFile file) async {
    if (file.bytes != null) {
      return MapEntry(key, MultipartFile.fromBytes(file.bytes!, filename: file.name));
    }
    return MapEntry(key, await MultipartFile.fromFile(file.path!, filename: file.name));
  }
}
