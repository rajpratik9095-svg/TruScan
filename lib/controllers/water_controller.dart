import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../services/supabase_service.dart';

class WaterController extends GetxController {
  final storage = GetStorage();
  
  // Observable values
  final RxInt todayGlasses = 0.obs;
  final RxInt todayMl = 0.obs;
  final RxInt dailyGoalMl = 2000.obs; // 2 liters default
  final RxInt glassSize = 250.obs; // 250ml per glass
  final RxBool reminderEnabled = true.obs;
  final RxInt reminderInterval = 60.obs; // minutes
  final RxList<Map<String, dynamic>> todayIntakes = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> weeklyData = <Map<String, dynamic>>[].obs;
  
  Timer? _reminderTimer;
  
  // Storage keys
  static const String _keyDailyGoal = 'water_daily_goal';
  static const String _keyGlassSize = 'water_glass_size';
  static const String _keyReminderEnabled = 'water_reminder_enabled';
  static const String _keyReminderInterval = 'water_reminder_interval';
  static const String _keyLastIntakeDate = 'water_last_date';
  static const String _keyTodayGlasses = 'water_today_glasses';
  static const String _keyTodayMl = 'water_today_ml';

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    _loadTodayData();
    _startReminderTimer();
  }

  @override
  void onClose() {
    _reminderTimer?.cancel();
    super.onClose();
  }

  void _loadSettings() {
    dailyGoalMl.value = storage.read(_keyDailyGoal) ?? 2000;
    glassSize.value = storage.read(_keyGlassSize) ?? 250;
    reminderEnabled.value = storage.read(_keyReminderEnabled) ?? true;
    reminderInterval.value = storage.read(_keyReminderInterval) ?? 60;
  }

  Future<void> _loadTodayData() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastDate = storage.read(_keyLastIntakeDate);
    
    // Reset if new day
    if (lastDate != today) {
      todayGlasses.value = 0;
      todayMl.value = 0;
      storage.write(_keyLastIntakeDate, today);
      storage.write(_keyTodayGlasses, 0);
      storage.write(_keyTodayMl, 0);
    } else {
      todayGlasses.value = storage.read(_keyTodayGlasses) ?? 0;
      todayMl.value = storage.read(_keyTodayMl) ?? 0;
    }
    
    // Load from Supabase if logged in
    await _syncFromSupabase();
  }

  Future<void> _syncFromSupabase() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return;
    
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      
      // Get today's intakes
      final response = await SupabaseService.client
          .from('water_intake')
          .select()
          .eq('user_id', userId)
          .eq('intake_date', today)
          .order('intake_time', ascending: false);
      
      if (response != null && response.isNotEmpty) {
        todayIntakes.value = List<Map<String, dynamic>>.from(response);
        
        int totalMl = 0;
        for (var intake in response) {
          totalMl += (intake['ml_amount'] as int?) ?? 0;
        }
        
        todayMl.value = totalMl;
        todayGlasses.value = (totalMl / glassSize.value).floor();
        
        // Save locally
        storage.write(_keyTodayGlasses, todayGlasses.value);
        storage.write(_keyTodayMl, todayMl.value);
      }
      
      // Get weekly data
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final weekResponse = await SupabaseService.client
          .from('water_intake')
          .select()
          .eq('user_id', userId)
          .gte('intake_date', weekAgo.toIso8601String().substring(0, 10));
      
      if (weekResponse != null) {
        weeklyData.value = List<Map<String, dynamic>>.from(weekResponse);
      }
    } catch (e) {
      print('Error syncing water data: $e');
    }
  }

  Future<void> addWater({int? ml}) async {
    final amount = ml ?? glassSize.value;
    todayMl.value += amount;
    todayGlasses.value = (todayMl.value / glassSize.value).floor();
    
    // Save locally
    storage.write(_keyTodayGlasses, todayGlasses.value);
    storage.write(_keyTodayMl, todayMl.value);
    
    // Save to Supabase
    final userId = SupabaseService.currentUser?.id;
    if (userId != null) {
      try {
        final now = DateTime.now();
        await SupabaseService.client.from('water_intake').insert({
          'user_id': userId,
          'glasses': 1,
          'ml_amount': amount,
          'intake_date': now.toIso8601String().substring(0, 10),
          'intake_time': '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
          'synced': true,
        });
        
        // Add to local list
        todayIntakes.insert(0, {
          'ml_amount': amount,
          'intake_time': '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        });
      } catch (e) {
        print('Error saving water intake: $e');
      }
    }
  }

  Future<void> removeWater({int? ml}) async {
    final amount = ml ?? glassSize.value;
    todayMl.value = (todayMl.value - amount).clamp(0, 10000);
    todayGlasses.value = (todayMl.value / glassSize.value).floor();
    
    storage.write(_keyTodayGlasses, todayGlasses.value);
    storage.write(_keyTodayMl, todayMl.value);
  }

  void _startReminderTimer() {
    _reminderTimer?.cancel();
    
    if (!reminderEnabled.value) return;
    
    _reminderTimer = Timer.periodic(
      Duration(minutes: reminderInterval.value),
      (_) => _showReminder(),
    );
  }

  void _showReminder() {
    if (!reminderEnabled.value) return;
    if (todayMl.value >= dailyGoalMl.value) return; // Goal reached
    
    final remaining = dailyGoalMl.value - todayMl.value;
    
    Get.snackbar(
      '💧 Water Reminder',
      'Time to drink water! $remaining ml remaining to reach your goal.',
      duration: const Duration(seconds: 5),
      snackPosition: SnackPosition.TOP,
    );
  }

  void setDailyGoal(int ml) {
    dailyGoalMl.value = ml;
    storage.write(_keyDailyGoal, ml);
  }

  void setGlassSize(int ml) {
    glassSize.value = ml;
    storage.write(_keyGlassSize, ml);
  }

  void setReminderEnabled(bool enabled) {
    reminderEnabled.value = enabled;
    storage.write(_keyReminderEnabled, enabled);
    _startReminderTimer();
  }

  void setReminderInterval(int minutes) {
    reminderInterval.value = minutes;
    storage.write(_keyReminderInterval, minutes);
    _startReminderTimer();
  }

  double get progressPercent => 
      dailyGoalMl.value > 0 ? (todayMl.value / dailyGoalMl.value).clamp(0.0, 1.0) : 0.0;

  int get remainingMl => (dailyGoalMl.value - todayMl.value).clamp(0, dailyGoalMl.value);

  String get progressText => '${todayMl.value}/${dailyGoalMl.value} ml';

  int getWeeklyTotal() {
    int total = 0;
    for (var data in weeklyData) {
      total += (data['ml_amount'] as int?) ?? 0;
    }
    return total;
  }

  double getWeeklyAverage() {
    if (weeklyData.isEmpty) return 0;
    
    final Map<String, int> dailyTotals = {};
    for (var data in weeklyData) {
      final date = data['intake_date'] as String?;
      if (date != null) {
        dailyTotals[date] = (dailyTotals[date] ?? 0) + ((data['ml_amount'] as int?) ?? 0);
      }
    }
    
    if (dailyTotals.isEmpty) return 0;
    return dailyTotals.values.reduce((a, b) => a + b) / dailyTotals.length;
  }
}
