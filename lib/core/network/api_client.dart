import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../error/failure.dart';

/// Kiểu dữ liệu JSON object mà mọi endpoint trả về.
typedef JsonMap = Map<String, dynamic>;

/// Lớp gọi HTTP duy nhất của app.
///
/// Mọi lỗi được chuyển thành [Failure] ngay tại đây, nên tầng repository trở lên
/// không bao giờ thấy `DioException`.
class ApiClient {
  ApiClient({Dio? dio}) : _dio = dio ?? _createDio();

  final Dio _dio;

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.requestTimeout,
        receiveTimeout: AppConfig.requestTimeout,
        sendTimeout: AppConfig.uploadTimeout,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        // Tự xử lý mã trạng thái trong `_toFailure` để mọi lỗi đi qua một chỗ.
        validateStatus: (status) => status != null && status < 400,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (AppConfig.apiToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer ${AppConfig.apiToken}';
          }
          handler.next(options);
        },
      ),
    );

    // Chỉ log ở debug: log ở bản release sẽ in dữ liệu người dùng ra logcat.
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: false),
      );
    }

    return dio;
  }

  Future<JsonMap> getObject(
    String path, {
    JsonMap? queryParameters,
    CancelToken? cancelToken,
  }) async {
    final data = await _send<dynamic>(
      () => _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      ),
    );
    return _asObject(data);
  }

  Future<List<JsonMap>> getList(
    String path, {
    JsonMap? queryParameters,
    CancelToken? cancelToken,
  }) async {
    final data = await _send<dynamic>(
      () => _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      ),
    );
    return _asList(data);
  }

  Future<JsonMap> post(
    String path, {
    Object? body,
    CancelToken? cancelToken,
  }) async {
    final data = await _send<dynamic>(
      () => _dio.post<dynamic>(path, data: body, cancelToken: cancelToken),
    );
    // Một số endpoint trả 204 không có body — coi như object rỗng.
    return data == null ? const <String, dynamic>{} : _asObject(data);
  }

  Future<JsonMap> delete(String path, {CancelToken? cancelToken}) async {
    final data = await _send<dynamic>(
      () => _dio.delete<dynamic>(path, cancelToken: cancelToken),
    );
    return data == null ? const <String, dynamic>{} : _asObject(data);
  }

  /// Tải một tệp ảnh lên bằng `multipart/form-data`.
  Future<JsonMap> uploadImage(
    String path, {
    required String filePath,
    String fieldName = 'image',
    JsonMap? fields,
    CancelToken? cancelToken,
  }) async {
    final formData = FormData.fromMap({
      ...?fields,
      fieldName: await MultipartFile.fromFile(filePath),
    });

    final data = await _send<dynamic>(
      () => _dio.post<dynamic>(
        path,
        data: formData,
        cancelToken: cancelToken,
        options: Options(sendTimeout: AppConfig.uploadTimeout),
      ),
    );
    return _asObject(data);
  }

  /// Chạy request và chuyển mọi ngoại lệ thành [Failure].
  Future<T?> _send<T>(Future<Response<T>> Function() request) async {
    try {
      final response = await request();
      return response.data;
    } on DioException catch (error) {
      throw _toFailure(error);
    } on SocketException catch (_) {
      throw const NetworkFailure();
    }
  }

  Failure _toFailure(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const TimeoutFailure();
      case DioExceptionType.cancel:
        return const CancelledFailure();
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return const NetworkFailure();
      case DioExceptionType.badCertificate:
        return const NetworkFailure('Kết nối không an toàn.');
      case DioExceptionType.badResponse:
        return _fromStatusCode(error);
    }
  }

  Failure _fromStatusCode(DioException error) {
    final status = error.response?.statusCode ?? 0;
    // Ưu tiên thông điệp do backend trả về: nó cụ thể hơn câu mặc định.
    final serverMessage = _messageFrom(error.response?.data);

    return switch (status) {
      400 || 422 => ValidationFailure(
        serverMessage ?? const ValidationFailure().message,
      ),
      401 || 403 => const UnauthorizedFailure(),
      404 => const NotFoundFailure(),
      429 => const RateLimitFailure(),
      >= 500 => ServerFailure(serverMessage ?? const ServerFailure().message),
      _ => UnknownFailure(serverMessage ?? const UnknownFailure().message),
    };
  }

  /// Đọc `{"message": "..."}` hoặc `{"error": "..."}` từ body lỗi.
  String? _messageFrom(Object? data) {
    if (data is! Map) return null;
    final value = data['message'] ?? data['error'];
    return value is String && value.isNotEmpty ? value : null;
  }

  JsonMap _asObject(Object? data) {
    if (data is JsonMap) return data;
    throw const ParsingFailure('Máy chủ trả về dữ liệu không phải object.');
  }

  List<JsonMap> _asList(Object? data) {
    if (data is List) {
      return data.whereType<JsonMap>().toList(growable: false);
    }
    throw const ParsingFailure('Máy chủ trả về dữ liệu không phải danh sách.');
  }
}
