import 'package:flutter_movie/config/app_config.dart';

class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final double voteAverage;
  final int voteCount;
  final String releaseDate;
  final String originalLanguage;
  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.voteAverage,
    required this.voteCount,
    required this.releaseDate,
    required this.originalLanguage,
  });

  static Movie fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as int,
      title:
          json['title'] as String? ?? json['original_title'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String? ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] as int? ?? 0,
      releaseDate: json['release_date'] as String? ?? '',
      originalLanguage: json['original_language'] as String? ?? 'en',
    );
  }

  /// 获取海报完整URL
  /// [size] 图片尺寸，可选值: 'w200', 'w500', 'w780' 等
  String? getPosterUrl({String size = 'w500'}) {
    if (posterPath.isEmpty) return null;
    return '${AppConfig.tmdbImageBaseUrl}/$size$posterPath';
  }
}
