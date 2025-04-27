// ✅ 原始设想版本的 auth_service.dart（逻辑封装、UI 控制交由页面）
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final log = Logger('AuthService');
  final _clinet = Supabase.instance.client;

  Future<bool> signIn(String email, String password) async {
    try {
      final response = await _clinet.auth.signInWithPassword(
        email: email,
        password: password,
      );
      log.info("✅ 登录成功：${response.user?.email}");
      return response.user != null;
    } on AuthException catch (e) {
      log.warning("❌ 登录失败（密码错误或用户不存在）：$e");
      throw AuthException("登录失败");
    } catch (e) {
      log.severe("❌ 登录未知错误：$e");
      throw Exception("未知错误：$e");
    }
  }

  Future<bool> signUp(String email, String password) async {
    try {
      final response = await _clinet.auth.signUp(
        email: email,
        password: password,
      );
      if (response.user != null) {
        log.info(
          "✉️ 尝试注册：${response.user?.email}。若收到验证邮件请完成验证，若无则可能邮箱已注册，请检查密码。",
        );
        return true;
      } else {
        log.warning("⚠️ 注册返回无 user");
        return false;
      }
    } catch (e) {
      log.severe("❌ 注册异常：$e");
      throw Exception("注册异常：$e");
    }
  }

  Future<bool> isEmailVerified() async {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.emailConfirmedAt != null;
  }

  Future<bool> refreshUserSession() async {
    try {
      final response = await _clinet.auth.refreshSession();
      final refreshedUser = response.user;
      if (refreshedUser != null && refreshedUser.emailConfirmedAt != null) {
        return true;
      }
      return false;
    } catch (e) {
      log.severe("❌ 刷新失败：$e");
      return false;
    }
  }

  Future<void> signOut() async {
    await _clinet.auth.signOut();
  }
}
