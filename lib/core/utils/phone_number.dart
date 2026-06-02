/// Format nomor HP Indonesia (+62) — selaras dengan backend [PhoneNumber].
class PhoneNumberUtil {
  PhoneNumberUtil._();

  static const String countryCode = '+62';

  /// Normalisasi ke bentuk penyimpanan: +6281234567890
  static String? normalizeFull(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;

    var local = digits;
    if (local.startsWith('62')) {
      local = local.substring(2);
    } else if (local.startsWith('0')) {
      local = local.substring(1);
    }
    if (local.isEmpty) return null;

    return '$countryCode$local';
  }

  /// Bagian nomor setelah +62 (untuk field input).
  static String localPartFromStored(String? stored) {
    if (stored == null || stored.trim().isEmpty || stored == '-') {
      return '';
    }
    final full = normalizeFull(stored);
    if (full == null || !full.startsWith(countryCode)) return '';
    return full.substring(countryCode.length);
  }

  /// Tampilan di profil / daftar: +62 812 9149 7170
  static String formatDisplay(String? stored) {
    if (stored == null || stored.trim().isEmpty || stored == '-') {
      return '-';
    }
    final full = normalizeFull(stored);
    if (full == null) return '-';

    final local = full.substring(countryCode.length);
    if (local.length <= 4) return full;

    final buffer = StringBuffer('$countryCode ');
    for (var i = 0; i < local.length; i += 4) {
      final end = (i + 4 > local.length) ? local.length : i + 4;
      if (i > 0) buffer.write(' ');
      buffer.write(local.substring(i, end));
    }
    return buffer.toString();
  }
}
