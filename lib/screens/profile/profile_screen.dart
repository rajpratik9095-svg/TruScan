import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../controllers/auth_controller.dart';
import '../../config/theme.dart';
import 'edit_profile_screen.dart';
import 'scan_history_screen.dart';
import 'help_support_screen.dart';
import 'ads_settings_screen.dart';
import '../steps/step_counter_screen.dart';
import '../water/water_screen.dart';
import '../reminders/reminders_screen.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final storage = GetStorage();
  bool notificationsEnabled = true;
  String selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    notificationsEnabled = storage.read('notifications_enabled') ?? true;
    selectedLanguage = storage.read('app_language') ?? 'English';
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Profile Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  // Profile Picture
                  Obx(() {
                    final user = authController.currentUser.value;
                    return Stack(
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                                ? Image.network(
                                    user.avatarUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _buildDefaultAvatar(user.name),
                                  )
                                : _buildDefaultAvatar(user?.name ?? 'U'),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              if (authController.isGuestUser) {
                                authController.showLoginRequired(feature: 'edit_profile'.tr);
                              } else {
                                Get.to(() => const EditProfileScreen());
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: AppTheme.primaryGradientStart,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 16),
                  
                  // Name & Email
                  Obx(() {
                    final user = authController.currentUser.value;
                    return Column(
                      children: [
                        Text(
                          user?.name ?? 'User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 20),
                  
                  // Edit Profile Button
                  ElevatedButton.icon(
                    onPressed: () {
                      final auth = Get.find<AuthController>();
                      if (auth.isGuestUser) {
                        auth.showLoginRequired(feature: 'edit_profile'.tr);
                      } else {
                        Get.to(() => const EditProfileScreen());
                      }
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: Text('edit_profile'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryGradientStart,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Quick Access Cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'quick_access'.tr,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickCard(
                          icon: Icons.directions_walk,
                          title: 'steps'.tr,
                          subtitle: 'track_activity'.tr,
                          color: Colors.green,
                          onTap: () {
                            final auth = Get.find<AuthController>();
                            if (auth.isGuestUser) {
                              auth.showLoginRequired(feature: 'step_counter'.tr);
                            } else {
                              Get.to(() => const StepCounterScreen());
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickCard(
                          icon: Icons.water_drop,
                          title: 'water'.tr,
                          subtitle: 'stay_hydrated'.tr,
                          color: Colors.blue,
                          onTap: () {
                            final auth = Get.find<AuthController>();
                            if (auth.isGuestUser) {
                              auth.showLoginRequired(feature: 'water_tracker'.tr);
                            } else {
                              Get.to(() => const WaterScreen());
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Reminders Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: GestureDetector(
                onTap: () {
                  final auth = Get.find<AuthController>();
                  if (auth.isGuestUser) {
                    auth.showLoginRequired(feature: 'reminders'.tr);
                  } else {
                    Get.to(() => const RemindersScreen());
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade400, Colors.deepPurple.shade400],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.alarm, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'reminders'.tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'manage_reminders'.tr,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.7), size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Account Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'account'.tr,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          icon: Icons.history,
                          title: 'scan_history'.tr,
                          subtitle: 'view_scanned_products'.tr,
                          onTap: () {
                            final auth = Get.find<AuthController>();
                            if (auth.isGuestUser) {
                              auth.showLoginRequired(feature: 'scan_history'.tr);
                            } else {
                              Get.to(() => const ScanHistoryScreen());
                            }
                          },
                        ),
                        _buildDivider(),
                        _buildToggleItem(
                          icon: Icons.notifications_outlined,
                          title: 'notifications'.tr,
                          subtitle: notificationsEnabled ? 'enabled'.tr : 'disabled'.tr,
                          value: notificationsEnabled,
                          onChanged: (val) {
                            setState(() => notificationsEnabled = val);
                            storage.write('notifications_enabled', val);
                            Get.snackbar(
                              'Notifications ${val ? 'Enabled' : 'Disabled'}',
                              val ? 'You will receive reminders' : 'Reminders turned off',
                              backgroundColor: val ? AppTheme.success : Colors.grey,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(seconds: 2),
                            );
                          },
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.language,
                          title: 'language'.tr,
                          subtitle: selectedLanguage,
                          onTap: () => _showLanguageDialog(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Preferences Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'preferences'.tr,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildToggleItem(
                          icon: Icons.dark_mode_outlined,
                          title: 'dark_mode'.tr,
                          subtitle: isDark ? 'enabled'.tr : 'disabled'.tr,
                          value: isDark,
                          onChanged: (val) {
                            Get.changeThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                            storage.write('dark_mode', val);
                          },
                        ),
                        _buildDivider(),
                        // Ads Settings
                        _buildMenuItem(
                          icon: Icons.campaign_outlined,
                          title: 'Ads Settings',
                          subtitle: 'Preferences & turn off ads',
                          onTap: () => Get.to(() => const AdsSettingsScreen()),
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.help_outline,
                          title: 'help_support'.tr,
                          subtitle: 'faq_contact'.tr,
                          onTap: () => Get.to(() => const HelpSupportScreen()),
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.privacy_tip_outlined,
                          title: 'privacy_policy'.tr,
                          subtitle: 'terms_conditions'.tr,
                          onTap: () => _showPrivacyPolicy(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Logout/Sign In Button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Obx(() {
                final isGuest = authController.isGuestUser;
                return ElevatedButton.icon(
                  onPressed: () {
                    if (isGuest) {
                      // Guest user - take to login
                      authController.isGuest.value = false;
                      Get.offAll(() => const LoginScreen());
                    } else {
                      // Logged in user - show logout dialog
                      _showLogoutDialog(authController);
                    }
                  },
                  icon: Icon(isGuest ? Icons.login : Icons.logout, size: 20),
                  label: Text(isGuest ? 'Sign In' : 'logout'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isGuest 
                        ? const Color(0xFF667eea).withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    foregroundColor: isGuest 
                        ? const Color(0xFF667eea)
                        : Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                );
              }),
            ),
          ),

          // App Version
          SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Text(
                  'TrueScan v1.0.0',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    final languages = [
      {'code': 'en_US', 'name': 'English', 'flag': '🇺🇸'},
      {'code': 'hi_IN', 'name': 'हिंदी (Hindi)', 'flag': '🇮🇳'},
      {'code': 'bn_BD', 'name': 'বাংলা (Bengali)', 'flag': '🇧🇩'},
      {'code': 'es_ES', 'name': 'Español (Spanish)', 'flag': '🇪🇸'},
      {'code': 'fr_FR', 'name': 'Français (French)', 'flag': '🇫🇷'},
      {'code': 'ar_SA', 'name': 'العربية (Arabic)', 'flag': '🇸🇦'},
      {'code': 'pt_BR', 'name': 'Português (Portuguese)', 'flag': '🇧🇷'},
      {'code': 'ta_IN', 'name': 'தமிழ் (Tamil)', 'flag': '🇮🇳'},
      {'code': 'te_IN', 'name': 'తెలుగు (Telugu)', 'flag': '🇮🇳'},
    ];
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('language'.tr, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
              ],
            ),
            const SizedBox(height: 16),
            ...languages.map((lang) {
              final isSelected = selectedLanguage == lang['name'];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                leading: Text(lang['flag']!, style: const TextStyle(fontSize: 28)),
                title: Text(
                  lang['name']!,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppTheme.primaryGradientStart : Colors.black87,
                    fontSize: 16,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: AppTheme.primaryGradientStart, size: 28)
                    : const Icon(Icons.circle_outlined, color: Colors.grey, size: 28),
                onTap: () {
                  final code = lang['code']!;
                  final parts = code.split('_');
                  final locale = Locale(parts[0], parts.length > 1 ? parts[1] : '');
                  
                  Get.updateLocale(locale);
                  setState(() => selectedLanguage = lang['name']!);
                  storage.write('app_language', lang['name']);
                  storage.write('app_locale', code);
                  Get.back();
                  Get.snackbar(
                    'language_changed'.tr,
                    '${'app_language_set'.tr} ${lang['name']}',
                    backgroundColor: AppTheme.success,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              );
            }),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicy() {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Privacy Policy', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
              ],
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPolicySection('1. Data Collection', 
                      'TrueScan collects product barcode data, scan history, and user preferences to provide personalized recommendations. We also collect basic account information like name and email for authentication.'),
                    _buildPolicySection('2. Data Usage',
                      'Your data is used to: \n• Show your scan history\n• Provide health recommendations\n• Track your water and step goals\n• Improve app functionality'),
                    _buildPolicySection('3. Data Storage',
                      'All data is securely stored using Supabase cloud services. Local data is stored on your device using encrypted storage.'),
                    _buildPolicySection('4. Third Party Services',
                      'We use:\n• Supabase for authentication and database\n• Open Food Facts API for product information'),
                    _buildPolicySection('5. Your Rights',
                      'You can:\n• Request data deletion\n• Export your data\n• Opt-out of notifications\n• Delete your account anytime'),
                    _buildPolicySection('6. Contact Us',
                      'For privacy concerns, contact us at:\nprivacy@truescan.app'),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'Last updated: January 2026',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildPolicySection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          Text(content, style: TextStyle(color: Colors.grey[700], height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(String name) {
    return Container(
      color: AppTheme.primaryGradientEnd,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.primaryGradientStart.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.primaryGradientStart, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.primaryGradientStart.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.primaryGradientStart, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryGradientStart,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, indent: 70, endIndent: 20, color: Colors.grey.withOpacity(0.2));
  }

  void _showLogoutDialog(AuthController authController) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              authController.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
