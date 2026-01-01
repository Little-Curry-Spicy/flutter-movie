import 'package:flutter_movie/services/base_response.dart';

/// 电影类型模型
class Genre {
  final int id;
  final String name;
  final int tmdb_id;

  Genre({required this.id, required this.name, required this.tmdb_id});

  static Genre fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] as int,
      name: json['name'] as String,
      tmdb_id: json['tmdb_id'] as int,
    );
  }
}

/// 类型列表响应模型
class GenreListResponse {
  final List<Genre> genres;
  GenreListResponse({required this.genres});

  static GenreListResponse fromJson(BaseResponse json) {
    // 确保 data 是 List 类型
    if (json.data is! List) {
      throw Exception('响应数据格式错误: data 应该是数组类型');
    }

    return GenreListResponse(
      genres: (json.data as List<dynamic>)
          .map((genre) => Genre.fromJson(genre as Map<String, dynamic>))
          .toList(),
    );
  }
}
