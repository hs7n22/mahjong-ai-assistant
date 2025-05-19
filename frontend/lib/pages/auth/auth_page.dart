//
// ✅ lib/pages/auth_page.dart 深色 UI 改造版
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
      try {
        final signUpSuccess = await _authService.signUp(email, password);
        if (!mounted) return;

        if (signUpSuccess) {
          SnackbarHelper.show(
            context,
            "登录失败，我们已为您尝试注册新账户。\n"
            "如果您收到验证邮件，请点击验证后继续使用。\n"
            "如果没有收到，请检查邮箱是否已注册并输入正确密码。",
          );
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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部 Logo
              Row(
                children: const [
                  Icon(Icons.auto_awesome, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "川麻AI助手",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // 中部标题
              const Center(
                child: Column(
                  children: [
                    Text(
                      '川麻AI助手',
                      style: TextStyle(
                        fontSize: 36,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '登录或注册后即可上传麻将牌面，由 AI 分析出牌建议',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32),
                  ],
                ),
              ),
              // 表单
              AuthForm(onSubmit: _signInOrSignUp),
              const Spacer(),
              // 重新验证提示按钮
              Center(
                child: TextButton(
                  onPressed: _refreshUserStatus,
                  style: TextButton.styleFrom(foregroundColor: Colors.white70),
                  child: const Text("已验证邮箱？点此继续登录 ⟳"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
