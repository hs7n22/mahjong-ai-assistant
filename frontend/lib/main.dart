import 'package:flutter/material.dart';
import 'package:frontend/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';
import 'pages/auth/auth_page.dart';
import 'pages/home/home_page.dart';
import 'pages/chat/chat_page.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'pages/payment/payment_success_page.dart';
import 'pages/payment/payment_cancel_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();

  Logger.root.level = Level.ALL; //捕获所有等级
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('[${record.level.name}] ${record.time}: ${record.message}');
  });
  setUrlStrategy(PathUrlStrategy());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mahjong AI Assistant',
      theme: ThemeData(primarySwatch: Colors.blue),
      onGenerateRoute: (settings) {
        //首页路有逻辑控制
        if (settings.name == '/') {
          final user = Supabase.instance.client.auth.currentUser;
          return MaterialPageRoute(
            builder: (_) => user == null ? const AuthPage() : const HomePage(),
          );
        }
        if (settings.name == '/chat') {
          final args = settings.arguments as Map?;
          final sessionId = args?['sessionId'] ?? 'default-session';
          return MaterialPageRoute(
            builder: (_) => ChatPage(sessionId: sessionId),
          );
        }
        if (settings.name == '/payment-cancel') {
          return MaterialPageRoute(builder: (_) => const PaymentCancelPage());
        }
        if (settings.name == '/payment-success') {
          return MaterialPageRoute(builder: (_) => PaymentSuccessPage());
        }
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text('页面不存在'))),
        ); //默认按 routes 查找
      },
    );
  }
}
