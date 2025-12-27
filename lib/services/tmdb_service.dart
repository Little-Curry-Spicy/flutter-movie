import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/genre.dart';
import '../models/movie_detail.dart';
import '../models/movie_response.dart';
import '../utils/logger.dart';

/// TMDb API服务类
/// 使用 Dio 进行网络请求，提供更好的错误处理和拦截器支持
class TmdbService {
  // 私有构造函数，实现单例模式
  TmdbService._();

  // 单例实例
  static final TmdbService _instance = TmdbService._();
  static TmdbService get instance => _instance;

  // Dio 实例（懒加载初始化）
  Dio? _dio;

  /// 获取 Dio 实例（懒加载）
  Dio get dio {
    _dio ??= _createDio();
    return _dio!;
  }

  /// 创建并配置 Dio 客户端
  Dio _createDio() {
    final dioInstance = Dio(
      BaseOptions(
        baseUrl: AppConfig.tmdbApiBaseUrl,
        connectTimeout: Duration(seconds: AppConfig.requestTimeout),
        receiveTimeout: Duration(seconds: AppConfig.requestTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 添加请求拦截器（用于日志记录和自动添加API key）
    dioInstance.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // 自动添加 API key 到查询参数
          options.queryParameters['api_key'] = AppConfig.tmdbApiKey;

          Logger.debug('请求: ${options.method} ${options.uri}', 'TmdbService');
          Logger.debug('请求参数: ${options.queryParameters}', 'TmdbService');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          Logger.debug(
            '响应: ${response.statusCode} ${response.requestOptions.uri}',
            'TmdbService',
          );
          Logger.debug(
            '响应数据长度: ${response.data.toString().length}',
            'TmdbService',
          );
          return handler.next(response);
        },
        onError: (error, handler) {
          Logger.error(
            '请求失败: ${error.requestOptions.uri}',
            error.error,
            error.stackTrace,
            'TmdbService',
          );
          return handler.next(error);
        },
      ),
    );

    return dioInstance;
  }

