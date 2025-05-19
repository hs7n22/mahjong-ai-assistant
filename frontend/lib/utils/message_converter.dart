import "package:flutter_chat_types/flutter_chat_types.dart" as types;
import "package:uuid/uuid.dart";
import "package:frontend/models/message.dart" as model;

//将后端 Message 模型转为UI可用的TextMessage
types.TextMessage toTextMessage(
  model.Message m,
  types.User user,
  types.User ai,
) {
  return types.TextMessage(
    author: m.role == 'user' ? user : ai,
    id: const Uuid().v4(),
    text: m.content,
    createdAt: m.timestamp,
  );
}
