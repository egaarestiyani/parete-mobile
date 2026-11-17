import 'package:dio/dio.dart';

import '../config/api_config.dart';

class ApiClient {
  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.apiBase,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Accept': 'application/json'},
      ),
    );
  }

  late final Dio _dio;
  String? _token;

  Dio get dio => _dio;

  void setToken(String? token) {
    _token = token;
  }

  Options _withAuth([Options? options]) {
    final merged = options ?? Options();
    final headers = Map<String, dynamic>.from(merged.headers ?? {});
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return merged.copyWith(headers: headers);
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: _withAuth(options),
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Options? options,
  }) {
    return _dio.post<T>(path, data: data, options: _withAuth(options));
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Options? options,
  }) {
    return _dio.put<T>(path, data: data, options: _withAuth(options));
  }

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Options? options,
  }) {
    return _dio.patch<T>(path, data: data, options: _withAuth(options));
  }

  Future<Response<List<int>>> download(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get<List<int>>(
      path,
      queryParameters: queryParameters,
      options: _withAuth(Options(responseType: ResponseType.bytes)),
    );
  }

  String messageFromError(DioException error) {
    // Log mentah ke Debug Console (Android Studio / VS Code / `flutter run`)
    // agar statusCode + body terlihat saat UI hanya menampilkan pesan singkat.
    // ignore: avoid_print
    print('[API ERROR] ${error.toString()}');
    // ignore: avoid_print
    print('[API ERROR] type=${error.type}');
    // ignore: avoid_print
    print('[API ERROR] statusCode=${error.response?.statusCode}');
    // ignore: avoid_print
    print('[API ERROR] body=${error.response?.data}');
    // ignore: avoid_print
    print('[API ERROR] uri=${error.requestOptions.uri}');

    final data = error.response?.data;
    if (data is Map) {
      final message = data['message'];
      final code = data['error_code'];
      if (message is String && message.isNotEmpty) {
        if (code is String && code.isNotEmpty) {
          return '$message [$code]';
        }
        return message;
      }
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) {
          return first.first.toString();
        }
      }
    }
    if (error.type == DioExceptionType.connectionError) {
      return 'Tidak dapat terhubung ke server. Pastikan backend Laravel berjalan di ${ApiConfig.baseUrl}.';
    }
    final status = error.response?.statusCode;
    if (status != null) {
      return 'Terjadi kesalahan (HTTP $status). Coba lagi.';
    }
    return 'Terjadi kesalahan. Coba lagi. (${error.type})';
  }
}
