// ✅ 最终优化后的 auth_page.dart
import 'package:flutter/material.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/pages/home/home_page.dart';
import 'package:frontend/widgets/auth_form.dart';
import 'package:frontend/widgets/snackbar_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final AuthService _authService = AuthService();

  Future<void> _signInOrSignUp(String email, String password) async {
    try {
      final loginSuccess = await _authService.signIn(email, password);
      if (loginSuccess) {
        if (!mounted) return;
        SnackbarHelper.show(context, "登录成功，欢迎用户：$email");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } on AuthException {
      //登录失败后尝试注册
      try {
        final signUpSuccess = await _authService.signUp(email, password);
        if (!mounted) return;

        if (signUpSuccess) {
          if (signUpSuccess) {
            SnackbarHelper.show(
              context,
              "登录失败，我们已为您尝试注册新账户。\n"
              "如果您收到验证邮件，请点击验证后继续使用。\n"
              "如果没有收到，请检查邮箱是否已注册并输入正确密码。",
            );
          }
        }
      } catch (e) {
        SnackbarHelper.show(context, "注册失败，请稍后重试。");
      }
    } catch (e) {
      SnackbarHelper.show(context, "未知错误：$e");
    }
  }

  Future<void> _refreshUserStatus() async {
    final verified = await _authService.refreshUserSession();
    if (!mounted) return;

    if (verified) {
      SnackbarHelper.showSuccess(context, "邮箱已验证，可以登录");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      SnackbarHelper.show(context, "邮箱未验证或无效会话");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("登录或注册"),
        actions: [
          IconButton(
            onPressed: _refreshUserStatus,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AuthForm(onSubmit: _signInOrSignUp),
      ),
    );
  }
}
