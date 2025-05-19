// import 'package:flutter/material.dart';
// import 'package:frontend/widgets/chat_page_ui.dart';
// import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
// import 'package:uuid/uuid.dart';
// import 'package:frontend/services/chat_service.dart';
// import 'package:frontend/utils/message_converter.dart';

// class ChatPage extends StatefulWidget {
//   final String sessionId;
//   const ChatPage({super.key, required this.sessionId});

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   List<types.TextMessage> _messages = [];
//   final types.User _user = types.User(id: const Uuid().v4());
//   final types.User _ai = const types.User(id: 'ai-1');

//   @override
//   void initState() {
//     super.initState();
//     _loadHistory();
//   }

//   void _loadHistory() async {
//     final history = await ChatService.fetchHistory(widget.sessionId);
//     setState(() {
//       _messages =
//           history
//               .map((m) => toTextMessage(m, _user, _ai))
//               .toList()
//               .reversed
//               .toList();
//     });
//   }

//   // void _handleSendPressed(types.PartialText message) async {
//   //   final reply = await ChatService.sendMessage(
//   //     sessionId: widget.sessionId,
//   //     userMessage: message.text,
//   //   );
//   //   setState(() {
//   //     _messages =
//   //         reply
//   //             .map((m) => toTextMessage(m, _user, _ai))
//   //             .toList()
//   //             .reversed
//   //             .toList();
//   //   });
//   // }

//   void _handleSendPressed(types.PartialText message) async {
//     final now = DateTime.now().millisecondsSinceEpoch;
//     // 1. 立即添加用户消息
//     final userMessage = types.TextMessage(
//       id: const Uuid().v4(),
//       author: _user,
//       text: message.text,
//       createdAt: now,
//     );

//     // 2. 添加 AI 占位符消息
//     final thinkingMessage = types.TextMessage(
//       id: "thinking", // 固定 ID 用于后续替换
//       author: _ai,
//       text: "AI 正在思考中...",
//       createdAt: now + 1,
//     );

//     setState(() {
//       _messages.insert(0, thinkingMessage);
//       _messages.insert(0, userMessage);
//     });

//     try {
//       // 3. 调用 API 获取 AI 回复
//       final reply = await ChatService.sendMessage(
//         sessionId: widget.sessionId,
//         userMessage: message.text,
//       );

//       final List<types.TextMessage> newMessages =
//           reply
//               .map((m) => toTextMessage(m, _user, _ai))
//               .toList()
//               .reversed
//               .toList();

//       // final newMessages =
//       //     reply
//       //         .map((m) => toTextMessage(m, _user, _ai))
//       //         .toList()
//       //         .reversed
//       //         .toList();

//       //获取列表中最后一个AI回复
//       final types.TextMessage latesteAiReply = newMessages.firstWhere(
//         (m) => m.author.id == _ai.id,
//         orElse: () => thinkingMessage,
//       );

//       setState(() {
//         // 4. 替换“思考中...”消息
//         _messages.removeWhere((m) => m.id == "thinking");

//         // 5. 插入真实回复（可多轮）
//         _messages.insert(0, latesteAiReply);
//       });
//     } catch (e) {
//       // 如果出错，更新“思考中”为错误提示
//       setState(() {
//         _messages.removeWhere((m) => m.id == "thinking");
//         _messages.insert(
//           0,
//           types.TextMessage(
//             id: const Uuid().v4(),
//             author: _ai,
//             text: "❌ AI 回复失败，请稍后再试",
//             createdAt: DateTime.now().millisecondsSinceEpoch,
//           ),
//         );
//       });
//     }
//   }

//   void _handleExitChat() {
//     Navigator.pushReplacementNamed(context, "/");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFC),
//       appBar: AppBar(
//         elevation: 0,
//         title: const Text(
//           'AI 出牌助手',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//             fontSize: 18,
//           ),
//         ),
//         backgroundColor: const Color(0xFF0F172A),
//         automaticallyImplyLeading: false,
//         leading: IconButton(
//           onPressed: _handleExitChat,
//           icon: const Icon(Icons.logout, color: Colors.white),
//           tooltip: '退出会话',
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.only(top: 8.0),
//         child: ChatPageUI(
//           messages: _messages,
//           onSendPressed: _handleSendPressed,
//           user: _user,
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'package:frontend/services/chat_service.dart';
import 'package:frontend/utils/message_converter.dart';
import 'package:frontend/widgets/chat_page_ui.dart';

class ChatPage extends StatefulWidget {
  final String sessionId;
  const ChatPage({super.key, required this.sessionId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<types.TextMessage> _messages = [];
  final types.User _user = types.User(id: const Uuid().v4());
  final types.User _ai = const types.User(id: 'ai-1');

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() async {
    final history = await ChatService.fetchHistory(widget.sessionId);
    setState(() {
      _messages =
          history
              .map((m) => toTextMessage(m, _user, _ai))
              .toList()
              .reversed
              .toList();
    });
  }

  void _handleSendPressed(types.PartialText message) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final userMessage = types.TextMessage(
      id: const Uuid().v4(),
      author: _user,
      text: message.text,
      createdAt: now,
    );

    final thinkingMessage = types.TextMessage(
      id: "thinking",
      author: _ai,
      text: "AI 正在思考中...",
      createdAt: now + 1,
    );

    setState(() {
      _messages.insert(0, thinkingMessage);
      _messages.insert(0, userMessage);
    });

    try {
      final reply = await ChatService.sendMessage(
        sessionId: widget.sessionId,
        userMessage: message.text,
      );

      final newMessages =
          reply
              .map((m) => toTextMessage(m, _user, _ai))
              .toList()
              .reversed
              .toList();

      final latestAiReply = newMessages.firstWhere(
        (m) => m.author.id == _ai.id,
        orElse: () => thinkingMessage,
      );

      setState(() {
        _messages.removeWhere((m) => m.id == "thinking");
        _messages.insert(0, latestAiReply);
      });
    } catch (e) {
      setState(() {
        _messages.removeWhere((m) => m.id == "thinking");
        _messages.insert(
          0,
          types.TextMessage(
            id: const Uuid().v4(),
            author: _ai,
            text: "❌ AI 回复失败，请稍后再试",
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
      });
    }
  }

  void _handleExitChat() {
    Navigator.pushReplacementNamed(context, "/");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.auto_awesome, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  '川麻AI助手',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: _handleExitChat,
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: '退出会话',
            ),
          ],
        ),
      ),
      body: ChatPageUI(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: _user,
      ),
    );
  }
}
