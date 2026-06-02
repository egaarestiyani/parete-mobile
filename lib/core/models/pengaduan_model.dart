import '../utils/api_date.dart';

enum ComplaintStatusUi { terkirim, diterima, diproses, selesai, ditolak, dibatalkan }

class PengaduanModel {
  const PengaduanModel({
    required this.id,
    required this.nomorPengaduan,
    required this.judul,
    required this.topik,
    required this.lokasi,
    required this.deskripsi,
    required this.status,
    required this.tanggalDibuat,
    this.catatanSelesai,
    this.alasanDitolak,
    this.canEdit = false,
    this.canBatalkan = false,
  });

  final String id;
  final String nomorPengaduan;
  final String judul;
  final String topik;
  final String lokasi;
  final String deskripsi;
  final ComplaintStatusUi status;
  final DateTime? tanggalDibuat;
  final String? catatanSelesai;
  final String? alasanDitolak;
  final bool canEdit;
  final bool canBatalkan;

  bool get isActive =>
      status == ComplaintStatusUi.terkirim ||
      status == ComplaintStatusUi.diterima ||
      status == ComplaintStatusUi.diproses;

  factory PengaduanModel.fromJson(Map<String, dynamic> json) {
    return PengaduanModel(
      id: json['id']?.toString() ?? '',
      nomorPengaduan: json['nomor_pengaduan']?.toString() ?? '',
      judul: json['judul_pengaduan']?.toString() ?? '',
      topik: json['topik']?.toString() ?? '',
      lokasi: json['lokasi_kejadian']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? '',
      status: _mapStatus(json['status_pengaduan']?.toString() ?? ''),
      tanggalDibuat: ApiDate.parse(json['tanggal_dibuat']),
      catatanSelesai: json['catatan_selesai']?.toString(),
      alasanDitolak: json['alasan_ditolak']?.toString(),
      canEdit: json['can_edit'] == true,
      canBatalkan: json['can_batalkan'] == true,
    );
  }

  static ComplaintStatusUi _mapStatus(String raw) {
    return switch (raw) {
      'Terkirim' => ComplaintStatusUi.terkirim,
      'Diterima' => ComplaintStatusUi.diterima,
      'Diproses' => ComplaintStatusUi.diproses,
      'Selesai' => ComplaintStatusUi.selesai,
      'Ditolak' => ComplaintStatusUi.ditolak,
      'Dibatalkan' => ComplaintStatusUi.dibatalkan,
      _ => ComplaintStatusUi.terkirim,
    };
  }
}

/// Statistik pengaduan — logika sama dengan tab di [ComplaintsListScreen].
class PengaduanStats {
  const PengaduanStats({
    required this.total,
    required this.aktif,
    required this.selesai,
  });

  final int total;
  final int aktif;
  final int selesai;

  factory PengaduanStats.fromList(List<PengaduanModel> all) {
    return PengaduanStats(
      total: all.length,
      aktif: all.where((e) => e.isActive).length,
      selesai: all
          .where(
            (e) =>
                e.status == ComplaintStatusUi.selesai ||
                e.status == ComplaintStatusUi.ditolak ||
                e.status == ComplaintStatusUi.dibatalkan,
          )
          .length,
    );
  }
}
