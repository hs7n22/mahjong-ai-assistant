import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:frontend/services/stripe_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/services/upload_service.dart';
import 'package:frontend/widgets/user_info_card.dart';
import 'package:frontend/widgets/image_upload_box.dart';
import 'package:frontend/widgets/snackbar_helper.dart';
// import 'package:frontend/services/upgrade_service.dart';

final user = Supabase.instance.client.auth.currentUser;
bool isVip = false;

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
  // late final UpgradeService _upgradeService;
  late final StripeService _stripeService;

  @override
  void initState() {
    super.initState();
    _uploadService = UploadService();
    // _upgradeService = UpgradeService();
    _stripeService = StripeService();
    _fetchVipStatus();
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
      _uploadResult = '状态码: \${result.statusCode}\n返回值: \${result.body}';
    });

    if (result.isSuccess) {
      SnackbarHelper.show(context, "✅ 上传成功！");

      final sessionId = jsonDecode(result.body)['session_id'];
      Navigator.pushReplacementNamed(
        context,
        "/chat",
        arguments: {'sessionId': sessionId},
      );
    } else if (result.statusCode == 403) {
      SnackbarHelper.show(context, "⚠️ 今日上传次数已用完，请升级会员");
    } else if (result.statusCode == 401) {
      SnackbarHelper.show(context, "❗ 请先登录！");
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

  // Future<void> _upgradeToVip() async {
  //   final success = await _upgradeService.upgradeToVip();

  //   if (!mounted) return;

  //   if (success) {
  //     SnackbarHelper.show(context, "🎉 开通会员成功！");
  //   } else {
  //     SnackbarHelper.show(context, "❌ 开通会员失败，请稍后再试！");
  //   }
  // }
  //无需调用原来的UpgradeService.upgradeToVip()，新逻辑由webhook处理
  Future<void> _upgradeToVip() async {
    try {
      await _stripeService.startCheckout();
    } catch (e) {
      SnackbarHelper.show(context, "❌ 创建支付失败，请稍后再试！");
    }
  }

  Future<void> _fetchVipStatus() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      final response =
          await Supabase.instance.client
              .from('profiles')
              .select('is_vip')
              .eq('id', userId)
              .single();
      if (mounted && response['is_vip'] == true) {
        setState(() {
          isVip = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部栏
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text(
                        "川麻AI助手",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.menu, color: Colors.white),
                      ),
                    ],
                  ),
                  UserInfoCard(email: user?.email, onSignOut: _signOut),
                ],
              ),
              const Spacer(),
              const Center(
                child: Column(
                  children: [
                    Text(
                      '川麻AI助手',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "AI Mahjong Assistant",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '上传你的麻将牌面截图，AI 将立即分析并给出最佳建议。',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '欢迎你：1052848001@qq.com',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    SizedBox(height: 32),
                  ],
                ),
              ),
              Center(
                child: ImageUploadBox(
                  imageBytes: _imageBytes,
                  fileName: _fileName,
                  onPickImage: _pickImage,
                  onUpload: _uploadImage,
                  resultText: _uploadResult,
                  onUpgrade: _upgradeToVip,
                  isVip: isVip,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
