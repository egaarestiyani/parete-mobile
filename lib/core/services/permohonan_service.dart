import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

import '../api/api_client.dart';

class PermohonanService {
  PermohonanService(this._api);

  final ApiClient _api;

  Future<void> submit({
    required String jenisDokumen,
    String? jenisLainnya,
    required String keperluan,
    String? catatan,
    PlatformFile? berkasDiisi,
    PlatformFile? dokumenPendukung,
  }) async {
    try {
      final formData = FormData.fromMap({
        'jenis_dokumen': jenisDokumen,
        if (jenisLainnya != null && jenisLainnya.isNotEmpty) 'jenis_dokumen_lainnya': jenisLainnya,
        'keperluan': keperluan,
        if (catatan != null && catatan.isNotEmpty) 'catatan_tambahan': catatan,
      });

      if (berkasDiisi != null) {
        formData.files.add(await _fileEntry('berkas_diisi', berkasDiisi));
      }
      if (dokumenPendukung != null) {
        formData.files.add(await _fileEntry('dokumen_pendukung', dokumenPendukung));
      }

      await _api.post(
        '/permohonan-dokumen',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
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
