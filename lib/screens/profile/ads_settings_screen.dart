import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../config/theme.dart';

class AdsSettingsScreen extends StatefulWidget {
  const AdsSettingsScreen({super.key});

  @override
  State<AdsSettingsScreen> createState() => _AdsSettingsScreenState();
}

class _AdsSettingsScreenState extends State<AdsSettingsScreen> {
  final storage = GetStorage();
  
  // Ad preferences
  bool healthAds = true;
  bool dietAds = true;
  bool technologyAds = true;
  bool shoppingAds = true;
  bool fitnessAds = true;
  
  // Ads off state
  bool adsOff = false;
  DateTime? adsOffUntil;
  DateTime? lastAdsOffTime;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() {
    healthAds = storage.read('ad_pref_health') ?? true;
    dietAds = storage.read('ad_pref_diet') ?? true;
    technologyAds = storage.read('ad_pref_technology') ?? true;
    shoppingAds = storage.read('ad_pref_shopping') ?? true;
    fitnessAds = storage.read('ad_pref_fitness') ?? true;
    
    // Check ads off state
    final offUntilStr = storage.read<String>('ads_off_until');
    final lastOffStr = storage.read<String>('last_ads_off_time');
    
    if (offUntilStr != null) {
      adsOffUntil = DateTime.tryParse(offUntilStr);
      if (adsOffUntil != null && DateTime.now().isBefore(adsOffUntil!)) {
        adsOff = true;
      } else {
        adsOff = false;
        storage.remove('ads_off_until');
      }
    }
    
    if (lastOffStr != null) {
      lastAdsOffTime = DateTime.tryParse(lastOffStr);
    }
    
    setState(() {});
  }

  bool _canTurnOffAds() {
    if (lastAdsOffTime == null) return true;
    
    // Check if 7 days have passed since last off
    final daysSinceLastOff = DateTime.now().difference(lastAdsOffTime!).inDays;
    return daysSinceLastOff >= 7;
  }

  int _daysUntilCanTurnOff() {
    if (lastAdsOffTime == null) return 0;
    final daysSinceLastOff = DateTime.now().difference(lastAdsOffTime!).inDays;
    return 7 - daysSinceLastOff;
  }

  Duration _getRemainingOffTime() {
    if (adsOffUntil == null) return Duration.zero;
    return adsOffUntil!.difference(DateTime.now());
  }

  void _toggleAdsOff() {
    if (adsOff) {
      // Turn ads back on
      setState(() {
        adsOff = false;
        storage.remove('ads_off_until');
        storage.write('ads_enabled', true);
      });
      Get.snackbar(
        'Ads Enabled',
        'Ads are now visible',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      // Try to turn off
      if (!_canTurnOffAds()) {
        final daysLeft = _daysUntilCanTurnOff();
        Get.snackbar(
          'Cannot Turn Off Ads',
          'You can turn off ads again in $daysLeft days',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      
      // Turn off for 1 day
      setState(() {
        adsOff = true;
        adsOffUntil = DateTime.now().add(const Duration(days: 1));
        lastAdsOffTime = DateTime.now();
        
        storage.write('ads_off_until', adsOffUntil!.toIso8601String());
        storage.write('last_ads_off_time', lastAdsOffTime!.toIso8601String());
        storage.write('ads_enabled', false);
      });
      
      Get.snackbar(
        'Ads Disabled',
        'Ads are hidden for 24 hours',
        backgroundColor: AppTheme.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _savePreference(String key, bool value) {
    storage.write('ad_pref_$key', value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ads Settings'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.campaign, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Personalize Your Ads',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Choose what type of ads you want to see',
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Ads Off Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        adsOff ? Icons.visibility_off : Icons.visibility,
                        color: adsOff ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Turn Off Ads',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Switch(
                        value: adsOff,
                        onChanged: (val) => _toggleAdsOff(),
                        activeColor: const Color(0xFF667eea),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (adsOff) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Ads off for ${_getRemainingOffTime().inHours}h ${_getRemainingOffTime().inMinutes % 60}m',
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Text(
                      _canTurnOffAds()
                          ? 'You can turn off ads for 24 hours'
                          : 'You can turn off ads again in ${_daysUntilCanTurnOff()} days',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Ad Preferences
            const Text(
              'Ad Preferences',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose what types of ads you want to see',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 16),
            
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                  _buildPreferenceItem(
                    icon: Icons.favorite,
                    title: 'Health & Wellness',
                    subtitle: 'Medical, supplements, health products',
                    color: Colors.red,
                    value: healthAds,
                    onChanged: (val) {
                      setState(() => healthAds = val);
                      _savePreference('health', val);
                    },
                  ),
                  _buildDivider(),
                  _buildPreferenceItem(
                    icon: Icons.restaurant,
                    title: 'Diet & Nutrition',
                    subtitle: 'Healthy food, recipes, diet plans',
                    color: Colors.green,
                    value: dietAds,
                    onChanged: (val) {
                      setState(() => dietAds = val);
                      _savePreference('diet', val);
                    },
                  ),
                  _buildDivider(),
                  _buildPreferenceItem(
                    icon: Icons.phone_android,
                    title: 'Technology',
                    subtitle: 'Apps, gadgets, tech products',
                    color: Colors.blue,
                    value: technologyAds,
                    onChanged: (val) {
                      setState(() => technologyAds = val);
                      _savePreference('technology', val);
                    },
                  ),
                  _buildDivider(),
                  _buildPreferenceItem(
                    icon: Icons.shopping_bag,
                    title: 'Shopping',
                    subtitle: 'Online stores, deals, offers',
                    color: Colors.orange,
                    value: shoppingAds,
                    onChanged: (val) {
                      setState(() => shoppingAds = val);
                      _savePreference('shopping', val);
                    },
                  ),
                  _buildDivider(),
                  _buildPreferenceItem(
                    icon: Icons.fitness_center,
                    title: 'Fitness',
                    subtitle: 'Gym, workout, sports products',
                    color: Colors.purple,
                    value: fitnessAds,
                    onChanged: (val) {
                      setState(() => fitnessAds = val);
                      _savePreference('fitness', val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Info Note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ads help keep TrueScan free. Thank you for your support!',
                      style: TextStyle(color: Colors.blue[700], fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF667eea),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, indent: 70, endIndent: 16, color: Colors.grey.withOpacity(0.2));
  }
}
