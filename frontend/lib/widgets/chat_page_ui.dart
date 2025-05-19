// import 'package:flutter/material.dart';
// import 'package:flutter_chat_ui/flutter_chat_ui.dart';
// import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

// class ChatPageUI extends StatelessWidget {
//   final List<types.TextMessage> messages;
//   final void Function(types.PartialText) onSendPressed;
//   final types.User user;
//   const ChatPageUI({
//     super.key,
//     required this.messages,
//     required this.onSendPressed,
//     required this.user,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Chat(
//       messages: messages,
//       onSendPressed: onSendPressed,
//       user: user,
//       showUserAvatars: true,
//       showUserNames: true,
//       theme: const DefaultChatTheme(
//         inputBackgroundColor: Color(0xFF1E293B),
//         inputTextColor: Colors.white,
//         inputTextCursorColor: Colors.white,
//         sendButtonIcon: Icon(Icons.send, color: Colors.white),
//         primaryColor: Color(0xFF6366F1), //用户气泡背景
//         secondaryColor: Color(0xFFE2E8F0), //AI气泡背景
//         sentMessageBodyTextStyle: TextStyle(color: Colors.white, fontSize: 14),
//         receivedMessageBodyTextStyle: TextStyle(
//           color: Color(0xFF1E293B),
//           fontSize: 14,
//         ),
//         backgroundColor: Color(0xFFF1F5F9),
//         inputTextStyle: TextStyle(color: Colors.white, fontSize: 14),
//         inputBorderRadius: BorderRadius.all(Radius.circular(16)),
//         inputMargin: EdgeInsets.all(8),
//         inputPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         messageBorderRadius: 16,
//         messageInsetsHorizontal: 12,
//         messageInsetsVertical: 8,
//         sendButtonMargin: EdgeInsets.only(right: 8),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ChatPageUI extends StatelessWidget {
  final List<types.TextMessage> messages;
  final void Function(types.PartialText) onSendPressed;
  final types.User user;
  const ChatPageUI({
    super.key,
    required this.messages,
    required this.onSendPressed,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Chat(
      messages: messages,
      onSendPressed: onSendPressed,
      user: user,
      showUserAvatars: true,
      showUserNames: false,
      theme: const DefaultChatTheme(
        inputBackgroundColor: Color(0xFF1E1E1E),
        inputTextColor: Colors.white,
        inputTextCursorColor: Colors.white,
        sendButtonIcon: Icon(Icons.send, color: Colors.white),
        primaryColor: Color.fromARGB(210, 129, 130, 138),
        secondaryColor: Colors.white,
        sentMessageBodyTextStyle: TextStyle(color: Colors.white, fontSize: 14),
        receivedMessageBodyTextStyle: TextStyle(
          color: Color(0xFF1E1E1E),
          fontSize: 14,
        ),
        backgroundColor: Color(0xFF000000),
        inputTextStyle: TextStyle(color: Colors.white, fontSize: 14),
        inputBorderRadius: BorderRadius.all(Radius.circular(20)),
        inputMargin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        inputPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        messageBorderRadius: 16,
        messageInsetsHorizontal: 12,
        messageInsetsVertical: 8,
        sendButtonMargin: EdgeInsets.only(right: 8),
      ),
    );
  }
}
