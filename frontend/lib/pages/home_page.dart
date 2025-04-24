import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// ignore: unused_import
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_page.dart';
// ignore: unused_import
import 'dart:convert';
import 'dart:typed_data';
import 'package:frontend/config.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Uint8List? _imageBytes;
  String? _fileName;
  String _uploadResult = "";

  void _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _imageBytes = result.files.single.bytes;
        _fileName = result.files.single.name;
      });
    }
  }

  void _uploadImage() async {
    if (_imageBytes == null || _fileName == null) return;

    final token = Supabase.instance.client.auth.currentSession?.accessToken;

    final request = http.MultipartRequest('POST', Uri.parse("$baseUrl/upload"));

    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      http.MultipartFile.fromBytes('file', _imageBytes!, filename: _fileName),
    );

    final response = await request.send();

    final resBody = await response.stream.bytesToString();

    setState(() {
      _uploadResult = '状态码： ${response.statusCode}\n返回值: $resBody';
    });
  }

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

  // void testProtectedRoute() async {
  //   final log = Logger('Auth');
  //   final token = Supabase.instance.client.auth.currentSession?.accessToken;
  //   final response = await http.get(
  //     Uri.parse("http://192.168.100.112:8000/protected"),
  //     headers: {"Authorization": "Bearer $token"},
  //   );
  //   final decoded = json.decode(utf8.decode(response.bodyBytes));
  //   log.info("🔐 Protected response: ${decoded['msg']}");
  //   log.info("📧 用户邮箱:${decoded['email']}");
  //   log.info("🆔 用户 ID:${decoded['user_id']}");
  //   log.info("🎭 用户角色:${decoded['role']}");
  // }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('用户主页'),
        actions: [
          IconButton(onPressed: signOut, icon: const Icon(Icons.logout)),
          // ElevatedButton(
          //   onPressed: testProtectedRoute,
          //   child: const Text("测试 /protected 接口"),
          // ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('欢迎你: ${user?.email ?? "未知"}'),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _pickImage, child: const Text("选择图片")),
            if (_imageBytes != null) ...[
              const SizedBox(height: 20),
              Image.memory(_imageBytes!, width: 300),
              ElevatedButton(
                onPressed: _uploadImage,
                child: const Text("上传图片"),
              ),
            ],
            const SizedBox(height: 20),
            Text(_uploadResult),
          ],
        ),
      ),
    );
  }
}
