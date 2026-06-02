class DokumenModel {
  const DokumenModel({
    required this.id,
    required this.nama,
    required this.tipe,
    required this.kategori,
    required this.ukuranByte,
    required this.downloadPath,
    this.sudahDiunduh = false,
  });

  final String id;
  final String nama;
  final String tipe;
  final String kategori;
  final int ukuranByte;
  final String downloadPath;
  final bool sudahDiunduh;

  String get ukuranLabel {
    if (ukuranByte < 1024) return '$ukuranByte B';
    if (ukuranByte < 1024 * 1024) {
      return '${(ukuranByte / 1024).toStringAsFixed(0)} KB';
    }
    return '${(ukuranByte / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  factory DokumenModel.fromJson(Map<String, dynamic> json) {
    return DokumenModel(
      id: json['id']?.toString() ?? '',
      nama: json['nama_dokumen']?.toString() ?? '',
      tipe: json['tipe_berkas']?.toString() ?? 'pdf',
      kategori: json['kategori']?.toString() ?? '',
      ukuranByte: int.tryParse(json['ukuran_byte']?.toString() ?? '') ?? 0,
      downloadPath: json['download_url']?.toString() ?? '',
      sudahDiunduh: json['sudah_diunduh'] == true,
    );
  }

  String get fileName {
    final safe = nama.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    return '$safe.$tipe';
  }
}

class DokumenStats {
  const DokumenStats({
    required this.total,
    required this.baruBulanIni,
    required this.totalUnduhan,
  });

  final int total;
  final int baruBulanIni;
  final int totalUnduhan;

  factory DokumenStats.fromJson(Map<String, dynamic> json) {
    return DokumenStats(
      total: int.tryParse(json['total']?.toString() ?? '') ?? 0,
      baruBulanIni: int.tryParse(json['baru_bulan_ini']?.toString() ?? '') ?? 0,
      totalUnduhan: int.tryParse(json['total_unduhan']?.toString() ?? '') ?? 0,
    );
  }
}
