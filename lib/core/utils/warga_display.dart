/// Label tampilan dari data warga (sinkron dengan web admin).
class WargaDisplay {
  WargaDisplay._();

  static String rtLabel(String idKeluarga) {
    final match = RegExp(r'^RT(\d{2})', caseSensitive: false).firstMatch(idKeluarga.trim());
    if (match != null) {
      final num = int.tryParse(match.group(1) ?? '');
      if (num != null) return 'RT. $num';
    }
    return 'RT';
  }

  static String nomorRumahLabel(String nomorRumah) {
    final n = nomorRumah.trim();
    if (n.isEmpty || n == '-') return 'No. —';
    return 'No. $n';
  }
}
