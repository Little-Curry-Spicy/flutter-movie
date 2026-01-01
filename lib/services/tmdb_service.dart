import 'package:dio/dio.dart';
import 'package:flutter_movie/services/base_response.dart';
import '../models/genre.dart';
import '../models/movie.dart';
import '../models/movie_detail.dart';
import '../models/movie_response.dart';
import '../utils/logger.dart';
import 'http_service.dart';

/// 电影 API 服务类（本地 Swagger API）
/// 使用 Dio 进行网络请求，提供更好的错误处理和拦截器支持
class TmdbService {
  // 私有构造函数，实现单例模式
  TmdbService._();

  // 单例实例
  static final TmdbService _instance = TmdbService._();
  static TmdbService get instance => _instance;

  /// 使用共享的 Dio 实例
  Dio get dio => HttpService.instance.dio;

  /// 获取正在上映的电影（使用 /movies 接口）
  /// [page] 页码，默认为1
  /// [language] 语言代码，默认为zh-CN
  /// 返回电影列表响应
  Future<MovieResponse> getNowPlayingMovies({
    int page = 1,
    String language = 'zh-CN',
  }) async {
    try {
      final response = await dio.get(
        '/movies',
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
        '/movies/popular',
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

  /// 获取最新电影（使用 /movies/latest 接口）
  /// [page] 页码，默认为1
  /// [language] 语言代码，默认为zh-CN
  /// 返回电影列表响应
  Future<MovieResponse> getUpcomingMovies({
    int page = 1,
    String language = 'zh-CN',
  }) async {
    try {
      final response = await dio.get(
        '/movies/latest',
        queryParameters: {'language': language, 'page': page},
      );

      return _handleMovieResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e, '获取最新电影失败2');
    } catch (e, stackTrace) {
      Logger.error('获取最新电影失败3', e, stackTrace, 'TmdbService');
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
        '/movies/top-rated',
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

  /// 获取热门趋势电影（使用 /movies 接口，可能需要其他参数）
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
      // 如果没有专门的 trending 接口，使用 popular 接口
      final response = await dio.get(
        '/movies/popular',
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
        '/movies/search',
        queryParameters: {'q': query, 'language': language, 'page': page},
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
  Future<GenreListResponse> getMovieGenres({String language = 'zh-CN'}) async {
    try {
      final response = await dio.get(
        '/movies/genres/all',
        queryParameters: {'language': language},
      );

      // 解析基础响应
      final baseResponse = BaseResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      Logger.debug(
        '获取电影类型响应: code=${baseResponse.code}, message=${baseResponse.message}',
        'TmdbService',
      );

      if (baseResponse.code == 200) {
        // GenreListResponse.fromJson 期望接收 BaseResponse 对象
        final genreListResponse = GenreListResponse.fromJson(baseResponse);
        Logger.info(
          '成功获取 ${genreListResponse.genres.length} 个电影类型',
          'TmdbService',
        );
        return genreListResponse;
      } else {
        throw Exception('请求失败: ${baseResponse.code}');
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
  /// [sortBy] 排序方式，默认为 'popularity.desc'（后端暂不支持，固定使用 popularity 降序）
  /// 返回电影列表响应
  Future<MovieResponse> discoverMoviesByGenre({
    required int genreId,
    int page = 1,
    String language = 'zh-CN',
    String sortBy = 'popularity.desc',
  }) async {
    try {
      // 后端使用 limit 和 offset 进行分页，每页固定 20 条
      const int limit = 20;
      final int offset = (page - 1) * limit;
      
      final response = await dio.get(
        '/movies/genre/$genreId',
        queryParameters: {
          'language': language,
          'limit': limit,
          'offset': offset,
          // 注意：后端暂不支持 sortBy 参数，固定使用 popularity 降序排序
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
  /// 返回电影详情（包含演员信息和影评）
  Future<MovieDetail> getMovieDetail({
    required int movieId,
    String language = 'zh-CN',
  }) async {
    try {
      // 获取电影详情（包含演员信息和影评）
      final response = await dio.get(
        '/movies/$movieId',
        queryParameters: {
          'language': language,
          'includeCredits': true, // 包含演员信息
          'includeReviews': true, // 包含影评
        },
      );

      return _handleMovieDetailResponse(BaseResponse.fromJson(response.data));
    } on DioException catch (e) {
      throw _handleDioError(e, '获取电影详情失败');
    } catch (e, stackTrace) {
      Logger.error('获取电影详情失败', e, stackTrace, 'TmdbService');
      rethrow;
    }
  }

  /// 处理电影列表响应
  MovieResponse _handleMovieResponse(Response response) {
    if (BaseResponse.fromJson(response.data).code == 200) {
      try {
        final movieResponse = MovieResponse.fromJson(
          BaseResponse.fromJson(response.data).data,
        );
        return movieResponse;
      } catch (e) {
        Logger.debug(
          '响应内容: ${response.data.toString().substring(0, response.data.toString().length > 500 ? 500 : response.data.toString().length)}',
          'TmdbService',
        );
        throw Exception('响应数据格式错误: $e');
      }
    } else {
      Logger.error(
        '请求失败: ${BaseResponse.fromJson(response.data).code}',
        null,
        null,
        'TmdbService',
      );
      throw Exception('请求失败: ${BaseResponse.fromJson(response.data).code}');
    }
  }

  /// 获取演员参演的电影列表
  /// [personId] 演员ID
  /// [language] 语言代码，默认为zh-CN
  /// 返回电影列表响应
  Future<MovieResponse> getPersonMovies({
    required int personId,
    String language = 'zh-CN',
  }) async {
    try {
      // 注意：根据 Swagger 文档，/movies/actors/{id} 是获取演员详情
      // 如果需要获取演员参演的电影，可能需要从演员详情中获取，或者使用其他接口
      final response = await dio.get(
        '/movies/actors/$personId',
        queryParameters: {'language': language},
      );

      // 处理演员电影列表响应（格式与普通电影列表不同）
      if (response.statusCode == 200) {
        try {
          final jsonData = response.data as Map<String, dynamic>;
          // 演员电影列表返回的是 cast 字段，需要转换为 MovieResponse 格式
          final castList = jsonData['cast'] as List<dynamic>? ?? [];
          final movies = castList
              .map((movie) => Movie.fromJson(movie as Map<String, dynamic>))
              .toList();

          // 创建 MovieResponse 对象
          final movieResponse = MovieResponse(
            results: movies,
            total: jsonData['total'] as int,
          );

          Logger.info('成功获取 ${movies.length} 部电影', 'TmdbService');
          return movieResponse;
        } catch (e, stackTrace) {
          Logger.error('JSON解析失败', e, stackTrace, 'TmdbService');
          throw Exception('响应数据格式错误: $e');
        }
      } else {
        Logger.error('请求失败: ${response.statusCode}', null, null, 'TmdbService');
        throw Exception('请求失败: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e, '获取演员电影列表失败');
    } catch (e, stackTrace) {
      Logger.error('获取演员电影列表失败', e, stackTrace, 'TmdbService');
      rethrow;
    }
  }

  /// 处理电影详情响应
  MovieDetail _handleMovieDetailResponse(BaseResponse response) {
    if (response.code == 200) {
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
      throw Exception('请求失败: ${response.code}');
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
