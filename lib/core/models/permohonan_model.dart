import '../utils/api_date.dart';

class PermohonanModel {
  const PermohonanModel({
    required this.id,
    required this.jenisDokumen,
    this.jenisDokumenLainnya,
    required this.jenisDokumenDisplay,
    required this.keperluan,
    this.catatanTambahan,
    required this.mintaTandaTangan,
    required this.mintaTandaTanganLabel,
    required this.status,
    this.catatanRt,
    this.alasanDitolak,
    this.tanggalDibuat,
    this.tanggalDijawab,
    required this.suratBalasanTersedia,
    required this.suratTtdTersedia,
    this.downloadSuratBalasanUrl,
    this.downloadSuratTtdUrl,
    this.canEdit = false,
    this.canBatalkan = false,
  });

  final String id;
  final String jenisDokumen;
  final String? jenisDokumenLainnya;
  final String jenisDokumenDisplay;
  final String keperluan;
  final String? catatanTambahan;
  final String mintaTandaTangan;
  final String mintaTandaTanganLabel;
  final String status;
  final String? catatanRt;
  final String? alasanDitolak;
  final DateTime? tanggalDibuat;
  final DateTime? tanggalDijawab;
  final bool suratBalasanTersedia;
  final bool suratTtdTersedia;
  final String? downloadSuratBalasanUrl;
  final String? downloadSuratTtdUrl;
  final bool canEdit;
  final bool canBatalkan;

  bool get isSelesai => status == 'Selesai';
  bool get isDitolak => status == 'Ditolak';
  bool get isDibatalkan => status == 'Dibatalkan';
  bool get isTerkirim => status == 'Terkirim';
  bool get mintaDenganTtd => mintaTandaTangan == 'dengan_ttd';

  factory PermohonanModel.fromJson(Map<String, dynamic> json) {
    return PermohonanModel(
      id: json['id']?.toString() ?? '',
      jenisDokumen: json['jenis_dokumen']?.toString() ?? '',
      jenisDokumenLainnya: json['jenis_dokumen_lainnya']?.toString(),
      jenisDokumenDisplay: json['jenis_dokumen_display']?.toString() ?? '',
      keperluan: json['keperluan']?.toString() ?? '',
      catatanTambahan: json['catatan_tambahan']?.toString(),
      mintaTandaTangan: json['minta_tanda_tangan']?.toString() ?? 'tanpa_ttd',
      mintaTandaTanganLabel: json['minta_tanda_tangan_label']?.toString() ?? '',
      status: json['status_permohonan']?.toString() ?? 'Terkirim',
      catatanRt: json['catatan_rt']?.toString(),
      alasanDitolak: json['alasan_ditolak']?.toString(),
      tanggalDibuat: ApiDate.parse(json['tanggal_dibuat']),
      tanggalDijawab: ApiDate.parse(json['tanggal_dijawab']),
      suratBalasanTersedia: json['surat_balasan_tersedia'] == true,
      suratTtdTersedia: json['surat_ttd_tersedia'] == true,
      downloadSuratBalasanUrl: json['download_surat_balasan_url']?.toString(),
      downloadSuratTtdUrl: json['download_surat_ttd_url']?.toString(),
      canEdit: json['can_edit'] == true,
      canBatalkan: json['can_batalkan'] == true,
    );
  }
}
