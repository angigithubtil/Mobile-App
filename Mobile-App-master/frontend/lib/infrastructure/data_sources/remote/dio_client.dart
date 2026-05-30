import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../config/app_config.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  late final Dio dio;

  DioClient._internal() {
    String baseUrl = AppConfig.apiBaseUrl;
    if (kIsWeb) {
      baseUrl = baseUrl.replaceAll('10.0.2.2', 'localhost');
    }

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 3200),
        receiveTimeout: const Duration(seconds: 3200),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add error handling
    dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException e, ErrorInterceptorHandler handler) {
        if (e.type == DioExceptionType.connectionError) {
          print('Connection error: Please check if the server is running at $baseUrl');
        }
        return handler.next(e);
      },
    ));
  }
} 
