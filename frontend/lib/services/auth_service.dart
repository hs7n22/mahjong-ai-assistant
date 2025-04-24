// ✅ 原始设想版本的 auth_service.dart（逻辑封装、UI 控制交由页面）
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final log = Logger('AuthService');

  Future<bool> signIn(String email, String password) async {
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      log.info("✅ 登录成功：${response.user?.email}");
      return true;
    } catch (e) {
      log.warning("⚠️ 登录失败：$e");
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
      log.info("✅ 注册成功：${response.user?.email}");
      return true;
    } catch (e) {
      log.severe("❌ 注册失败：$e");
      return false;
    }
  }

  Future<bool> isEmailVerified() async {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.emailConfirmedAt != null;
  }

  Future<bool> refreshUserSession() async {
    try {
      final response = await Supabase.instance.client.auth.refreshSession();
      return response.user?.emailConfirmedAt != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }
}
