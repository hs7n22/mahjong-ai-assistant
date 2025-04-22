import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final log = Logger('Auth');

  void signInOrSignUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (!mounted) return; //检查是否还在树上

      log.info("✅ 登录成功：${response.user!.email}");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("登录成功")));

      //✅ 登录成功后跳转主页
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (signInError) {
      log.warning("⚠️ 登录失败，尝试注册中...");

      try {
        final response = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );

        if (!mounted) return;

        log.info("✅ 注册成功：${response.user?.email}");

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("注册成功")));

        // ✅ 注册成功后跳转主页
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } catch (signUpError) {
        if (!mounted) return;

        log.severe("❌ 登录+注册都失败：$signUpError");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("登录或注册失败，请稍后重试")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("登录或注册")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              onSubmitted: (_) => signInOrSignUp(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: signInOrSignUp,
              child: const Text("登录 / 注册"),
            ),
          ],
        ),
      ),
    );
  }
}
