import 'package:flutter/material.dart';
import 'package:frontend/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';
import 'pages/auth_page.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();

  Logger.root.level = Level.ALL; //捕获所有等级
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('[${record.level.name}] ${record.time}: ${record.message}');
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    return MaterialApp(
      title: 'Mahjong AI Assistant',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: user == null ? const AuthPage() : const HomePage(), // 使用迁移后的页面
    );
  }
}
