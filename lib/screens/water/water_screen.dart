import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/water_controller.dart';
import '../../config/theme.dart';

class WaterScreen extends StatelessWidget {
  const WaterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<WaterController>()) {
      Get.put(WaterController());
    }
    final controller = Get.find<WaterController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettingsDialog(controller),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Main Water Progress
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.cyan.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Obx(() => Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: CircularProgressIndicator(
                          value: controller.progressPercent,
                          strokeWidth: 14,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.water_drop, color: Colors.white, size: 36),
                          const SizedBox(height: 8),
                          Text(
                            '${controller.todayMl.value}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'of ${controller.dailyGoalMl.value} ml',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
                  const SizedBox(height: 24),
                  
                  // Glass count
                  Obx(() => Text(
                    '${controller.todayGlasses.value} glasses today',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  )),
                  const SizedBox(height: 20),
                  
                  // Quick Add Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickAddButton(controller, 150, '150ml'),
                      _buildQuickAddButton(controller, 250, '250ml'),
                      _buildQuickAddButton(controller, 500, '500ml'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stats Row
            Row(
              children: [
                Expanded(
                  child: Obx(() => _buildStatCard(
                    icon: Icons.flag,
                    value: '${controller.remainingMl}',
                    label: 'Remaining (ml)',
                    color: Colors.orange,
                  )),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => _buildStatCard(
                    icon: Icons.show_chart,
                    value: '${controller.getWeeklyAverage().toStringAsFixed(0)}',
                    label: 'Daily Avg (ml)',
                    color: Colors.green,
                  )),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Today's Intake History
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
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
                      const Text(
                        'Today\'s History',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Obx(() => Text(
                        '${controller.todayIntakes.length} entries',
                        style: TextStyle(color: Colors.grey[600]),
                      )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    if (controller.todayIntakes.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Icon(Icons.water_drop_outlined, size: 50, color: Colors.grey[300]),
                              const SizedBox(height: 12),
                              Text('No water logged yet', style: TextStyle(color: Colors.grey[500])),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    return Column(
                      children: controller.todayIntakes.take(5).map((intake) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.water_drop, color: Colors.blue),
                          ),
                          title: Text('${intake['ml_amount']} ml'),
                          subtitle: Text(intake['intake_time'] ?? ''),
                          trailing: const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        );
                      }).toList(),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Reminder Settings
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications_active, color: Colors.blue),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Water Reminders',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Obx(() => Switch(
                        value: controller.reminderEnabled.value,
                        onChanged: (val) => controller.setReminderEnabled(val),
                        activeColor: Colors.blue,
                      )),
                    ],
                  ),
                  Obx(() => controller.reminderEnabled.value
                      ? Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            'Remind every ${controller.reminderInterval.value} minutes',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
                      : const SizedBox()),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.addWater(),
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Obx(() => Text(
          'Add ${controller.glassSize.value}ml',
          style: const TextStyle(color: Colors.white),
        )),
      ),
    );
  }

  Widget _buildQuickAddButton(WaterController controller, int ml, String label) {
    return ElevatedButton(
      onPressed: () => controller.addWater(ml: ml),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.2),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      child: Text(label),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(WaterController controller) {
    final goalController = TextEditingController(
      text: controller.dailyGoalMl.value.toString(),
    );
    final glassController = TextEditingController(
      text: controller.glassSize.value.toString(),
    );

    Get.dialog(
      AlertDialog(
        title: const Text('Water Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: goalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Daily Goal (ml)',
                suffixText: 'ml',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: glassController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Glass Size (ml)',
                suffixText: 'ml',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final goal = int.tryParse(goalController.text) ?? 2000;
              final glass = int.tryParse(glassController.text) ?? 250;
              controller.setDailyGoal(goal);
              controller.setGlassSize(glass);
              Get.back();
              Get.snackbar('Saved', 'Water settings updated',
                  backgroundColor: AppTheme.success, colorText: Colors.white);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
