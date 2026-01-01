import 'package:flutter/material.dart';
import 'package:flutter_movie/models/movie.dart';
import 'package:flutter_movie/services/favorite_service.dart';
import 'package:flutter_movie/utils/logger.dart';
import 'package:flutter_movie/views/detail_movie.dart';

class Favorites extends StatefulWidget {
  const Favorites({super.key, this.onVisible, this.refreshCallback});

  // 当页面变为可见时的回调
  final VoidCallback? onVisible;
  // 用于注册刷新回调
  final Function(VoidCallback)? refreshCallback;

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  final List<Movie> _favoriteMovies = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    // 注册刷新回调，让外部可以调用 refreshFavorites
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.refreshCallback?.call(refreshFavorites);
      widget.onVisible?.call();
    });
  }

  // 当页面变为可见时调用（用于 IndexedStack 场景）
  void refreshFavorites() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final favorites = await FavoriteService.instance.getFavorites();
      setState(() {
        _favoriteMovies.clear();
        _favoriteMovies.addAll(favorites);
      });
    } catch (e, stackTrace) {
      Logger.error('加载收藏列表失败', e, stackTrace, 'Movies');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 移除收藏
  Future<void> _removeFavorite(int movieId) async {
    try {
      final success = await FavoriteService.instance.removeFavorite(movieId);
      if (success) {
        // 移除成功后刷新列表
        _loadFavorites();
        // 显示成功提示
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('已移除收藏'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // 显示失败提示
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('移除收藏失败'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      Logger.error('移除收藏失败', e, stackTrace, 'Favorites');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('移除收藏失败'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteMovies.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '暂无收藏',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '在电影详情页点击"Add to Favorites"来收藏电影',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadFavorites,
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _favoriteMovies.length,
                itemBuilder: (context, index) {
                  return MovieCard(
                    movie: _favoriteMovies[index],
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailMovie(movieId: _favoriteMovies[index].id),
                        ),
                      ).then((_) {
                        // 从详情页返回后刷新收藏列表
                        _loadFavorites();
                      });
                    },
                    onRemove: () async {
                      // 移除收藏
                      await _removeFavorite(_favoriteMovies[index].id);
                    },
                  );
                },
              ),
            ),
    );
  }
}

class MovieCard extends StatefulWidget {
  const MovieCard({
    super.key,
    required this.movie,
    required this.onPressed,
    this.onRemove,
  });
  final Movie movie;
  final VoidCallback onPressed;
  final VoidCallback? onRemove; // 移除收藏的回调

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final posterUrl = widget.movie.getPosterUrl(size: 'w500');
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: posterUrl != null
                        ? AnimatedScale(
                            scale: _isHovered ? 1.1 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            child: Image.network(
                              posterUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.error_outline,
                                      size: 48,
                                    ),
                                  ),
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                            ),
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.movie, size: 48),
                          ),
                  ),
                  if (true)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: GestureDetector(
                        onTap: () {
                          // 显示确认对话框
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('移除收藏'),
                              content: Text(
                                '确定要移除《${widget.movie.title}》的收藏吗？',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('取消'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    widget.onRemove?.call();
                                  },
                                  child: const Text(
                                    '确定',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        // 阻止事件冒泡到父级 GestureDetector
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _RatingBadge(rating: widget.movie.voteAverage),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              widget.movie.releaseDate,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;

  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
