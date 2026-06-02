import '../utils/api_date.dart';
import '../utils/api_media_url.dart';

enum InformasiJenis { pengumuman, kegiatan }

class InformasiModel {
  const InformasiModel({
    required this.id,
    required this.jenis,
    required this.judul,
    required this.isi,
    required this.tanggalPublikasi,
    this.penulis,
    this.gambarUrl,
    this.tanggalKegiatan,
  });

  final String id;
  final InformasiJenis jenis;
  final String judul;
  final String isi;
  final DateTime? tanggalPublikasi;
  final String? penulis;
  final String? gambarUrl;
  final DateTime? tanggalKegiatan;

  bool get hasGambar => gambarUrl != null && gambarUrl!.isNotEmpty;

  String get ringkasan {
    final text = isi.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (text.length <= 120) return text;
    return '${text.substring(0, 117)}...';
  }

  factory InformasiModel.fromJson(Map<String, dynamic> json) {
    final jenisRaw = json['jenis_informasi']?.toString() ?? 'pengumuman';
    return InformasiModel(
      id: json['id']?.toString() ?? '',
      jenis: jenisRaw == 'kegiatan' ? InformasiJenis.kegiatan : InformasiJenis.pengumuman,
      judul: json['judul_informasi']?.toString() ?? '',
      isi: json['isi_informasi']?.toString() ?? '',
      tanggalPublikasi: ApiDate.parse(json['tanggal_publikasi']),
      penulis: json['penulis']?.toString(),
      gambarUrl: _parseGambarUrl(json),
      tanggalKegiatan: ApiDate.parse(json['tanggal_kegiatan']),
    );
  }

  static String? _parseGambarUrl(Map<String, dynamic> json) {
    final raw = json['gambar_informasi']?.toString();
    if (raw != null && raw.isNotEmpty) {
      return resolveApiMediaUrl(raw);
    }
    return null;
  }
}
