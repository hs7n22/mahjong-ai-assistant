// // ✅ lib/widgets/auth_form.dart：使用 SnackbarHelper
// import 'package:flutter/material.dart';
// import 'package:frontend/widgets/snackbar_helper.dart';

// class AuthForm extends StatefulWidget {
//   final void Function(String email, String password) onSubmit;

//   const AuthForm({super.key, required this.onSubmit});

//   @override
//   State<AuthForm> createState() => _AuthFormState();
// }

// class _AuthFormState extends State<AuthForm> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();

//   void _handleSubmit() {
//     final email = _emailController.text.trim();
//     final password = _passwordController.text.trim();
//     if (email.isNotEmpty && password.isNotEmpty) {
//       widget.onSubmit(email, password);
//     } else {
//       SnackbarHelper.show(context, "请输入邮箱和密码");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         TextField(
//           controller: _emailController,
//           decoration: const InputDecoration(labelText: 'Email'),
//         ),
//         TextField(
//           controller: _passwordController,
//           decoration: const InputDecoration(labelText: 'Password'),
//           obscureText: true,
//           onSubmitted: (_) => _handleSubmit(),
//         ),
//         const SizedBox(height: 20),
//         ElevatedButton(onPressed: _handleSubmit, child: const Text("登录 / 注册")),
//       ],
//     );
//   }
// }

// ✅ lib/widgets/auth_form.dart：使用 SnackbarHelper + 深色风格美化
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextField(
          controller: _emailController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: const TextStyle(color: Colors.white70),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white24),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Password',
            labelStyle: const TextStyle(color: Colors.white70),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white24),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          obscureText: true,
          onSubmitted: (_) => _handleSubmit(),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: const Text(
            "登录 / 注册",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
