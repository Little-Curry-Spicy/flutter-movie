import 'package:flutter_movie/config/app_config.dart';

import '../models/cast.dart';
import '../models/genre.dart';
import '../models/review.dart';

class MovieDetail {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final double voteAverage;
  final int voteCount;
  final String releaseDate;
  final String originalLanguage;
  final int runtime;
  final List<Genre> genres;
  final List<Cast> actors; // 演员列表
  final List<Review> tmdbReviews; // 影评列表
  MovieDetail({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.voteCount,
    required this.releaseDate,
    required this.originalLanguage,
    required this.runtime,
    required this.genres,
    required this.actors,
    required this.tmdbReviews,
  });
  static MovieDetail fromJson(Map<String, dynamic> json) {
    // 处理 actors（演员信息）- 直接在 data 下的数组
    List<Cast> actorsList = [];
    if (json['actors'] != null && json['actors'] is List) {
      actorsList = (json['actors'] as List<dynamic>)
          .map((c) => Cast.fromJson(c as Map<String, dynamic>))
          .toList();
      // 按 order 排序，获取前10个主演
      actorsList.sort((a, b) => a.order.compareTo(b.order));
      actorsList = actorsList.take(10).toList();
    }

    // 处理 tmdbReviews（影评信息）- 直接在 data 下的数组
    List<Review> tmdbReviewsList = [];
    if (json['tmdbReviews'] != null && json['tmdbReviews'] is List) {
      tmdbReviewsList = (json['tmdbReviews'] as List<dynamic>)
          .map((r) => Review.fromJson(r as Map<String, dynamic>))
          .toList();
    }

    return MovieDetail(
      id: json['id'] as int? ?? json['tmdb_id'] as int? ?? 0,
      title:
          json['title'] as String? ?? json['original_title'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String? ?? '',
      backdropPath: json['backdrop_path'] as String? ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] as int? ?? 0,
      releaseDate: json['release_date'] as String? ?? '',
      originalLanguage: json['original_language'] as String? ?? 'en',
      runtime: json['runtime'] as int? ?? 0,
      genres:
          (json['genres'] as List<dynamic>?)
              ?.map((g) => Genre.fromJson(g as Map<String, dynamic>))
              .toList() ??
          [],
      actors: actorsList,
      tmdbReviews: tmdbReviewsList,
    );
  }

  String? getPosterUrl({String size = 'w500'}) {
    if (posterPath.isEmpty) return null;
    return '${AppConfig.tmdbImageBaseUrl}/$size$posterPath';
  }

  String? getBackdropUrl({String size = 'w1280'}) {
    if (backdropPath.isEmpty) return null;
    return '${AppConfig.tmdbImageBaseUrl}/$size$backdropPath';
  }

  String getFormattedRuntime() {
    if (runtime == 0) return '0m';
    final hours = runtime ~/ 60;
    final minutes = runtime % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
