enum ComplaintStatusUi { terkirim, diterima, diproses, selesai, ditolak }

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
      tanggalDibuat: DateTime.tryParse(json['tanggal_dibuat']?.toString() ?? ''),
      catatanSelesai: json['catatan_selesai']?.toString(),
      alasanDitolak: json['alasan_ditolak']?.toString(),
    );
  }

  static ComplaintStatusUi _mapStatus(String raw) {
    return switch (raw) {
      'Terkirim' => ComplaintStatusUi.terkirim,
      'Diterima' => ComplaintStatusUi.diterima,
      'Diproses' => ComplaintStatusUi.diproses,
      'Selesai' => ComplaintStatusUi.selesai,
      'Ditolak' => ComplaintStatusUi.ditolak,
      _ => ComplaintStatusUi.terkirim,
    };
  }
}
