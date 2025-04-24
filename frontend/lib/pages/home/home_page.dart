// ✅ 更新后的 home_page.dart：使用封装的组件 + SnackbarHelper 提示
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/services/upload_service.dart';
import 'package:frontend/widgets/user_info_card.dart';
import 'package:frontend/widgets/image_upload_box.dart';
import 'package:frontend/widgets/snackbar_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Uint8List? _imageBytes;
  String? _fileName;
  String _uploadResult = "";
  late final UploadService _uploadService;

  @override
  void initState() {
    super.initState();
    _uploadService = UploadService();
  }

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
    } else {
      SnackbarHelper.show(context, "未选择图片");
    }
  }

  Future<void> _uploadImage() async {
    if (_imageBytes == null || _fileName == null) {
      SnackbarHelper.show(context, "请先选择图片");
      return;
    }

    final result = await _uploadService.uploadImage(
      imageBytes: _imageBytes!,
      fileName: _fileName!,
    );

    if (!mounted) return;

    setState(() {
      _uploadResult = '状态码: ${result.statusCode}\n返回值: ${result.body}';
    });

    SnackbarHelper.showSuccess(context, "图片上传成功");
  }

  void _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    SnackbarHelper.showSuccess(context, "已退出登录");
    Navigator.pushReplacementNamed(context, "/");
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('用户主页')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            UserInfoCard(email: user?.email, onSignOut: _signOut),
            const SizedBox(height: 20),
            ImageUploadBox(
              imageBytes: _imageBytes,
              fileName: _fileName,
              onPickImage: _pickImage,
              onUpload: _uploadImage,
              resultText: _uploadResult,
            ),
          ],
        ),
      ),
    );
  }
}
