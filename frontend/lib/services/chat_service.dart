import 'package:frontend/models/message.dart';
import 'package:frontend/services/api_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  static Future<List<Message>> fetchHistory(String sessionId) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token == null) {
      await Future.delayed(Duration(milliseconds: 300));
      throw Exception("❌ Token 缺失，请先登录");
    }
    final response = await ApiService.get("/chat/$sessionId");
    if (response.isSuccess) {
      return Message.messageListFromJson(response.body);
    } else {
      throw Exception(response.error);
    }
  }

  static Future<List<Message>> sendMessage({
    required String sessionId,
    required String userMessage,
  }) async {
    final message = Message(
      role: "user",
      type: "text",
      content: userMessage,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    final response = await ApiService.post(
      ("/chat/$sessionId"),
      message.toJson(),
    );
    if (response.isSuccess) {
      return Message.messageListFromJson(response.body);
    } else {
      throw Exception(response.body);
    }
  }
}
