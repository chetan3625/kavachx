import 'package:get/get.dart';
import 'package:kavachx/Services/api_service.dart';

class OwnerDashboardController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxInt selectedBottomIndex = 0.obs;
  final RxString gymName = 'Kavach Fitness'.obs;
  final RxInt todayCheckIns = 0.obs;
  final RxInt pendingRequestsCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardStats();
  }

  Future<void> fetchDashboardStats() async {
    try {
      final response = await _apiService.getJoinRequests();
      if (response.isOk && response.body != null) {
        final List requests = response.body['data'] ?? [];
        pendingRequestsCount.value = requests.length;
      }
    } catch (e) {
      // Keep previous count on error
    }
  }

  void logoutOwner() {
    _apiService.clearAuthData();
    Get.offAllNamed('/splash');
  }
}