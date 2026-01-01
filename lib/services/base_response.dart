class BaseResponse {
  final int code;
  final String message;
  final dynamic data;
  BaseResponse({required this.code, required this.message, required this.data});

  static BaseResponse fromJson(Map<String, dynamic> json) {
    return BaseResponse(
      code: json['code'] as int,
      message: json['message'] as String,
      data: json['data'],
    );
  }

  void operator [](String other) {}
}
