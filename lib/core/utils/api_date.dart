import 'package:intl/intl.dart';

/// Parsing & format tanggal dari API (zona WIB / perangkat lokal).
class ApiDate {
  ApiDate._();

  static DateTime? parse(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty) return null;
    final dt = DateTime.tryParse(text);
    if (dt == null) return null;
    return dt.toLocal();
  }

  static String format(
    DateTime? dateTime, {
    String pattern = 'd MMM yyyy, HH:mm',
  }) {
    if (dateTime == null) return '-';
    return DateFormat(pattern, 'id_ID').format(dateTime.toLocal());
  }

  static String formatDate(DateTime? dateTime) =>
      format(dateTime, pattern: 'd MMM yyyy');
}
