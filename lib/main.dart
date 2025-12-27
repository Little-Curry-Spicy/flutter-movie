import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/app_config.dart';
import 'config/app_theme.dart';
import 'config/app_router.dart';
import 'utils/logger.dart';

/// 应用入口
void main() {
  // 初始化应用
  Logger.info('应用启动', 'Main');

  runApp(const ProviderScope(child: MyApp()));
}

/// 应用根组件
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // 应用标题
      title: AppConfig.appName,

      // 调试模式标志
      debugShowCheckedModeBanner: false,

      // 浅色主题
      theme: AppTheme.lightTheme,

      // 深色主题
      darkTheme: AppTheme.darkTheme,

      // 主题模式（跟随系统）
      themeMode: ThemeMode.system,

      // 路由配置
      routerConfig: AppRouter.router,
    );
  }
}
