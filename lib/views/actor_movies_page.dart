import 'package:flutter/material.dart';
import 'package:flutter_movie/models/movie.dart';
import 'package:flutter_movie/services/tmdb_service.dart';
import 'package:flutter_movie/utils/logger.dart';
import 'package:flutter_movie/views/detail_movie.dart';

class ActorMoviesPage extends StatefulWidget {
  const ActorMoviesPage({
    super.key,
    required this.actorId,
    required this.actorName,
  });

  final int actorId;
  final String actorName;

  @override
  State<ActorMoviesPage> createState() => _ActorMoviesPageState();
}

class _ActorMoviesPageState extends State<ActorMoviesPage> {
  List<Movie> _movies = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    if (_isLoading) return;
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await TmdbService.instance.getPersonMovies(
        personId: widget.actorId,
      );

      setState(() {
        _movies = response.results;
      });
    } catch (e, stackTrace) {
      Logger.error('加载演员电影列表失败', e, stackTrace, 'ActorMoviesPage');
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.actorName)),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Movies', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '加载失败',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage!,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadMovies,
                            child: const Text('重试'),
                          ),
                        ],
                      ),
                    )
                  : _movies.isEmpty
                  ? const Center(child: Text('暂无电影数据'))
                  : RefreshIndicator(
                      onRefresh: _loadMovies,
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.7,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: _movies.length,
                        itemBuilder: (context, index) {
                          return MovieCard(
                            movie: _movies[index],
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetailMovie(movieId: _movies[index].id),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// 复用 MovieCard 组件
class MovieCard extends StatefulWidget {
  const MovieCard({super.key, required this.movie, required this.onPressed});
  final Movie movie;
  final VoidCallback onPressed;

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final posterUrl = widget.movie.getPosterUrl(size: 'w500');
    return GestureDetector(
      onTap: widget.onPressed,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
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
