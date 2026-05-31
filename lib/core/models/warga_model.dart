class WargaModel {
  const WargaModel({
    required this.id,
    required this.idKeluarga,
    required this.namaKepalaKeluarga,
    required this.nomorRumah,
    required this.alamatLengkap,
    required this.nomorHp,
    required this.statusAkun,
    required this.harusGantiPassword,
  });

  final String id;
  final String idKeluarga;
  final String namaKepalaKeluarga;
  final String nomorRumah;
  final String alamatLengkap;
  final String nomorHp;
  final String statusAkun;
  final bool harusGantiPassword;

  factory WargaModel.fromJson(Map<String, dynamic> json) {
    return WargaModel(
      id: json['id']?.toString() ?? '',
      idKeluarga: json['id_keluarga']?.toString() ?? '',
      namaKepalaKeluarga: json['nama_kepala_keluarga']?.toString() ?? '',
      nomorRumah: json['nomor_rumah']?.toString() ?? '',
      alamatLengkap: json['alamat_lengkap']?.toString() ?? '',
      nomorHp: json['nomor_hp']?.toString() ?? '',
      statusAkun: json['status_akun']?.toString() ?? '',
      harusGantiPassword: json['harus_ganti_password'] == true,
    );
  }
}
