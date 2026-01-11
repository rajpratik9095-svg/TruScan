import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

/// Connectivity Service
/// Monitors internet connection and provides connectivity status
class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  
  final RxBool isConnected = true.obs;
  final Rx<ConnectivityResult> connectionStatus = ConnectivityResult.wifi.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }
  
  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      print('Error checking connectivity: $e');
    }
  }
  
  void _updateConnectionStatus(ConnectivityResult result) {
    connectionStatus.value = result;
    isConnected.value = result != ConnectivityResult.none;
    
    if (isConnected.value) {
      print('📶 Connected to internet');
      Get.snackbar(
        'Connected',
        'You are back online',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } else {
      print('📵 No internet connection');
      Get.snackbar(
        'Offline',
        'Working in offline mode',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
