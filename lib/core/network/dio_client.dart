import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../storage/local_storage.dart';
import 'api_exception.dart';

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(localStorageProvider);
  return DioClient(storage).dio;
});

class DioClient {
  DioClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = _storage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              final opts = error.requestOptions;
              opts.headers['Authorization'] = 'Bearer ${_storage.getAccessToken()}';
              try {
                final response = await _dio.fetch(opts);
                return handler.resolve(response);
              } catch (_) {}
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  final LocalStorage _storage;
  late final Dio _dio;
  Dio get dio => _dio;

  Future<bool> _refreshToken() async {
    final refresh = _storage.getRefreshToken();
    if (refresh == null) return false;
    try {
      final response = await _dio.post(
        ApiConstants.refresh,
        data: {'refresh_token': refresh},
        options: Options(headers: {'Authorization': null}),
      );
      final access = response.data['access_token'] as String?;
      final newRefresh = response.data['refresh_token'] as String?;
      if (access != null) {
        await _storage.saveTokens(access: access, refresh: newRefresh ?? refresh);
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? query}) async {
    try {
      return await _dio.get<T>(path, queryParameters: query);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Response<T>> post<T>(String path, {dynamic data}) async {
    try {
      return await _dio.post<T>(path, data: data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  ApiException _mapError(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    String message = e.message ?? 'Network error';
    if (data is Map && data['message'] != null) {
      message = data['message'].toString();
    }
    return ApiException(message: message, statusCode: status, originalError: e);
  }
}
