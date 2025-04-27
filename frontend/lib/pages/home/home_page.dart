// ✅ 更新后的 home_page.dart：使用封装的组件 + SnackbarHelper 提示
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/services/upload_service.dart';
import 'package:frontend/widgets/user_info_card.dart';
import 'package:frontend/widgets/image_upload_box.dart';
import 'package:frontend/widgets/snackbar_helper.dart';
import 'package:frontend/services/upgrade_service.dart';

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
  late final UpgradeService _upgradeService;

  @override
  void initState() {
    super.initState();
    _uploadService = UploadService();
    _upgradeService = UpgradeService();
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

    if (result.isSuccess) {
      SnackbarHelper.show(context, "✅ 上传成功！");
    } else if (result.statusCode == 403) {
      SnackbarHelper.show(context, "⚠️ 今日上传次数已用完，请升级会员");
    } else if (result.statusCode == 401) {
      SnackbarHelper.show(context, "❗ 请先登录！");
      //跳转至登录页面
      Navigator.pushReplacementNamed(context, "/");
    } else {
      SnackbarHelper.show(context, "❌ 上传失败，请稍后重试！");
    }
  }

  void _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    SnackbarHelper.showSuccess(context, "已退出登录");
    Navigator.pushReplacementNamed(context, "/");
  }

  Future<void> _upgradeToVip() async {
    final success = await _upgradeService.upgradeToVip();

    if (!mounted) return;

    if (success) {
      SnackbarHelper.show(context, "🎉 开通会员成功！");
      //
    } else {
      SnackbarHelper.show(context, "❌ 开通会员失败，请稍后再试！");
    }
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
            ElevatedButton(
              onPressed: _upgradeToVip,
              child: const Text("开通会员 🚀"),
            ),
          ],
        ),
      ),
    );
  }
}
