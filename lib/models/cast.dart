/// 演员模型
class Cast {
  final int id;
  final String name;
  final String character;
  final String profilePath;
  final int order;

  Cast({
    required this.id,
    required this.name,
    required this.character,
    required this.profilePath,
    required this.order,
  });

  static Cast fromJson(Map<String, dynamic> json) {
    return Cast(
      id: json['id'] as int? ?? json['tmdb_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      character: json['character'] as String? ?? json['character_name'] as String? ?? '',
      profilePath: json['profile_path'] as String? ?? '',
      // 支持 order 和 cast_order 两种字段名
      order: json['order'] as int? ?? json['cast_order'] as int? ?? 999,
    );
  }

  String? getProfileUrl({String size = 'w185'}) {
    if (profilePath.isEmpty) return null;
    return 'https://image.tmdb.org/t/p/$size$profilePath';
  }
}

