import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          Text(
            'Appearance',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryGradientStart,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          // Theme Toggle
          Card(
            child: Obx(() => SwitchListTile(
                  secondary: Icon(
                    settingsController.isDarkMode.value
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    color: AppTheme.primaryGradientStart,
                  ),
                  title: Text('theme'.tr),
                  subtitle: Text(settingsController.isDarkMode.value
                      ? 'dark_mode'.tr
                      : 'light_mode'.tr),
                  value: settingsController.isDarkMode.value,
                  onChanged: (value) => settingsController.toggleTheme(),
                  activeColor: AppTheme.primaryGradientStart,
                )),
          ),
          const SizedBox(height: 12),

          // Language Selection
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.language,
                color: AppTheme.primaryGradientStart,
              ),
              title: Text('language'.tr),
              subtitle: Obx(() => Text(
                    settingsController.currentLanguage.value == 'en_US'
                        ? 'english'.tr
                        : 'hindi'.tr,
                  )),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showLanguageDialog(context, settingsController),
            ),
          ),

          const SizedBox(height: 24),

          // Notifications Section
          Text(
            'notifications'.tr,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryGradientStart,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          // Push Notifications
          Card(
            child: Obx(() => SwitchListTile(
                  secondary: const Icon(
                    Icons.notifications_outlined,
                    color: AppTheme.primaryGradientStart,
                  ),
                  title: Text('push_notifications'.tr),
                  subtitle: const Text('Receive product scan alerts'),
                  value: settingsController.pushNotifications.value,
                  onChanged: settingsController.togglePushNotifications,
                  activeColor: AppTheme.primaryGradientStart,
                )),
          ),
          const SizedBox(height: 12),

          // Email Notifications
          Card(
            child: Obx(() => SwitchListTile(
                  secondary: const Icon(
                    Icons.email_outlined,
                    color: AppTheme.primaryGradientStart,
                  ),
                  title: Text('email_notifications'.tr),
                  subtitle: const Text('Receive weekly health tips'),
                  value: settingsController.emailNotifications.value,
                  onChanged: settingsController.toggleEmailNotifications,
                  activeColor: AppTheme.primaryGradientStart,
                )),
          ),

          const SizedBox(height: 24),

          // Data & Storage Section
          Text(
            'Data & Storage',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryGradientStart,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          // Clear Cache
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: AppTheme.error,
              ),
              title: Text('clear_cache'.tr),
              subtitle: const Text('Remove temporary files and data'),
              onTap: () => _showClearCacheDialog(context, settingsController),
            ),
          ),

          const SizedBox(height: 24),

          // About Section
          Text(
            'about'.tr,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryGradientStart,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          // Terms & Conditions
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.description_outlined,
                color: AppTheme.primaryGradientStart,
              ),
              title: Text('terms_conditions'.tr),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to terms & conditions
              },
            ),
          ),
          const SizedBox(height: 12),

          // Privacy Policy
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.privacy_tip_outlined,
                color: AppTheme.primaryGradientStart,
              ),
              title: Text('privacy'.tr),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to privacy policy
              },
            ),
          ),
          const SizedBox(height: 12),

          // Version
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.info_outline,
                color: AppTheme.primaryGradientStart,
              ),
              title: Text('version'.tr),
              subtitle: Text(AppConstants.appVersion),
            ),
          ),

          const SizedBox(height: 32),

          // App Info Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.qr_code_scanner,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                Text(
                  AppConstants.appName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Scan products, track nutrition, stay healthy',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('select_language'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text('english'.tr),
              value: 'en_US',
              groupValue: controller.currentLanguage.value,
              onChanged: (value) {
                if (value != null) {
                  controller.changeLanguage(value);
                  Get.back();
                }
              },
              activeColor: AppTheme.primaryGradientStart,
            ),
            RadioListTile<String>(
              title: Text('hindi'.tr),
              value: 'hi_IN',
              groupValue: controller.currentLanguage.value,
              onChanged: (value) {
                if (value != null) {
                  controller.changeLanguage(value);
                  Get.back();
                }
              },
              activeColor: AppTheme.primaryGradientStart,
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context, SettingsController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('clear_cache'.tr),
        content: const Text('This will remove all cached data. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              controller.clearCache();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
