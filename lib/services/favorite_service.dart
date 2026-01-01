import 'package:flutter_movie/models/movie.dart';
import 'package:flutter_movie/services/base_response.dart';
import 'package:flutter_movie/services/http_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_movie/utils/logger.dart';

/// 收藏服务类
/// 使用 SharedPreferences 本地存储收藏的电影
class FavoriteService {
  FavoriteService._();

  // 单例实例
  static final FavoriteService _instance = FavoriteService._();
  static FavoriteService get instance => _instance;

  /// 使用共享的 Dio 实例
  Dio get dio => HttpService.instance.dio;

  /// 获取收藏列表
  Future<List<Movie>> getFavorites() async {
    try {
      final response = await dio.get('/favorites');
      if (BaseResponse.fromJson(response.data).code == 200) {
        final baseResponse = BaseResponse.fromJson(response.data);
        // 后端返回的数据结构：每个收藏项包含 movie 字段
        // data: [{ id, user_id, movie_id, created_at, movie: {...} }]
        final List<dynamic> favoritesList = baseResponse.data as List<dynamic>;

        // 从每个收藏项中提取 movie 对象并转换为 Movie
        final movies = favoritesList
            .map((favoriteItem) {
              // favoriteItem 是收藏项，包含 movie 字段
              final movieData = favoriteItem['movie'] as Map<String, dynamic>?;
              if (movieData != null) {
                return Movie.fromJson(movieData);
              }
              return null;
            })
            .whereType<Movie>() // 过滤掉 null 值
            .toList();

        Logger.info('成功获取 ${movies.length} 部收藏电影', 'FavoriteService');
        return movies;
      }
      return [];
    } catch (e, stackTrace) {
      Logger.error('获取收藏列表失败', e, stackTrace, 'FavoriteService');
      return [];
    }
  }

  /// 添加收藏
  Future<bool> addFavorite(int movieId) async {
    try {
      // 调用收藏接口
      final response = await dio.post('/favorites/$movieId');
      if (BaseResponse.fromJson(response.data).code == 201) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 移除收藏
  Future<bool> removeFavorite(int movieId) async {
    try {
      final response = await dio.delete('/favorites/$movieId');
      if (BaseResponse.fromJson(response.data).code == 200) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 检查是否已收藏
  Future<bool> isFavorite(int movieId) async {
    try {
      final response = await dio.get('/favorites/$movieId/check');
      if (BaseResponse.fromJson(response.data).code == 200) {
        return BaseResponse.fromJson(response.data).data['isFavorite'] as bool;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
