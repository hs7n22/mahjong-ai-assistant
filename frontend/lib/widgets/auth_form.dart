// ✅ lib/widgets/auth_form.dart：使用 SnackbarHelper
import 'package:flutter/material.dart';
import 'package:frontend/widgets/snackbar_helper.dart';

class AuthForm extends StatefulWidget {
  final void Function(String email, String password) onSubmit;

  const AuthForm({super.key, required this.onSubmit});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _handleSubmit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isNotEmpty && password.isNotEmpty) {
      widget.onSubmit(email, password);
    } else {
      SnackbarHelper.show(context, "请输入邮箱和密码");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
          onSubmitted: (_) => _handleSubmit(),
        ),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: _handleSubmit, child: const Text("登录 / 注册")),
      ],
    );
  }
}
