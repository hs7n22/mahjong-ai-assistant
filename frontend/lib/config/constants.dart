// ✅ lib/config/constants.dart：用于统一管理 API 地址和配置常量

class AppConstants {
  /// 本地开发用 API 地址（需通过 dart-define 设置）
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://192.168.100.112:8000',
  );

  /// 上传接口路径
  static const String uploadEndpoint = '/upload';

  /// 示例：完整上传 URL
  static String get fullUploadUrl => '$apiBaseUrl$uploadEndpoint';
}
