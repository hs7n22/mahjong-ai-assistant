// // ✅ lib/widgets/image_upload_box.dart

// import 'dart:typed_data';
// import 'package:flutter/material.dart';

// class ImageUploadBox extends StatelessWidget {
//   final Uint8List? imageBytes;
//   final String? fileName;
//   final VoidCallback onPickImage;
//   final Future<void> Function() onUpload;
//   final String resultText;
//   final bool darkMode;

//   const ImageUploadBox({
//     super.key,
//     required this.imageBytes,
//     required this.fileName,
//     required this.onPickImage,
//     required this.onUpload,
//     required this.resultText,
//     this.darkMode = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final textColor = darkMode ? Colors.white : Colors.black;
//     return Column(
//       children: [
//         ElevatedButton(
//           onPressed: onPickImage,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: darkMode ? Colors.white : Colors.black,
//             foregroundColor: darkMode ? Colors.black : Colors.white,
//           ),
//           child: const Text("选择图片"),
//         ),
//         if (imageBytes != null) ...[
//           const SizedBox(height: 12),
//           Image.memory(imageBytes!, width: 300),
//           const SizedBox(height: 12),
//           ElevatedButton(
//             onPressed: onUpload,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: darkMode ? Colors.white : Colors.black,
//               foregroundColor: darkMode ? Colors.black : Colors.white,
//             ),
//             child: const Text("上传图片"),
//           ),
//         ],
//         const SizedBox(height: 12),
//         Text(resultText, style: TextStyle(color: textColor)),
//       ],
//     );
//   }
// }
// ✅ 更新后的 image_upload_box.dart（并排按钮 + 简洁样式）
// lib/widgets/image_upload_box.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageUploadBox extends StatelessWidget {
  final Uint8List? imageBytes;
  final String? fileName;
  final VoidCallback onPickImage;
  final Future<void> Function() onUpload;
  final VoidCallback onUpgrade;
  final String resultText;

  const ImageUploadBox({
    super.key,
    required this.imageBytes,
    required this.fileName,
    required this.onPickImage,
    required this.onUpload,
    required this.onUpgrade,
    required this.resultText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPickImage,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontSize: 16),
          ),
          child: const Text("选择图片"),
        ),
        if (imageBytes != null) ...[
          const SizedBox(height: 20),
          Image.memory(imageBytes!, width: 300),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: onUpload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text("上传图片"),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: onUpgrade,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text("开通会员 🚀"),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        Text(
          resultText,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
