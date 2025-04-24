// ✅ 更新后的 UploadService：使用统一的 ApiService 封装
import 'dart:typed_data';
import 'package:frontend/services/api_service.dart';

class UploadService {
  Future<UploadResult> uploadImage({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    final response = await ApiService.upload('/upload', imageBytes, fileName);
    return UploadResult(
      statusCode: response.statusCode ?? 0,
      body: response.body,
      error: response.error,
    );
  }
}

class UploadResult {
  final int statusCode;
  final String body;
  final String? error;

  UploadResult({required this.statusCode, required this.body, this.error});

  bool get isSuccess => error == null;
}
