import 'package:flutter/material.dart';
import 'package:flutter_movie/models/genre.dart';
import 'package:flutter_movie/models/movie.dart';
import 'package:flutter_movie/models/movie_response.dart';
import 'package:flutter_movie/services/tmdb_service.dart';
import 'package:flutter_movie/utils/logger.dart';
import 'package:flutter_movie/views/detail_movie.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

const List<String> _movieChips = [
  'Now Playing',
  'Upcoming',
  'Popular',
  'Top Rated',
  'Trending',
];

class _HomeState extends State<Home> {
  String _selectedMovieChip = '';
  int? _selectedGenreId; // 选中的类型ID
  final List<Movie> _movies = [];
  List<Genre> _genres = []; // 类型列表
  bool _isLoading = false;
  bool _isLoadingGenres = false;
  // 滚动控制器
  final ScrollController _scrollController = ScrollController();
  // 当前页码
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    // 先设置默认选中的标签
    _selectedMovieChip = _movieChips[0];

    // 设置滚动监听器
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          _hasMore &&
          !_isLoading) {
        _loadMovies();
      }
    });

    // 加载类型列表
    _loadGenres();
    // 加载初始电影列表
    _loadMovies();
  }

  // 加载电影类型列表
  Future<void> _loadGenres() async {
    if (_isLoadingGenres) return;
    try {
      setState(() {
        _isLoadingGenres = true;
      });
      final response = await TmdbService.instance.getMovieGenres();
      setState(() {
        _genres = response.genres;
      });
    } catch (e, stackTrace) {
      Logger.error('加载电影类型失败', e, stackTrace, 'MainNavigation');
    } finally {
      setState(() {
        _isLoadingGenres = false;
      });
    }
  }

  // 加载电影列表
  Future<void> _loadMovies({bool isRefresh = false}) async {
    if (_isLoading) return;
    try {
      setState(() {
        _isLoading = true;
      });
      // 如果是刷新，则清空电影列表
      if (isRefresh) {
        _currentPage = 1;
        _hasMore = true;
        _movies.clear();
      }

      // 根据选中的标签和类型调用不同的 API
      MovieResponse response;

      // 如果选择了类型，使用类型筛选（可以配合分类标签的排序方式）
      if (_selectedGenreId != null) {
        // 根据分类标签选择排序方式
        String sortBy = 'popularity.desc'; // 默认按热度排序
        switch (_selectedMovieChip) {
          case 'Now Playing':
            // 正在上映的电影，按上映日期倒序排序
            sortBy = 'release_date.desc';
            break;
          case 'Upcoming':
            // 即将上映的电影，按上映日期正序排序
            sortBy = 'release_date.asc';
            break;
          case 'Popular':
            // 热门电影，按热度排序
            sortBy = 'popularity.desc';
            break;
          case 'Top Rated':
            // 高分电影，按评分排序
            sortBy = 'vote_average.desc';
            break;
          case 'Trending':
            // 趋势电影，按热度排序
            sortBy = 'popularity.desc';
            break;
          default:
            sortBy = 'popularity.desc';
        }

        // 使用类型筛选接口获取电影列表
        response = await TmdbService.instance.discoverMoviesByGenre(
          genreId: _selectedGenreId!,
          page: _currentPage,
          sortBy: sortBy,
        );
      } else {
        // 否则使用分类标签
        switch (_selectedMovieChip) {
          case 'Popular':
            response = await TmdbService.instance.getPopularMovies(
              page: _currentPage,
            );
            break;
          case 'Top Rated':
            response = await TmdbService.instance.getTopRatedMovies(
              page: _currentPage,
            );
            break;
          case 'Trending':
            response = await TmdbService.instance.getTrendingMovies(
              page: _currentPage,
            );
            break;
          case 'Now Playing':
            response = await TmdbService.instance.getNowPlayingMovies(
              page: _currentPage,
            );
            break;
          case 'Upcoming':
            response = await TmdbService.instance.getUpcomingMovies(
              page: _currentPage,
            );
            break;
          default:
            response = await TmdbService.instance.getPopularMovies(
              page: _currentPage,
            );
        }
      }

      final movies = response.results;
      setState(() {
        _movies.addAll(movies);
        _currentPage++;
        // 修复分页计算：计算总页数（每页20条）
        const int pageSize = 20;
        final int totalPages = (response.total / pageSize).ceil();
        _hasMore = _currentPage <= totalPages;
      });
    } catch (e, stackTrace) {
      Logger.error('加载电影列表失败', e, stackTrace, 'MainNavigation');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onMovieChipPressed(String label) {
    // 如果点击的是已选中的标签且没有选择类型，则不执行操作
    if (_selectedMovieChip == label && _selectedGenreId == null) return;

    setState(() {
      _selectedMovieChip = label;
      // 不清除类型选择，允许同时使用
      _currentPage = 1;
      _hasMore = true;
      _movies.clear();
    });
    // 切换标签时重新加载电影列表
    _loadMovies(isRefresh: true);
  }

  void _onGenrePressed(int genreId) {
    // 如果点击的是已选中的类型，则取消选择
    if (_selectedGenreId == genreId) {
      setState(() {
        _selectedGenreId = null;
        _currentPage = 1;
        _hasMore = true;
        _movies.clear();
      });
      _loadMovies(isRefresh: true);
      return;
    }

    setState(() {
      _selectedGenreId = genreId;
      // 不清除分类标签选择，允许同时使用
      // 如果没有选择分类标签，默认使用 Popular
      if (_selectedMovieChip.isEmpty) {
        _selectedMovieChip = _movieChips[0];
      }
      _currentPage = 1;
      _hasMore = true;
      _movies.clear();
    });
    // 切换类型时重新加载电影列表
    _loadMovies(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Discover Movies',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search movies...',
                hintStyle: TextStyle(color: Colors.grey),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              // runSpacing是Wrap控件的垂直间距字段，用于设置每一行之间的垂直间隔，单位为像素。
              runSpacing: 8,
              children: List.generate(
                _movieChips.length,
                (index) => MovieChip(
                  label: _movieChips[index],
                  onPressed: () {
                    _onMovieChipPressed(_movieChips[index]);
                  },
                  isSelected: _selectedMovieChip == _movieChips[index],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 类型标签区域
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Genres',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: _isLoadingGenres
                      ? const Center(child: CircularProgressIndicator())
                      : _genres.isEmpty
                      ? const Center(
                          child: Text(
                            '加载类型中...',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _genres.length,
                          physics: const BouncingScrollPhysics(), // iOS 风格的弹性滚动
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          itemBuilder: (context, index) {
                            final genre = _genres[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                right: 8,
                                left: index == 0 ? 0 : 0, // 第一个标签不需要左边距
                              ),
                              child: MovieChip(
                                label: genre.name,
                                onPressed: () {
                                  // 使用 tmdb_id 而不是 id，因为数据库中 genre_ids 存储的是 TMDB ID
                                  _onGenrePressed(genre.tmdb_id);
                                },
                                isSelected: _selectedGenreId == genre.tmdb_id,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 电影列表
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () => _loadMovies(isRefresh: true),
                      child: _movies.isEmpty
                          ? ListView(
                              // 这个是ListView的滚动物理属性，
                              // 设置为AlwaysScrollableScrollPhysics确保即使内容不足一屏也支持下拉刷新
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(height: 300),
                                Center(child: Text('暂无电影数据')),
                              ],
                            )
                          : GridView.builder(
                              controller: _scrollController,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.7,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                              itemCount: _movies.length + (_hasMore ? 1 : 0),
                              itemBuilder: (context, index) =>
                                  index < _movies.length
                                  ? MovieCard(
                                      movie: _movies[index],
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DetailMovie(
                                              movieId: _movies[index].id,
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class MovieChip extends StatelessWidget {
  const MovieChip({
    super.key,
    required this.label,
    required this.onPressed,
    required this.isSelected,
  });
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [Colors.lightGreen, Colors.lightBlue]
                : [Colors.white10, Colors.white38],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.all(Radius.circular(20)),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

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

            // 3️⃣ 标题
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
