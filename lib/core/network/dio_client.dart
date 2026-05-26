import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/env_config.dart';
import '../constants/api_constants.dart';
import '../storage/local_storage.dart';
import 'api_exception.dart';
import 'api_response.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(ref.watch(localStorageProvider));
});

/// Back-compat: raw [Dio] instance for callers that need it directly.
final dioProvider = Provider<Dio>((ref) => ref.watch(dioClientProvider).dio);

class DioClient {
  DioClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (o) => debugPrint(o.toString()),
        ),
      );
    }
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.headers['Authorization'] == null &&
              options.headers.containsKey('Authorization')) {
            options.headers.remove('Authorization');
            handler.next(options);
            return;
          }
          final token = _storage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 && !_isAuthPath(error.requestOptions.path)) {
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

  bool _isAuthPath(String path) {
    return path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/refresh');
  }

  Future<bool> _refreshToken() async {
    final refresh = _storage.getRefreshToken();
    if (refresh == null) return false;
    try {
      final response = await _dio.post(
        ApiConstants.authRefresh,
        data: {'refresh_token': refresh},
        options: Options(headers: {'Authorization': null}),
      );
      final data = ApiResponse.unwrap(response.data);
      final map = ApiResponse.asMap(data);
      final access = map['access_token'] as String?;
      final newRefresh = map['refresh_token'] as String? ?? refresh;
      if (access != null) {
        await _storage.saveTokens(access: access, refresh: newRefresh);
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(path, queryParameters: query, options: options);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(path, data: data, options: options);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(path, data: data, options: options);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(path, data: data, options: options);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Response<T>> postFormData<T>(String path, FormData data) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        options: Options(contentType: 'multipart/form-data'),
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  ApiException _mapError(DioException e) {
    final status = e.response?.statusCode;
    final body = e.response?.data;
    var message = e.message ?? 'Network error';

    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      final underlying = e.error?.toString() ?? '';
      if (underlying.contains('Failed host lookup') ||
          underlying.contains('SocketException') ||
          message.contains('Failed host lookup')) {
        message =
            'Cannot reach the API server (${EnvConfig.apiBaseUrl}). '
            'On Android emulator: open Chrome and check internet, then cold-boot the AVD. '
            'For local backend use: --dart-define=API_BASE_URL=http://10.0.2.2:3000/v1';
      }
    }

    if (body is Map) {
      if (body['message'] != null) {
        message = body['message'].toString();
      } else if (body['error'] is Map && body['error']['message'] != null) {
        message = body['error']['message'].toString();
      } else if (body['errors'] is List && (body['errors'] as List).isNotEmpty) {
        final first = (body['errors'] as List).first;
        if (first is Map && first['message'] != null) {
          message = first['message'].toString();
        }
      }
    }

    return ApiException(message: message, statusCode: status, originalError: e);
  }
}
