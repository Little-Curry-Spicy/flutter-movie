class FavoritesResponse {
  final Favorite favorites;
  FavoritesResponse({required this.favorites});
  factory FavoritesResponse.fromJson(Map<String, dynamic> json) {
    return FavoritesResponse(favorites: json['favorites'] as Favorite);
  }
}

class Favorite {
  final int id;
  final int userId;
  final int movieId;
  final DateTime createdAt;
  Favorite({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.createdAt,
  });
  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'],
      userId: json['user_id'],
      movieId: json['movie_id'],
      createdAt: json['created_at'],
    );
  }
}
