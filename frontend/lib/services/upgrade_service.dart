import 'package:frontend/services/api_service.dart';

class UpgradeService {
  Future<bool> upgradeToVip() async {
    final response = await ApiService.post('/upgrade', {});

    return response.isSuccess;
  }
}
