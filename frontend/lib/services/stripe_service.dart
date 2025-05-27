import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import "package:universal_html/html.dart" as html;

class StripeService {
  Future<void> startCheckout() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (userId == null || token == null) {
      throw Exception("用户未登录");
    }

    final response = await http.post(
      Uri.parse('http://localhost:8000/create-checkout-session'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"user_id": userId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final stripeUrl = data["url"];
      html.window.location.href = stripeUrl;
    } else {
      throw Exception("创建支付会话失败: ${response.body}");
    }
  }
}
