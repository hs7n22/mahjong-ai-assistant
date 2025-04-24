// ✅ 最终优化后的 auth_page.dart
import 'package:flutter/material.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/pages/home/home_page.dart';
import 'package:frontend/widgets/auth_form.dart';
import 'package:frontend/widgets/snackbar_helper.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final AuthService _authService = AuthService();

  Future<void> _signInOrSignUp(String email, String password) async {
    final loginSuccess = await _authService.signIn(email, password);
    if (loginSuccess) {
      if (!mounted) return;
      SnackbarHelper.show(context, "登录成功，欢迎用户：$email");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      final signUpSuccess = await _authService.signUp(email, password);
      if (!mounted) return;

      if (signUpSuccess) {
        final verified = await _authService.isEmailVerified();
        if (verified) {
          SnackbarHelper.show(context, "注册成功，欢迎用户: $email");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        } else {
          SnackbarHelper.show(context, "请前往邮箱完成验证后再登录");
        }
      } else {
        SnackbarHelper.showError(context, "注册失败，请稍后重试");
      }
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
      SnackbarHelper.show(context, "邮箱未验证，请完成验证后再试");
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
