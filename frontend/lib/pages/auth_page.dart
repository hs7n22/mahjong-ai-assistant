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
  final user = Supabase.instance.client.auth.currentUser;

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
        ).showSnackBar(const SnackBar(content: Text("注册成功，请前往邮箱完整验证")));

        if (response.user?.emailChangeSentAt != null) {
          //✅ 注册成功并且已验证邮箱，跳转主页
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        } else {
          //  ❌注册后尚未验证邮箱
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("请前往邮箱完成验证后再登录")));
        }
      } catch (signUpError) {
        if (!mounted) return;

        log.severe("❌ 登录+注册都失败：$signUpError");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("登录或注册失败，请稍后重试")));
      }
    }
  }

  //刷新用户状态
  void refreshUserStatus() async {
    try {
      final response =
          await Supabase.instance.client.auth.refreshSession(); //🔁刷新session
      final refreshedUser = response.user;

      if (!mounted) return;

      if (refreshedUser != null) {
        if (refreshedUser.emailConfirmedAt != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("邮箱已验证，可以登录")));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("邮箱未验证，请完成验证后再试")));
        }
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("刷新失败: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("登录或注册"),
        actions: [
          IconButton(
            onPressed: refreshUserStatus,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
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
