class MovieDetail {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final double voteAverage;
  final int voteCount;
  final String releaseDate;
  final String originalLanguage;
  MovieDetail({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.voteAverage,
    required this.voteCount,
    required this.releaseDate,
    required this.originalLanguage,
  });
  static MovieDetail fromJson(Map<String, dynamic> json) {
    return MovieDetail(
      id: json['id'],
      title: json['title'],
      overview: json['overview'],
      posterPath: json['poster_path'],
      voteAverage: json['vote_average'],
      voteCount: json['vote_count'],
      releaseDate: json['release_date'],
      originalLanguage: json['original_language'],
    );
  }
}
