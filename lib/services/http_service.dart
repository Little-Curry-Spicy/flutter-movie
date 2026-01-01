import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../utils/logger.dart';
import 'storage_service.dart';

/// HTTP 服务类
/// 提供共享的 Dio 实例，供所有服务使用
class HttpService {
  HttpService._();
  static final HttpService _instance = HttpService._();
  static HttpService get instance => _instance;

  Dio? _dio;
  String? _cachedToken; // 内存缓存的 token

  /// 获取共享的 Dio 实例
  Dio get dio {
    _dio ??= _createDio();
    return _dio!;
  }

  /// 初始化 token（从本地存储加载）
  Future<void> initToken() async {
    _cachedToken = await StorageService.instance.getTokenAsync();
    if (_cachedToken != null && _cachedToken!.isNotEmpty) {
      Logger.info(
        'HttpService token 已加载: ${_cachedToken!.substring(0, _cachedToken!.length > 20 ? 20 : _cachedToken!.length)}...',
        'HttpService',
      );
    } else {
      Logger.warning('HttpService 未找到保存的 token', 'HttpService');
    }
  }

  /// 更新 token
  void updateToken(String? token) {
    _cachedToken = token;
    Logger.info(
      token != null
          ? 'HttpService token 已更新: ${token.substring(0, token.length > 20 ? 20 : token.length)}...'
          : 'HttpService token 已清除',
      'HttpService',
    );
  }

  /// 创建并配置 Dio 客户端
  Dio _createDio() {
    final baseUrl = AppConfig.localApiBaseUrl;
    Logger.info('创建共享 Dio 实例，baseUrl: $baseUrl', 'HttpService');

    final dioInstance = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(seconds: AppConfig.requestTimeout),
        receiveTimeout: Duration(seconds: AppConfig.requestTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 添加请求拦截器（用于日志记录和自动添加 token）
    dioInstance.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 优先使用内存缓存的 token，如果没有则从本地存储获取
          String? token = _cachedToken;
          if (token == null || token.isEmpty) {
            token = await StorageService.instance.getTokenAsync();
            if (token != null && token.isNotEmpty) {
              _cachedToken = token; // 更新内存缓存
            }
          }

          // 添加 token 到请求头
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            Logger.warning('未找到 token，请求将不带 Authorization 头', 'HttpService');
          }

          Logger.debug('请求url:${options.uri},请求参数: ${options.queryParameters}', 'HttpService');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (error, handler) {
          Logger.error(
            '请求失败: ${error.requestOptions.method} ${error.requestOptions.uri}',
            error.error,
            error.stackTrace,
            'HttpService',
          );
          if (error.response != null) {
            Logger.error(
              '响应状态: ${error.response?.statusCode}',
              error.response?.data,
              null,
              'HttpService',
            );
          }
          return handler.next(error);
        },
      ),
    );

    return dioInstance;
  }

  /// 重置 Dio 实例（用于调试或配置更改后）
  void resetDio() {
    _dio = null;
    Logger.info('共享 Dio 实例已重置', 'HttpService');
  }
}
