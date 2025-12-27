import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../views/main_navigation.dart';

/// 应用路由配置
/// 使用go_router进行路由管理
class AppRouter {
  /// 路由配置
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // 主导航页面（包含底部导航栏）
      GoRoute(
        path: '/',
        name: 'main',
        builder: (context, state) => const MainNavigation(),
      ),

      // 电影详情页路由
      // GoRoute(
      //   path: '/movie/:id',
      //   name: 'movie-detail',
      //   builder: (context, state) {
      //     final movieId = int.parse(state.pathParameters['id']!);
      //     return MovieDetailPage(movieId: movieId);
      //   },
      // ),
    ],

    // 错误页面
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('页面未找到')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              '页面未找到: ${state.uri}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    ),
  );
}
