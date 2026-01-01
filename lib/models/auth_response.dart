/// 登录/注册响应模型
///
/// 支持的响应格式：
/// 1. 嵌套格式（推荐）:
///    {
///      "code": 200,
///      "message": "success",
///      "data": {
///        "access_token": "...",
///        "user": {...}
///      }
///    }
/// 2. 直接格式:
///    {
///      "access_token": "...",
///      "user": {...}
///    }
class AuthResponse {
  final String? token;
  final String? accessToken;
  final String? refreshToken;
  final User? user;
  final String? message;
  final bool success;

  AuthResponse({
    this.token,
    this.accessToken,
    this.refreshToken,
    this.user,
    this.message,
    required this.success,
  });

  /// 从 JSON 创建 AuthResponse
  /// 支持两种响应格式：
  /// 1. 直接格式: {"access_token": "...", "user": {...}}
  /// 2. 嵌套格式: {"code": 200, "message": "success", "data": {"access_token": "...", "user": {...}}}
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // 检查是否是嵌套格式（有 data 字段）
    Map<String, dynamic> data;
    if (json['data'] != null && json['data'] is Map) {
      data = Map<String, dynamic>.from(json['data'] as Map);
    } else {
      // 直接格式，使用整个 json
      data = json;
    }

    // 安全地获取 accessToken（支持 accessToken 和 access_token）
    String? accessToken;
    final accessTokenValue = data['accessToken'] ?? data['access_token'];
    if (accessTokenValue != null) {
      if (accessTokenValue is String) {
        accessToken = accessTokenValue;
      } else if (accessTokenValue is List && accessTokenValue.isNotEmpty) {
        accessToken = accessTokenValue.first.toString();
      }
    }

    // 安全地获取 token（如果没有 accessToken，尝试 token 字段）
    String? token = accessToken;
    if (token == null) {
      final tokenValue = data['token'];
      if (tokenValue != null) {
        if (tokenValue is String) {
          token = tokenValue;
        } else if (tokenValue is List && tokenValue.isNotEmpty) {
          token = tokenValue.first.toString();
        }
      }
    }

    // 安全地获取 refreshToken（支持 refreshToken 和 refresh_token）
    String? refreshToken;
    final refreshTokenValue = data['refreshToken'] ?? data['refresh_token'];
    if (refreshTokenValue != null) {
      if (refreshTokenValue is String) {
        refreshToken = refreshTokenValue;
      } else if (refreshTokenValue is List && refreshTokenValue.isNotEmpty) {
        refreshToken = refreshTokenValue.first.toString();
      }
    }

    // 安全地获取 user
    User? user;
    if (data['user'] != null) {
      if (data['user'] is Map) {
        try {
          user = User.fromJson(Map<String, dynamic>.from(data['user'] as Map));
        } catch (e) {
          // 忽略 user 解析错误
        }
      } else if (data['user'] is List && (data['user'] as List).isNotEmpty) {
        // 如果是数组，取第一个元素
        final userData = (data['user'] as List).first;
        if (userData is Map) {
          try {
            user = User.fromJson(Map<String, dynamic>.from(userData));
          } catch (e) {
            // 忽略 user 解析错误
          }
        }
      }
    }

    // 安全地获取 message（从外层或 data 中获取）
    String? message;
    final messageValue = json['message'] ?? data['message'];
    if (messageValue != null) {
      if (messageValue is String) {
        message = messageValue;
      } else if (messageValue is List && messageValue.isNotEmpty) {
        message = messageValue.first.toString();
      } else {
        message = messageValue.toString();
      }
    }

    // 安全地获取 success（根据 code 或 success 字段判断）
    bool success = true;
    if (json['code'] != null) {
      // 如果有 code 字段，code == 200 表示成功
      final code = json['code'];
      if (code is int) {
        success = code == 200;
      } else if (code is String) {
        success = code == '200';
      }
    } else if (json['success'] != null || data['success'] != null) {
      final successValue = json['success'] ?? data['success'];
      if (successValue is bool) {
        success = successValue;
      } else if (successValue is String) {
        success = successValue.toLowerCase() == 'true';
      } else if (successValue is int) {
        success = successValue != 0;
      }
    }

    return AuthResponse(
      token: token,
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user,
      message: message,
      success: success,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      if (token != null) 'token': token,
      if (accessToken != null) 'accessToken': accessToken,
      if (refreshToken != null) 'refreshToken': refreshToken,
      if (user != null) 'user': user!.toJson(),
      if (message != null) 'message': message,
      'success': success,
    };
  }
}

/// 用户信息模型
///
/// 支持的字段：
/// - id: 数字或字符串（会自动转换为字符串）
/// - username: 用户名
/// - email: 邮箱
/// - avatar_url: 头像 URL（下划线格式）
/// - avatar: 头像 URL（驼峰格式）
/// - language: 语言设置
/// - theme: 主题设置
/// - createdAt/created_at: 创建时间
/// - updatedAt/updated_at: 更新时间
class User {
  final String id;
  final String username;
  final String email;
  final String? avatar;
  final String? avatarUrl; // 支持 avatar_url 字段
  final String? language;
  final String? theme;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.avatar,
    this.avatarUrl,
    this.language,
    this.theme,
    this.createdAt,
    this.updatedAt,
  });

  /// 从 JSON 创建 User
  /// 支持多种字段格式：
  /// - id: 可以是数字或字符串
  /// - avatar_url 或 avatar
  /// - createdAt/created_at 或 updatedAt/updated_at
  factory User.fromJson(Map<String, dynamic> json) {
    // 安全地获取 id（支持数字和字符串）
    String id = '';
    if (json['id'] != null) {
      id = json['id'].toString();
    } else if (json['_id'] != null) {
      id = json['_id'].toString();
    }

    // 安全地获取 username
    String username = '';
    if (json['username'] != null) {
      username = json['username'].toString();
    }

    // 安全地获取 email
    String email = '';
    if (json['email'] != null) {
      email = json['email'].toString();
    }

    return User(
      id: id,
      username: username,
      email: email,
      avatar: json['avatar'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      language: json['language'] as String?,
      theme: json['theme'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      if (avatar != null) 'avatar': avatar,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (language != null) 'language': language,
      if (theme != null) 'theme': theme,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// 获取头像 URL（优先使用 avatarUrl，如果没有则使用 avatar）
  String? getAvatarUrl() {
    return avatarUrl ?? avatar;
  }
}
