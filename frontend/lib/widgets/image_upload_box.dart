// ✅ lib/widgets/image_upload_box.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageUploadBox extends StatelessWidget {
  final Uint8List? imageBytes;
  final String? fileName;
  final VoidCallback onPickImage;
  final Future<void> Function() onUpload;
  final String resultText;

  const ImageUploadBox({
    super.key,
    required this.imageBytes,
    required this.fileName,
    required this.onPickImage,
    required this.onUpload,
    required this.resultText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(onPressed: onPickImage, child: const Text("选择图片")),
        if (imageBytes != null) ...[
          const SizedBox(height: 12),
          Image.memory(imageBytes!, width: 300),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onUpload, child: const Text("上传图片")),
        ],
        const SizedBox(height: 12),
        Text(resultText),
      ],
    );
  }
}
