/// 影评模型
class Review {
  final String id;
  final String author;
  final String content;
  final String createdAt;
  final String updatedAt;
  final String url;
  final double rating;

  Review({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.url,
    required this.rating,
  });

  static Review fromJson(Map<String, dynamic> json) {
    // 支持多种字段格式
    String id = '';
    if (json['id'] != null) {
      id = json['id'].toString();
    } else if (json['tmdb_review_id'] != null) {
      id = json['tmdb_review_id'].toString();
    }

    // 支持 author 和 author_username
    String author = json['author'] as String? ?? 
                    json['author_username'] as String? ?? 
                    'Anonymous';

    // 支持多种日期格式
    String createdAt = json['created_at'] as String? ?? 
                       json['tmdb_created_at'] as String? ?? 
                       '';
    String updatedAt = json['updated_at'] as String? ?? 
                       json['tmdb_updated_at'] as String? ?? 
                       '';

    // 支持多种 URL 格式
    String url = json['url'] as String? ?? 
                 json['tmdb_url'] as String? ?? 
                 '';

    // 支持多种评分格式
    double rating = 0.0;
    if (json['author_rating'] != null) {
      rating = (json['author_rating'] as num?)?.toDouble() ?? 0.0;
    } else if (json['author_details'] != null && json['author_details'] is Map) {
      final authorDetails = json['author_details'] as Map<String, dynamic>;
      rating = (authorDetails['rating'] as num?)?.toDouble() ?? 0.0;
    }

    return Review(
      id: id,
      author: author,
      content: json['content'] as String? ?? '',
      createdAt: createdAt,
      updatedAt: updatedAt,
      url: url,
      rating: rating,
    );
  }

  String getFormattedDate() {
    if (createdAt.isEmpty) return '';
    try {
      final date = DateTime.parse(createdAt);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return createdAt;
    }
  }
}

