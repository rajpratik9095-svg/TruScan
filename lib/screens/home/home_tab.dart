import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../controllers/scanner_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/step_counter_controller.dart';
import '../../controllers/water_controller.dart';
import '../../widgets/product_card.dart';
import '../../config/theme.dart';
import '../scanner/product_details_screen.dart';
import '../notifications/notifications_screen.dart';
import '../steps/step_counter_screen.dart';
import '../water/water_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late ScannerController scannerController;
  late AuthController authController;
  late StepCounterController stepController;
  late WaterController waterController;

  @override
  void initState() {
    super.initState();
    scannerController = Get.find<ScannerController>();
    authController = Get.find<AuthController>();
    
    // Initialize controllers if not exists
    if (!Get.isRegistered<StepCounterController>()) {
      Get.put(StepCounterController());
    }
    if (!Get.isRegistered<WaterController>()) {
      Get.put(WaterController());
    }
    stepController = Get.find<StepCounterController>();
    waterController = Get.find<WaterController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Premium Header (simplified)
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(35),
                    bottomRight: Radius.circular(35),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${'welcome'.tr},',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          authController.currentUser.value?.name ?? 'User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )),
                    GestureDetector(
                      onTap: () => Get.to(() => const NotificationsScreen()),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Step Counter Widget (Today's Activity)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: GestureDetector(
                  onTap: () {
                    if (authController.isGuestUser) {
                      authController.showLoginRequired(feature: 'step_counter'.tr);
                    } else {
                      Get.to(() => const StepCounterScreen());
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade400, Colors.teal.shade400],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Step Circle
                            Obx(() => Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: CircularProgressIndicator(
                                    value: stepController.progressPercent,
                                    strokeWidth: 7,
                                    backgroundColor: Colors.white.withOpacity(0.3),
                                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${stepController.todaySteps.value}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'steps'.tr,
                                      style: const TextStyle(color: Colors.white70, fontSize: 10),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                            const SizedBox(width: 16),
                            
                            // Stats Column
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'todays_activity'.tr,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Obx(() => _buildMiniStat(
                                        Icons.local_fire_department,
                                        '${stepController.caloriesBurned.toStringAsFixed(0)}',
                                        'kcal',
                                      )),
                                      Obx(() => _buildMiniStat(
                                        Icons.straighten,
                                        '${stepController.distanceKm.toStringAsFixed(1)}',
                                        'km',
                                      )),
                                      Obx(() => _buildMiniStat(
                                        Icons.timer,
                                        stepController.formattedTime,
                                        '',
                                      )),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        
                        // Start/Stop Button
                        Obx(() => SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (authController.isGuestUser) {
                                authController.showLoginRequired(feature: 'step_counter'.tr);
                                return;
                              }
                              if (stepController.isTracking.value) {
                                stepController.stopTracking();
                              } else {
                                stepController.startTracking();
                              }
                            },
                            icon: Icon(
                              stepController.isTracking.value ? Icons.stop : Icons.play_arrow,
                              size: 18,
                            ),
                            label: Text(
                              stepController.isTracking.value ? 'stop_tracking'.tr : 'start_tracking'.tr,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.teal,
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Water Tracker Widget
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: GestureDetector(
                  onTap: () {
                    if (authController.isGuestUser) {
                      authController.showLoginRequired(feature: 'water_tracker'.tr);
                    } else {
                      Get.to(() => const WaterScreen());
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade400, Colors.cyan.shade400],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Water Progress
                        Obx(() => Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: CircularProgressIndicator(
                                value: waterController.progressPercent,
                                strokeWidth: 6,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                valueColor: const AlwaysStoppedAnimation(Colors.white),
                              ),
                            ),
                            const Icon(Icons.water_drop, color: Colors.white, size: 24),
                          ],
                        )),
                        const SizedBox(width: 16),
                        
                        // Water Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'water_intake'.tr,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Obx(() => Text(
                                '${waterController.todayMl.value} / ${waterController.dailyGoalMl.value} ml',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13,
                                ),
                              )),
                              Obx(() => Text(
                                '${waterController.todayGlasses.value} ${'glasses'.tr}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              )),
                            ],
                          ),
                        ),
                        
                        // Add Water Button
                        ElevatedButton(
                          onPressed: () {
                            if (authController.isGuestUser) {
                              authController.showLoginRequired(feature: 'water_tracker'.tr);
                            } else {
                              waterController.addWater();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          child: const Text('+💧', style: TextStyle(fontSize: 18)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'quick_actions'.tr,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickAction(
                            context,
                            Icons.qr_code_scanner,
                            'scan_product'.tr,
                            AppTheme.primaryGradient,
                            () => Get.find<HomeTabController>().changeTab(1),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickAction(
                            context,
                            Icons.restaurant_menu,
                            'diet_settings'.tr,
                            AppTheme.accentGradient,
                            () {
                              if (authController.isGuestUser) {
                                authController.showLoginRequired(feature: 'diet_settings'.tr);
                              } else {
                                Get.find<HomeTabController>().changeTab(2);
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

            // Weekly Summary
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'weekly_summary'.tr,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () => Get.to(() => const StepCounterScreen()),
                            child: Text('view_all'.tr),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Obx(() => _buildSummaryStat(
                            Icons.directions_walk,
                            '${stepController.weeklySteps.value}',
                            'steps'.tr,
                            Colors.green,
                          )),
                          Obx(() => _buildSummaryStat(
                            Icons.water_drop,
                            '${(waterController.getWeeklyTotal() / 1000).toStringAsFixed(1)}L',
                            'water'.tr,
                            Colors.blue,
                          )),
                          _buildSummaryStat(
                            Icons.qr_code,
                            '${scannerController.getScansThisWeek()}',
                            'scanner'.tr,
                            AppTheme.primaryGradientStart,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Recent Scans Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'recent_scans'.tr,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text('view_all'.tr),
                    ),
                  ],
                ),
              ),
            ),

            // Recent Scans List
            SliverToBoxAdapter(
              child: Obx(() {
                final recentScans = scannerController.getRecentScans(limit: 3);
                
                if (recentScans.isEmpty) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.qr_code_scanner_outlined, size: 50, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        const Text('No scans yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text('Start scanning products', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                      ],
                    ),
                  );
                }

                return Column(
                  children: recentScans.map((product) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ProductCard(
                      product: product,
                      onTap: () {
                        scannerController.currentProduct.value = product;
                        Get.to(() => const ProductDetailsScreen());
                      },
                    ),
                  )).toList(),
                );
              }),
            ),
            
            // Ad Banner (below Recent Scans)
            SliverToBoxAdapter(
              child: Builder(
                builder: (context) {
                  final storage = GetStorage();
                  final adsEnabled = storage.read('ads_enabled') ?? true;
                  
                  // Check if ads are temporarily disabled
                  final offUntilStr = storage.read<String>('ads_off_until');
                  if (offUntilStr != null) {
                    final offUntil = DateTime.tryParse(offUntilStr);
                    if (offUntil != null && DateTime.now().isBefore(offUntil)) {
                      return const SizedBox.shrink();
                    }
                  }
                  
                  if (!adsEnabled) return const SizedBox.shrink();
                  
                  return Container(
                    margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple.shade50, Colors.deepPurple.shade50],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.purple.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sponsored tag and close
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Sponsored',
                                style: TextStyle(fontSize: 10, color: Colors.purple, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                // Just rebuild without showing
                              },
                              child: Icon(Icons.close, size: 18, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Ad content
                        Row(
                          children: [
                            // Ad Image
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.star, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 14),
                            // Ad Text
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'TrueScan Premium',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Unlock all features! Remove ads, unlimited scans & more.',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Learn More button
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF667eea),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Learn', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String value, String unit) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        if (unit.isNotEmpty)
          Text(unit, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    IconData icon,
    String label,
    Gradient gradient,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStat(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }
}

// Controller for tab navigation
class HomeTabController extends GetxController {
  final RxInt currentIndex = 0.obs;
  
  void changeTab(int index) {
    currentIndex.value = index;
    update(); // Notify GetBuilder to rebuild
  }
}
