import 'dart:convert';

class Message {
  final String role; //'user' or 'assistant'
  final String type; // 目前使用text
  final String content;
  final int? timestamp;

  Message({
    required this.role,
    required this.type,
    required this.content,
    this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    role: json["role"],
    type: json["type"],
    content: json["content"],
    timestamp: json["timestamp"],
  );

  Map<String, dynamic> toJson() => {
    "role": role,
    "type": type,
    "content": content,
    "timestamp": timestamp,
  };

  static List<Message> messageListFromJson(String jsonStr) {
    final List<dynamic> data = jsonDecode(jsonStr);
    return data.map((e) => Message.fromJson(e)).toList();
  }
}
