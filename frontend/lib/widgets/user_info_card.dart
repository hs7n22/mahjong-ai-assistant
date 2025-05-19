// // ✅ lib/widgets/user_info_card.dart

// import 'package:flutter/material.dart';

// class UserInfoCard extends StatelessWidget {
//   final String? email;
//   final VoidCallback onSignOut;
//   final Color color;

//   const UserInfoCard({
//     super.key,
//     required this.email,
//     required this.onSignOut,
//     this.color = Colors.black,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Expanded(
//           child: Text(
//             '欢迎你：${email ?? "未知"}',
//             style: TextStyle(fontSize: 16, color: color),
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//         IconButton(
//           onPressed: onSignOut,
//           icon: const Icon(Icons.logout),
//           tooltip: '退出登录',
//         ),
//       ],
//     );
//   }
// }

// ✅ 更新后的 user_info_card.dart（白色退出按钮）
import 'package:flutter/material.dart';

class UserInfoCard extends StatelessWidget {
  final String? email;
  final VoidCallback onSignOut;

  const UserInfoCard({super.key, required this.email, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
        onPressed: onSignOut,
        icon: const Icon(Icons.logout, color: Colors.white),
        tooltip: '退出登录',
      ),
    );
  }
}
