// ✅ 更新后的 lib/services/api_service.dart：使用 AppConstants + 清晰结构
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/config/constants.dart';

class ApiService {
  static final String baseUrl = AppConstants.apiBaseUrl;

  static Future<ApiResponse> get(String endpoint) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token == null) {
      return ApiResponse.error('Token 缺失，请重新登录');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return ApiResponse.fromHttp(response);
    } catch (e) {
      return ApiResponse.error('GET 请求异常: $e');
    }
  }

  static Future<ApiResponse> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token == null) {
      return ApiResponse.error('Token 缺失，请重新登录');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      return ApiResponse.fromHttp(response);
    } catch (e) {
      return ApiResponse.error('POST 请求异常: $e');
    }
  }

  static Future<ApiResponse> upload(
    String endpoint,
    Uint8List fileBytes,
    String fileName,
  ) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token == null) {
      return ApiResponse.error('Token 缺失，请重新登录');
    }

    final uri = Uri.parse('$baseUrl$endpoint');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
    );

    try {
      final streamed = await request.send();
      final body = await streamed.stream.bytesToString();
      return ApiResponse(
        statusCode: streamed.statusCode,
        body: body,
        error:
            streamed.statusCode >= 400 ? '上传失败 (${streamed.statusCode})' : null,
      );
    } catch (e) {
      return ApiResponse.error('上传异常: $e');
    }
  }
}

class ApiResponse {
  final int? statusCode;
  final String body;
  final String? error;

  ApiResponse({this.statusCode, required this.body, this.error});

  factory ApiResponse.fromHttp(http.Response response) {
    final isError = response.statusCode >= 400;
    return ApiResponse(
      statusCode: response.statusCode,
      body: response.body,
      error: isError ? '请求失败 (${response.statusCode})' : null,
    );
  }

  factory ApiResponse.error(String message) =>
      ApiResponse(statusCode: null, body: '', error: message);

  bool get isSuccess => error == null;
}
