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
    final data = error.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    if (error.type == DioExceptionType.connectionError) {
      return 'Tidak dapat terhubung ke server. Pastikan backend Laravel berjalan.';
    }
    return 'Terjadi kesalahan. Coba lagi.';
  }
}
