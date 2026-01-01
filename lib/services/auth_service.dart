import 'package:dio/dio.dart';
import '../models/auth_response.dart';
import '../utils/logger.dart';
import 'storage_service.dart';
import 'http_service.dart';

/// 认证服务类
/// 处理用户登录、注册、登出等功能
class AuthService {
  AuthService._();
  static final AuthService _instance = AuthService._();
  static AuthService get instance => _instance;

  /// 使用共享的 Dio 实例
  Dio get dio => HttpService.instance.dio;

  /// 更新 token
  void updateToken(String? token) {
    HttpService.instance.updateToken(token);
  }

  /// 用户注册
  /// [email] 邮箱
  /// [username] 用户名
  /// [password] 密码
  Future<AuthResponse> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/auth/register',
        data: {'email': email, 'username': username, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 确保 response.data 是 Map
        Map<String, dynamic> responseData;
        if (response.data is Map<String, dynamic>) {
          responseData = response.data as Map<String, dynamic>;
        } else if (response.data is Map) {
          responseData = Map<String, dynamic>.from(response.data as Map);
        } else {
          throw Exception('响应数据格式错误: 期望 Map，实际是 ${response.data.runtimeType}');
        }

        final authResponse = AuthResponse.fromJson(responseData);

        // 保存 token
        final token = authResponse.accessToken ?? authResponse.token;
        if (token != null && token.isNotEmpty) {
          await StorageService.instance.saveToken(token);
          updateToken(token); // 更新内存缓存
          Logger.debug(
            '注册成功，token 已保存: ${token.substring(0, token.length > 20 ? 20 : token.length)}...',
            'AuthService',
          );
        } else {
          Logger.warning('注册响应中未找到 token', 'AuthService');
        }

        // 保存用户信息
        if (authResponse.user != null) {
          await StorageService.instance.saveUser(authResponse.user!);
        }

        Logger.info('注册成功: $username', 'AuthService');
        return authResponse;
      } else {
        throw Exception('注册失败: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e, '注册失败');
    } catch (e, stackTrace) {
      Logger.error('注册失败', e, stackTrace, 'AuthService');
      rethrow;
    }
  }

  /// 用户登录
  /// [username] 用户名或邮箱
  /// [password] 密码
  Future<AuthResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        // 添加调试日志
        Logger.debug('登录响应数据: ${response.data}', 'AuthService');

        // 确保 response.data 是 Map
        Map<String, dynamic> responseData;
        if (response.data is Map<String, dynamic>) {
          responseData = response.data as Map<String, dynamic>;
        } else if (response.data is Map) {
          responseData = Map<String, dynamic>.from(response.data as Map);
        } else {
          throw Exception('响应数据格式错误: 期望 Map，实际是 ${response.data.runtimeType}');
        }

        final authResponse = AuthResponse.fromJson(responseData);

        // 保存 token
        final token = authResponse.accessToken ?? authResponse.token;
        if (token != null && token.isNotEmpty) {
          await StorageService.instance.saveToken(token);
          updateToken(token); // 更新内存缓存
          Logger.debug(
            '登录成功，token 已保存: ${token.substring(0, token.length > 20 ? 20 : token.length)}...',
            'AuthService',
          );
        } else {
          Logger.warning('登录响应中未找到 token', 'AuthService');
        }

        // 保存用户信息
        if (authResponse.user != null) {
          await StorageService.instance.saveUser(authResponse.user!);
        }

        Logger.info('登录成功: $username', 'AuthService');
        return authResponse;
      } else {
        throw Exception('登录失败: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e, '登录失败');
    } catch (e, stackTrace) {
      Logger.error('登录失败', e, stackTrace, 'AuthService');
      rethrow;
    }
  }

  /// 获取当前用户信息
  Future<User?> getCurrentUser() async {
    try {
      final response = await dio.get('/user/profile');

      if (response.statusCode == 200) {
        final user = User.fromJson(response.data as Map<String, dynamic>);
        StorageService.instance.saveUser(user);
        return user;
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Token 过期，清除本地存储
        StorageService.instance.clear();
      }
      Logger.error('获取用户信息失败', e, e.stackTrace, 'AuthService');
      return null;
    } catch (e, stackTrace) {
      Logger.error('获取用户信息失败', e, stackTrace, 'AuthService');
      return null;
    }
  }

  /// 用户登出
  Future<void> logout() async {
    try {
      await dio.post('/auth/logout');
    } catch (e) {
      Logger.warning('登出请求失败: $e', 'AuthService');
    } finally {
      // 无论请求是否成功，都清除本地存储和内存缓存
      StorageService.instance.clear();
      updateToken(null); // 清除内存缓存
      Logger.info('已登出', 'AuthService');
    }
  }

  /// 检查是否已登录
  Future<bool> isLoggedIn() async {
    final token = await StorageService.instance.getTokenAsync();
    return token != null && token.isNotEmpty;
  }

  /// 获取当前用户（从本地存储）
  Future<User?> getCurrentUserFromStorage() async {
    return await StorageService.instance.getUserAsync();
  }

  /// 处理 Dio 错误
  Exception _handleDioError(DioException error, String defaultMessage) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        Logger.error('请求超时', error, error.stackTrace, 'AuthService');
        return Exception('请求超时，请检查网络连接');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final errorMessage =
            error.response?.data?['message'] as String? ??
            error.response?.data?['error'] as String?;

        Logger.error(
          '请求失败: $statusCode',
          error,
          error.stackTrace,
          'AuthService',
        );

        if (statusCode == 401) {
          return Exception('用户名或密码错误');
        } else if (statusCode == 403) {
          return Exception('没有权限访问');
        } else if (statusCode == 404) {
          return Exception('接口不存在');
        } else if (statusCode == 409) {
          return Exception(errorMessage ?? '用户已存在');
        } else if (statusCode == 422) {
          return Exception(errorMessage ?? '请求参数错误');
        } else {
          return Exception(errorMessage ?? '请求失败: $statusCode');
        }

      case DioExceptionType.cancel:
        Logger.warning('请求已取消', 'AuthService');
        return Exception('请求已取消');

      case DioExceptionType.connectionError:
        Logger.error('网络连接失败', error, error.stackTrace, 'AuthService');
        return Exception('网络连接失败，请检查网络设置');

      case DioExceptionType.badCertificate:
        Logger.error('证书验证失败', error, error.stackTrace, 'AuthService');
        return Exception('SSL证书验证失败');

      case DioExceptionType.unknown:
        Logger.error(
          defaultMessage,
          error.error,
          error.stackTrace,
          'AuthService',
        );
        final errorMessage = error.message ?? '未知错误';
        if (errorMessage.contains('SocketException') ||
            errorMessage.contains('Connection failed') ||
            errorMessage.contains('Failed host lookup')) {
          return Exception('无法连接到服务器，请检查服务器是否运行');
        }
        return Exception('$defaultMessage: $errorMessage');
    }
  }
}
