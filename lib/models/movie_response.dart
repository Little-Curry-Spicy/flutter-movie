import 'movie.dart';

class MovieResponse {
  final List<Movie> results;
  final int totalPages;
  final int totalResults;
  final int page;
  final int perPage;
  final int total;
  MovieResponse({
    required this.results,
    required this.totalPages,
    required this.totalResults,
    required this.page,
    required this.perPage,
    required this.total,
  });

  static MovieResponse fromJson(Map<String, dynamic> json) {
    return MovieResponse(
      results: (json['results'] as List<dynamic>)
          .map((movie) => Movie.fromJson(movie as Map<String, dynamic>))
          .toList(),
      totalPages: json['total_pages'] as int? ?? 0,
      totalResults: json['total_results'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
    );
  }
}
