import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/token_storage.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenStorage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // No reintentar en endpoints de autenticación ni multipart
        final isAuthEndpoint =
            error.requestOptions.path.contains('/auth/login') ||
            error.requestOptions.path.contains('/auth/register') ||
            error.requestOptions.path.contains('/auth/refresh');
        final isMultipart = error.requestOptions.data is FormData;

        if (error.response?.statusCode != 401) {
          return handler.next(error);
        }
        if (isAuthEndpoint || isMultipart) {
          return handler.next(error);
        }

        final refreshed = await _refreshToken();
        if (refreshed) {
          final token = await TokenStorage.getAccessToken();
          error.requestOptions.headers['Authorization'] = 'Bearer $token';
          final response = await _dio.fetch(error.requestOptions);
          return handler.resolve(response);
        }
        return handler.next(error);
      },
    ));
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await Dio().post(
        '${ApiConstants.baseUrl}${ApiConstants.refresh}',
        data: {'refresh': refreshToken},
      );

      await TokenStorage.saveTokens(
        access: response.data['access'],
        refresh: response.data['refresh'] ?? refreshToken,
      );
      return true;
    } catch (_) {
      await TokenStorage.clearTokens();
      return false;
    }
  }

  Future<Response> get(String path, {Map<String, dynamic>? params}) async {
    return await _dio.get(path, queryParameters: params);
  }

  Future<Response> post(String path,
      {dynamic data, bool isMultipart = false}) async {
    return await _dio.post(
      path,
      data: data,
      options:
          isMultipart ? Options(contentType: 'multipart/form-data') : null,
    );
  }

  Future<Response> patch(String path, {dynamic data}) async {
    return await _dio.patch(path, data: data);
  }

  Future<Response> delete(String path) async {
  return await _dio.delete(path);
}
}