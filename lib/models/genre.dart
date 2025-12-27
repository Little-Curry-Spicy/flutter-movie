/// 电影类型模型
class Genre {
  final int id;
  final String name;

  Genre({
    required this.id,
    required this.name,
  });

  static Genre fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

/// 类型列表响应模型
class GenreListResponse {
  final List<Genre> genres;

  GenreListResponse({required this.genres});

  static GenreListResponse fromJson(Map<String, dynamic> json) {
    return GenreListResponse(
      genres: (json['genres'] as List<dynamic>)
          .map((genre) => Genre.fromJson(genre as Map<String, dynamic>))
          .toList(),
    );
  }
}

