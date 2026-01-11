import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import '../config/constants.dart';

class SettingsController extends GetxController {
  final storage = GetStorage();
  
  final RxString currentLanguage = 'en_US'.obs;
  final RxBool isDarkMode = false.obs;
  final RxBool pushNotifications = true.obs;
  final RxBool emailNotifications = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    currentLanguage.value = storage.read(AppConstants.storageKeyLanguage) ?? AppConstants.defaultLanguage;
    isDarkMode.value = storage.read(AppConstants.storageKeyTheme) ?? AppConstants.defaultDarkMode;
    
    // Set initial locale
    Get.updateLocale(Locale(currentLanguage.value.split('_')[0], currentLanguage.value.split('_')[1]));
  }

  void changeLanguage(String languageCode) {
    currentLanguage.value = languageCode;
    storage.write(AppConstants.storageKeyLanguage, languageCode);
    
    // Update app locale
    final parts = languageCode.split('_');
    Get.updateLocale(Locale(parts[0], parts[1]));
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    storage.write(AppConstants.storageKeyTheme, isDarkMode.value);
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void togglePushNotifications(bool value) {
    pushNotifications.value = value;
  }

  void toggleEmailNotifications(bool value) {
    emailNotifications.value = value;
  }

  void clearCache() {
    storage.remove(AppConstants.storageKeyScannedProducts);
    storage.remove(AppConstants.storageKeyDietEntries);
    Get.snackbar(
      'success'.tr,
      'cache_cleared'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}
