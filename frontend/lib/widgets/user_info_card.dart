// ✅ lib/widgets/user_info_card.dart

import 'package:flutter/material.dart';

class UserInfoCard extends StatelessWidget {
  final String? email;
  final VoidCallback onSignOut;

  const UserInfoCard({super.key, required this.email, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            '欢迎你：${email ?? "未知"}',
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          onPressed: onSignOut,
          icon: const Icon(Icons.logout),
          tooltip: '退出登录',
        ),
      ],
    );
  }
}
