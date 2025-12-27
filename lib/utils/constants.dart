/// 应用常量类
/// 用于定义应用中使用的常量值
class AppConstants {
  // 私有构造函数，防止实例化
  AppConstants._();

  // 存储键名
  static const String keyToken = 'user_token';
  static const String keyUserId = 'user_id';
  static const String keyUserInfo = 'user_info';

  // 网络相关
  static const String contentTypeJson = 'application/json';
  static const String contentTypeForm = 'application/x-www-form-urlencoded';

  // 日期格式
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';

  // 默认值
  static const int defaultPageSize = 20;
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
}
