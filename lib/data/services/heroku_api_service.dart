import 'package:dio/dio.dart';
import 'package:herokudroid/core/constants/api_constants.dart';
import 'package:herokudroid/core/errors/heroku_exception.dart';
import 'package:herokudroid/data/services/secure_storage_service.dart';

/// HTTP client service for Heroku Platform API
class HerokuApiService {
  late final Dio _dio;
  final SecureStorageService _storage;

  HerokuApiService(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          'Accept': ApiConstants.acceptHeader,
          'Content-Type': ApiConstants.contentTypeHeader,
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_authInterceptor());
    _dio.interceptors.add(_errorInterceptor());

    // Add logging interceptor in debug mode
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
        logPrint: (object) => print('[HTTP] $object'),
      ),
    );
  }

  /// Interceptor to add authentication token to requests
  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final token = await _storage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (e) {
          // Continue without token if storage fails
          print('[Auth Interceptor] Failed to get token: $e');
        }
        handler.next(options);
      },
    );
  }

  /// Interceptor to handle errors globally
  InterceptorsWrapper _errorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        // Convert DioException to HerokuException
        final herokuError = HerokuException.fromDioException(error);
        handler.reject(
          DioException(
            requestOptions: error.requestOptions,
            response: error.response,
            type: error.type,
            error: herokuError,
          ),
        );
      },
    );
  }

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle and convert DioException to HerokuException
  HerokuException _handleError(DioException error) {
    if (error.error is HerokuException) {
      return error.error as HerokuException;
    }
    return HerokuException.fromDioException(error);
  }

  /// Update authentication token
  Future<void> setToken(String token) async {
    await _storage.saveToken(token);
  }

  /// Clear authentication token
  Future<void> clearToken() async {
    await _storage.deleteToken();
  }

  /// Test API connection with current token
  Future<bool> testConnection() async {
    try {
      final response = await get(
        ApiConstants.apps,
        queryParameters: {'limit': '1'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
