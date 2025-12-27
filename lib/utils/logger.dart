import 'package:flutter/foundation.dart';

/// 日志工具类
/// 用于统一管理应用的日志输出
class Logger {
  /// 打印调试信息
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('🐛 DEBUG $tagStr: $message');
    }
  }

  /// 打印信息
  static void info(String message, [String? tag]) {
    if (kDebugMode) {
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('ℹ️ INFO $tagStr: $message');
    }
  }

  /// 打印警告信息
  static void warning(String message, [String? tag]) {
    if (kDebugMode) {
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('⚠️ WARNING $tagStr: $message');
    }
  }

  /// 打印错误信息
  static void error(
    String message, [
    Object? error,
    StackTrace? stackTrace,
    String? tag,
  ]) {
    if (kDebugMode) {
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('❌ ERROR $tagStr: $message');
      if (error != null) {
        debugPrint('Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('StackTrace: $stackTrace');
      }
    }
  }
}
