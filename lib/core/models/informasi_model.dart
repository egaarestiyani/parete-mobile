enum InformasiJenis { pengumuman, kegiatan }

class InformasiModel {
  const InformasiModel({
    required this.id,
    required this.jenis,
    required this.judul,
    required this.isi,
    required this.tanggalPublikasi,
    this.penulis,
  });

  final String id;
  final InformasiJenis jenis;
  final String judul;
  final String isi;
  final DateTime? tanggalPublikasi;
  final String? penulis;

  factory InformasiModel.fromJson(Map<String, dynamic> json) {
    final jenisRaw = json['jenis_informasi']?.toString() ?? 'pengumuman';
    return InformasiModel(
      id: json['id']?.toString() ?? '',
      jenis: jenisRaw == 'kegiatan' ? InformasiJenis.kegiatan : InformasiJenis.pengumuman,
      judul: json['judul_informasi']?.toString() ?? '',
      isi: json['isi_informasi']?.toString() ?? '',
      tanggalPublikasi: DateTime.tryParse(json['tanggal_publikasi']?.toString() ?? ''),
      penulis: json['penulis']?.toString(),
    );
  }
}
