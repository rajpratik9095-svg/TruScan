import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/step_counter_controller.dart';
import '../../config/theme.dart';

class StepCounterScreen extends StatelessWidget {
  const StepCounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller if not already
    if (!Get.isRegistered<StepCounterController>()) {
      Get.put(StepCounterController());
    }
    final controller = Get.find<StepCounterController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Step Counter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showGoalDialog(controller),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Main Step Counter Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGradientStart.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Circular Progress
                  Obx(() => Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: CircularProgressIndicator(
                          value: controller.progressPercent,
                          strokeWidth: 15,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.directions_walk, color: Colors.white, size: 40),
                          const SizedBox(height: 8),
                          Text(
                            '${controller.todaySteps.value}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '/ ${controller.dailyGoal.value} steps',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
                  const SizedBox(height: 24),
                  
                  // Status
                  Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          controller.isTracking.value ? Icons.sensors : Icons.sensors_off,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          controller.status.value,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 20),
                  
                  // Start/Stop Button
                  Obx(() => ElevatedButton.icon(
                    onPressed: () {
                      if (controller.isTracking.value) {
                        controller.stopTracking();
                      } else {
                        controller.startTracking();
                      }
                    },
                    icon: Icon(controller.isTracking.value ? Icons.stop : Icons.play_arrow),
                    label: Text(controller.isTracking.value ? 'Stop Tracking' : 'Start Tracking'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryGradientStart,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 24),


            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: Obx(() => _buildStatCard(
                    icon: Icons.local_fire_department,
                    value: '${controller.caloriesBurned.toStringAsFixed(0)}',
                    label: 'Calories',
                    color: Colors.orange,
                  )),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => _buildStatCard(
                    icon: Icons.straighten,
                    value: '${controller.distanceKm.toStringAsFixed(2)}',
                    label: 'Km',
                    color: Colors.blue,
                  )),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => _buildStatCard(
                    icon: Icons.timer,
                    value: controller.formattedTime,
                    label: 'Active',
                    color: Colors.green,
                  )),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Weekly Summary
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
                  const Text(
                    'Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Obx(() => _buildWeekStat(
                        'Weekly',
                        '${controller.weeklySteps.value}',
                        Icons.date_range,
                      )),
                      Obx(() => _buildWeekStat(
                        'Daily Avg',
                        '${controller.weeklyAverage.value}',
                        Icons.trending_up,
                      )),
                      Obx(() => _buildWeekStat(
                        'Monthly',
                        '${controller.monthlySteps.value}',
                        Icons.calendar_month,
                      )),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
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
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryGradientStart, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  void _showGoalDialog(StepCounterController controller) {
    final goalController = TextEditingController(
      text: controller.dailyGoal.value.toString(),
    );

    Get.dialog(
      AlertDialog(
        title: const Text('Set Daily Goal'),
        content: TextField(
          controller: goalController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Daily Steps Goal',
            suffixText: 'steps',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final goal = int.tryParse(goalController.text) ?? 10000;
              controller.setDailyGoal(goal);
              Get.back();
              Get.snackbar('Goal Updated', 'Daily goal set to $goal steps',
                  backgroundColor: AppTheme.success, colorText: Colors.white);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
