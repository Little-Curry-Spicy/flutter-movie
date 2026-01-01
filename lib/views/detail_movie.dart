import 'package:flutter/material.dart';
import 'package:flutter_movie/services/tmdb_service.dart';
import 'package:flutter_movie/services/favorite_service.dart';
import '../models/movie_detail.dart';
import '../models/cast.dart';
import '../models/review.dart';
import 'package:flutter_movie/utils/logger.dart';
import 'package:flutter_movie/views/actor_movies_page.dart';

class DetailMovie extends StatefulWidget {
  const DetailMovie({super.key, required this.movieId});
  final int movieId;
  @override
  State<DetailMovie> createState() => _DetailMovieState();
}

class _DetailMovieState extends State<DetailMovie> {
  @override
  void initState() {
    super.initState();
    _loadMovieDetail();
  }

  bool _isLoading = true;
  late MovieDetail _movieDetail;
  bool _isDescriptionExpanded = false;
  bool _isFavorite = false;

  void _loadMovieDetail() async {
    final movieDetail = await TmdbService.instance.getMovieDetail(
      movieId: widget.movieId,
    );
    Logger.info('电影详情2: ${movieDetail.toString()}', 'DetailMovie');

    // 检查是否已收藏
    final isFavorite = await FavoriteService.instance.isFavorite(
      widget.movieId,
    );

    setState(() {
      _movieDetail = movieDetail;
      _isLoading = false;
      _isFavorite = isFavorite;
      if (movieDetail.overview.length > 10) {
        _isDescriptionExpanded = true;
      }
    });
  }

  Future<void> _toggleFavorite() async {
    try {
      if (_isFavorite) {
        // 取消收藏
        await FavoriteService.instance.removeFavorite(widget.movieId);
        setState(() {
          _isFavorite = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('已取消收藏')));
        }
      } else {
        await FavoriteService.instance.addFavorite(widget.movieId);
        setState(() {
          _isFavorite = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('已添加到收藏')));
        }
      }
    } catch (e) {
      Logger.error('收藏操作失败', e, null, 'DetailMovie');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          // 这一行用于展示可滚动的电影详情页面内容
          : CustomScrollView(
              slivers: [
                // 顶部大图区域
                SliverAppBar(
                  expandedHeight: MediaQuery.of(context).size.height * 0.5,
                  pinned: false,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // 背景图片（优先使用backdrop，否则使用poster）
                        Image.network(
                          _movieDetail.getBackdropUrl() ??
                              _movieDetail.getPosterUrl(size: 'w1280') ??
                              '',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey[900],
                                child: const Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.white,
                                ),
                              ),
                        ),
                        // 渐变遮罩
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.3),
                                Colors.white,
                              ],
                              stops: const [0.0, 0.7, 1.0],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  leading: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                // 内容区域
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 标题
                        Text(
                          _movieDetail.title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // 元数据：年份、时长、评分
                        Row(
                          children: [
                            if (_movieDetail.releaseDate.isNotEmpty) ...[
                              Text(
                                _movieDetail.releaseDate,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _movieDetail.getFormattedRuntime(),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _movieDetail.voteAverage.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // 类型标签
                        if (_movieDetail.genres.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _movieDetail.genres
                                .map((genre) => _buildGenreChip(genre.name))
                                .toList(),
                          ),
                        const SizedBox(height: 20),
                        // 添加到收藏按钮
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _toggleFavorite,
                            style: ElevatedButton.styleFrom().copyWith(
                              backgroundColor: WidgetStateProperty.all(
                                Colors.transparent,
                              ),
                              shadowColor: WidgetStateProperty.all(
                                Colors.transparent,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: _isFavorite
                                      ? [Colors.red[300]!, Colors.red[500]!]
                                      : [
                                          const Color(0xFF4ECDC4),
                                          const Color(0xFF44A3FF),
                                        ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isFavorite
                                          ? 'Remove from Favorites'
                                          : 'Add to Favorites',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // 描述部分
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _movieDetail.overview,
                          maxLines: _isDescriptionExpanded ? null : 1,
                          overflow: _isDescriptionExpanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            height: 1.5,
                          ),
                        ),
                        if (_movieDetail.overview.length > 100) ...[
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isDescriptionExpanded =
                                    !_isDescriptionExpanded;
                              });
                            },
                            child: Row(
                              children: [
                                Text(
                                  _isDescriptionExpanded
                                      ? 'Read less'
                                      : 'Read more',
                                  style: const TextStyle(
                                    color: Color(0xFF4ECDC4),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  _isDescriptionExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: const Color(0xFF4ECDC4),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ],
                        // 主演部分
                        if (_movieDetail.actors.isNotEmpty) ...[
                          const SizedBox(height: 32),
                          const Text(
                            'Cast',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 160,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: _movieDetail.actors.length,
                              itemBuilder: (context, index) {
                                final actor = _movieDetail.actors[index];
                                return _buildCastCard(actor);
                              },
                            ),
                          ),
                        ],
                        // 影评部分
                        if (_movieDetail.tmdbReviews.isNotEmpty) ...[
                          const SizedBox(height: 32),
                          const Text(
                            'Reviews',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ..._movieDetail.tmdbReviews.map(
                            (review) => _buildReviewCard(review),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCastCard(Cast cast) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ActorMoviesPage(actorId: cast.id, actorName: cast.name),
          ),
        );
      },
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 演员头像
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                cast.getProfileUrl() ?? '',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: const Icon(Icons.person, size: 40),
                ),
              ),
            ),
            const SizedBox(height: 6),
            // 演员姓名
            SizedBox(
              width: 90,
              child: Text(
                cast.name,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 2),
            // 角色名
            SizedBox(
              width: 90,
              child: Text(
                cast.character,
                style: const TextStyle(fontSize: 10, color: Colors.black54),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenreChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF4ECDC4), width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 作者和评分
          Row(
            children: [
              Expanded(
                child: Text(
                  review.author,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (review.rating > 0) ...[
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  review.rating.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ],
          ),
          if (review.getFormattedDate().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              review.getFormattedDate(),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
          const SizedBox(height: 12),
          // 影评内容
          Text(
            review.content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
