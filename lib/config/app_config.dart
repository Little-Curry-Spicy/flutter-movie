/// 应用配置类
/// 用于管理应用的全局配置信息
class AppConfig {
  // 应用名称
  static const String appName = 'MovieGo';

  // 应用版本
  static const String appVersion = '1.0.0';

  // TMDb API配置
  static const String tmdbApiBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p';

  // TMDb API密钥
  static const String tmdbApiKey = 'b7ee1af86b0a0fe5073cb399dc3f5630';

  // TMDb API访问令牌
  static const String tmdbAccessToken =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJiN2VlMWFmODZiMGEwZmU1MDczY2IzOTlkYzNmNTYzMCIsIm5iZiI6MTc2NjgyMDI5NC40NzgwMDAyLCJzdWIiOiI2OTRmODljNmEwNzc5ZTI1NTZiMWM4N2YiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.atiDv1Hy_S2e428yS44NUXvWcSX6gEswlLBXX_kf8Ok';

  // 是否开启调试模式
  static const bool debugMode = true;

  // 请求超时时间（秒）
  static const int requestTimeout = 30;

  // 分页大小
  static const int pageSize = 20;

  // 图片尺寸配置
  static const String posterSizeSmall = 'w200';
  static const String posterSizeMedium = 'w500';
  static const String posterSizeLarge = 'w780';
  static const String backdropSizeLarge = 'w1280';
}