  /// 获取正在上映的电影
  /// [page] 页码，默认为1
  /// [language] 语言代码，默认为zh-CN
  /// 返回电影列表响应
  Future<MovieResponse> getNowPlayingMovies({
    int page = 1,
    String language = 'zh-CN',
  }) async {
    try {
      final response = await dio.get(
        '/movie/now_playing',
        queryParameters: {'language': language, 'page': page},
      );

      return _handleMovieResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e, '获取正在上映的电影失败');
    } catch (e, stackTrace) {
      Logger.error('获取正在上映的电影失败', e, stackTrace, 'TmdbService');
      rethrow;
    }
  }

  /// 获取热门电影
  /// [page] 页码，默认为1
  /// [language] 语言代码，默认为zh-CN
  /// 返回电影列表响应
  Future<MovieResponse> getPopularMovies({
    int page = 1,
    String language = 'zh-CN',
  }) async {
    try {
      final response = await dio.get(
        '/movie/popular',
        queryParameters: {'language': language, 'page': page},
      );

      return _handleMovieResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e, '获取热门电影失败');
    } catch (e, stackTrace) {
      Logger.error('获取热门电影失败', e, stackTrace, 'TmdbService');
      rethrow;
    }
  }

  /// 获取即将上映的电影
  /// [page] 页码，默认为1
  /// [language] 语言代码，默认为zh-CN
  /// 返回电影列表响应
  Future<MovieResponse> getUpcomingMovies({
    int page = 1,
    String language = 'zh-CN',
  }) async {
    try {
      final response = await dio.get(
        '/movie/upcoming',
        queryParameters: {'language': language, 'page': page},
      );

      return _handleMovieResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e, '获取即将上映的电影失败');
    } catch (e, stackTrace) {
      Logger.error('获取即将上映的电影失败', e, stackTrace, 'TmdbService');
      rethrow;
    }
  }

  /// 获取高分电影
  /// [page] 页码，默认为1
  /// [language] 语言代码，默认为zh-CN
  /// 返回电影列表响应
  Future<MovieResponse> getTopRatedMovies({
    int page = 1,
    String language = 'zh-CN',
  }) async {
    try {
      final response = await dio.get(
        '/movie/top_rated',
        queryParameters: {'language': language, 'page': page},
      );

      return _handleMovieResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e, '获取高分电影失败');
    } catch (e, stackTrace) {
      Logger.error('获取高分电影失败', e, stackTrace, 'TmdbService');
      rethrow;
    }
  }

  /// 获取热门趋势电影
  /// [timeWindow] 时间窗口，可选值: 'day' (今日) 或 'week' (本周)，默认为 'day'
  /// [page] 页码，默认为1
  /// [language] 语言代码，默认为zh-CN
  /// 返回电影列表响应
  Future<MovieResponse> getTrendingMovies({
    String timeWindow = 'day',
    int page = 1,
    String language = 'zh-CN',
  }) async {
    try {
      final response = await dio.get(
        '/trending/movie/$timeWindow',
        queryParameters: {'language': language, 'page': page},
      );

      return _handleMovieResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e, '获取热门趋势电影失败');
    } catch (e, stackTrace) {
      Logger.error('获取热门趋势电影失败', e, stackTrace, 'TmdbService');
      rethrow;
    }
  }

  /// 搜索电影
  /// [query] 搜索关键词
  /// [page] 页码，默认为1
  /// [language] 语言代码，默认为zh-CN
  /// 返回电影列表响应
  Future<MovieResponse> searchMovies({
    required String query,
    int page = 1,
    String language = 'zh-CN',
  }) async {
    try {
      final response = await dio.get(
        '/search/movie',
        queryParameters: {'query': query, 'language': language, 'page': page},
      );

      return _handleMovieResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e, '搜索电影失败');
    } catch (e, stackTrace) {
      Logger.error('搜索电影失败', e, stackTrace, 'TmdbService');
      rethrow;
    }
  }

  /// 获取电影类型列表
  /// [language] 语言代码，默认为zh-CN
  /// 返回类型列表
  Future<GenreListResponse> getMovieGenres({
    String language = 'zh-CN',
  }) async {
    try {
      final response = await dio.get(
        '/genre/movie/list',
        queryParameters: {'language': language},
      );

      if (response.statusCode == 200) {
        try {
          final jsonData = response.data as Map<String, dynamic>;
          final genreListResponse = GenreListResponse.fromJson(jsonData);
          Logger.info('成功获取 ${genreListResponse.genres.length} 个电影类型', 'TmdbService');
          return genreListResponse;
        } catch (e, stackTrace) {
          Logger.error('JSON解析失败', e, stackTrace, 'TmdbService');
          throw Exception('响应数据格式错误: $e');
        }
      } else {
        Logger.error('请求失败: ${response.statusCode}', null, null, 'TmdbService');
        throw Exception('请求失败: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e, '获取电影类型列表失败');
    } catch (e, stackTrace) {
      Logger.error('获取电影类型列表失败', e, stackTrace, 'TmdbService');
      rethrow;
    }
  }

  /// 按类型发现电影
  /// [genreId] 类型ID
  /// [page] 页码，默认为1
  /// [language] 语言代码，默认为zh-CN
  /// [sortBy] 排序方式，默认为 'popularity.desc'
  /// 返回电影列表响应
  Future<MovieResponse> discoverMoviesByGenre({
    required int genreId,
    int page = 1,
    String language = 'zh-CN',
    String sortBy = 'popularity.desc',
  }) async {
    try {
      final response = await dio.get(
        '/discover/movie',
        queryParameters: {
          'with_genres': genreId,
          'language': language,
          'page': page,
          'sort_by': sortBy,
        },
      );

      return _handleMovieResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e, '按类型发现电影失败');
    } catch (e, stackTrace) {
      Logger.error('按类型发现电影失败', e, stackTrace, 'TmdbService');
      rethrow;
    }
  }

  /// 获取电影详情
  /// [movieId] 电影ID
  /// [language] 语言代码，默认为zh-CN
  /// 返回电影详情
  Future<MovieDetail> getMovieDetail({
    required int movieId,
    String language = 'zh-CN',
  }) async {
    try {
      final response = await dio.get(
        '/movie/$movieId',
        queryParameters: {'language': language},
      );

      return _handleMovieDetailResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e, '获取电影详情失败');
    } catch (e, stackTrace) {
      Logger.error('获取电影详情失败', e, stackTrace, 'TmdbService');
      rethrow;
    }
  }

  /// 处理电影列表响应
  MovieResponse _handleMovieResponse(Response response) {
    if (response.statusCode == 200) {
      try {
        final jsonData = response.data as Map<String, dynamic>;
        final movieResponse = MovieResponse.fromJson(jsonData);
        Logger.info('成功获取 ${movieResponse.results.length} 部电影', 'TmdbService');
        return movieResponse;
      } catch (e, stackTrace) {
        Logger.error('JSON解析失败', e, stackTrace, 'TmdbService');
        Logger.debug(
          '响应内容: ${response.data.toString().substring(0, response.data.toString().length > 500 ? 500 : response.data.toString().length)}',
          'TmdbService',
        );
        throw Exception('响应数据格式错误: $e');
      }
    } else {
      Logger.error('请求失败: ${response.statusCode}', null, null, 'TmdbService');
      throw Exception('请求失败: ${response.statusCode}');
    }
  }

  /// 处理电影详情响应
  MovieDetail _handleMovieDetailResponse(Response response) {
    if (response.statusCode == 200) {
      try {
        final jsonData = response.data as Map<String, dynamic>;
        final movieDetail = MovieDetail.fromJson(jsonData);
        Logger.info('成功获取电影详情: ${movieDetail.title}', 'TmdbService');
        return movieDetail;
      } catch (e, stackTrace) {
        Logger.error('JSON解析失败', e, stackTrace, 'TmdbService');
        throw Exception('响应数据格式错误: $e');
      }
    } else {
      Logger.error('请求失败: ${response.statusCode}', null, null, 'TmdbService');
      throw Exception('请求失败: ${response.statusCode}');
    }
  }

  /// 处理 Dio 错误
  /// [error] DioException 错误对象
  /// [defaultMessage] 默认错误消息
  /// 返回友好的错误信息
  Exception _handleDioError(DioException error, String defaultMessage) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        Logger.error('请求超时', error, error.stackTrace, 'TmdbService');
        return Exception('请求超时，请检查网络连接');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        Logger.error(
          '请求失败: $statusCode',
          error,
          error.stackTrace,
          'TmdbService',
        );
        if (statusCode == 401 || statusCode == 403) {
          return Exception('API认证失败，请检查API配置');
        } else if (statusCode == 404) {
          return Exception('请求的资源不存在');
        } else {
          return Exception('请求失败: $statusCode');
        }

      case DioExceptionType.cancel:
        Logger.warning('请求已取消', 'TmdbService');
        return Exception('请求已取消');

      case DioExceptionType.connectionError:
        Logger.error('网络连接失败', error, error.stackTrace, 'TmdbService');
        return Exception('网络连接失败，请检查网络设置');

      case DioExceptionType.badCertificate:
        Logger.error('证书验证失败', error, error.stackTrace, 'TmdbService');
        return Exception('SSL证书验证失败');

      case DioExceptionType.unknown:
        Logger.error(
          defaultMessage,
          error.error,
          error.stackTrace,
          'TmdbService',
        );
        final errorMessage = error.message ?? '未知错误';
        if (errorMessage.contains('SocketException') ||
            errorMessage.contains('Connection failed') ||
            errorMessage.contains('Failed host lookup')) {
          return Exception('网络连接失败，请检查网络设置');
        }
        return Exception('$defaultMessage: $errorMessage');
    }
  }
}
