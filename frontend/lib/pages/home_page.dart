import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthPage()),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('登出失败：$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('用户主页'),
        actions: [
          IconButton(onPressed: signOut, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Center(
        child: Text(
          '欢迎您： ${user?.email ?? "未知"}',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
