import 'package:flutter/material.dart';
import 'package:flutter_movie/views/home.dart';
import 'package:flutter_movie/views/favorites.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // 用于触发 Movies 页面刷新的回调
  VoidCallback? _refreshMoviesCallback;

  // 使用 IndexedStack 保持所有 tab 的状态
  late final List<Widget> _pages = [
    const Home(),
    Favorites(
      refreshCallback: (callback) {
        // 保存刷新回调，以便在切换标签时调用
        _refreshMoviesCallback = callback;
      },
      onVisible: () {
        // 当 Movies 页面变为可见时，刷新收藏列表
        _refreshMoviesCallback?.call();
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            // 当切换到 Movies 页面时，刷新收藏列表
            if (index == 1) {
              _refreshMoviesCallback?.call();
            }
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Movies'),
        ],
      ),
    );
  }
}
