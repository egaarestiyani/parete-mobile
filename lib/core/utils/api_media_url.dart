import '../config/api_config.dart';

/// URL gambar/file dari backend (path disimpan di MongoDB).
///
/// Memakai `GET /api/media/{path}` agar host selalu sama dengan API
/// ([ApiConfig.baseUrl]) — penting untuk Android emulator (`10.0.2.2`) dan HP fisik.
String? resolveApiMediaUrl(String? raw) {
  if (raw == null || raw.isEmpty) return null;

  final diskPath = _normalizeDiskPath(raw.trim().replaceAll('\\', '/'));
  if (diskPath == null || diskPath.isEmpty) return null;

  final segments = diskPath.split('/').where((s) => s.isNotEmpty).map(Uri.encodeComponent);
  final mediaPath = segments.join('/');

  return '${ApiConfig.apiBase}/media/$mediaPath';
}

/// Path relatif di disk `public` (contoh: `informasi_gambar/abc.jpg`).
String? _normalizeDiskPath(String raw) {
  if (raw.startsWith('http://') || raw.startsWith('https://')) {
    final parsed = Uri.parse(raw);
    final path = parsed.path;
    const storagePrefix = '/storage/';
    if (path.contains(storagePrefix)) {
      return path.substring(path.indexOf(storagePrefix) + storagePrefix.length);
    }
    const mediaPrefix = '/api/media/';
    if (path.contains(mediaPrefix)) {
      return Uri.decodeComponent(path.substring(path.indexOf(mediaPrefix) + mediaPrefix.length));
    }
    return path.startsWith('/') ? path.substring(1) : path;
  }

  var path = raw.startsWith('/') ? raw.substring(1) : raw;
  if (path.startsWith('storage/')) {
    path = path.substring('storage/'.length);
  }
  return path;
}
