import 'movie.dart';

class MovieResponse {
  final List<Movie> results;
  final int total;
  MovieResponse({required this.results, required this.total});

  static MovieResponse fromJson(Map<String, dynamic> json) {
    return MovieResponse(
      results: (json['data'] as List<dynamic>)
          .map((movie) => Movie.fromJson(movie as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
    );
  }
}
