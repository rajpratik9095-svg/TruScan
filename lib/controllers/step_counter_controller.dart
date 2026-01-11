import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';

class StepCounterController extends GetxController {
  final storage = GetStorage();
  
  // Observable values
  final RxInt todaySteps = 0.obs;
  final RxInt weeklySteps = 0.obs;
  final RxInt monthlySteps = 0.obs;
  final RxInt weeklyAverage = 0.obs;
  final RxInt dailyGoal = 10000.obs;
  final RxBool isTracking = false.obs;
  final RxBool hasPermission = false.obs;
  final RxString status = 'Stopped'.obs;
  
  // Timer for simulated tracking (web fallback)
  Timer? _simulationTimer;
  
  // Keys for storage
  static const String _keyTodaySteps = 'today_steps';
  static const String _keyLastResetDate = 'last_reset_date';
  static const String _keyStepHistory = 'step_history';
  static const String _keyDailyGoal = 'daily_goal';

  @override
  void onInit() {
    super.onInit();
    _loadSavedData();
    _checkAndResetDaily();
  }

  @override
  void onClose() {
    stopTracking();
    super.onClose();
  }

  void _loadSavedData() {
    todaySteps.value = storage.read(_keyTodaySteps) ?? 0;
    dailyGoal.value = storage.read(_keyDailyGoal) ?? 10000;
    _loadWeeklyData();
    _loadMonthlyData();
  }

  void _loadWeeklyData() {
    final history = _getStepHistory();
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    int total = 0;
    int days = 0;
    
    history.forEach((dateStr, steps) {
      final date = DateTime.tryParse(dateStr);
      if (date != null && date.isAfter(weekAgo)) {
        total += steps as int;
        days++;
      }
    });
    
    weeklySteps.value = total;
    weeklyAverage.value = days > 0 ? (total / days).round() : 0;
  }

  void _loadMonthlyData() {
    final history = _getStepHistory();
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));
    
    int total = 0;
    
    history.forEach((dateStr, steps) {
      final date = DateTime.tryParse(dateStr);
      if (date != null && date.isAfter(monthAgo)) {
        total += steps as int;
      }
    });
    
    monthlySteps.value = total;
  }

  Map<String, dynamic> _getStepHistory() {
    return Map<String, dynamic>.from(storage.read(_keyStepHistory) ?? {});
  }

  void _saveStepHistory(Map<String, dynamic> history) {
    storage.write(_keyStepHistory, history);
  }

  void _checkAndResetDaily() {
    final lastResetStr = storage.read(_keyLastResetDate);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    
    if (lastResetStr != today) {
      // Save yesterday's steps to history
      if (lastResetStr != null && todaySteps.value > 0) {
        final history = _getStepHistory();
        history[lastResetStr] = todaySteps.value;
        _saveStepHistory(history);
      }
      
      // Reset for new day
      todaySteps.value = 0;
      storage.write(_keyTodaySteps, 0);
      storage.write(_keyLastResetDate, today);
      
      // Reload weekly/monthly
      _loadWeeklyData();
      _loadMonthlyData();
    }
  }

  Future<bool> requestPermission() async {
    // Skip on web - use simulation
    if (kIsWeb) {
      hasPermission.value = true;
      return true;
    }

    try {
      // Request activity recognition permission
      final activityStatus = await Permission.activityRecognition.request();
      
      if (activityStatus.isGranted) {
        hasPermission.value = true;
        return true;
      } else if (activityStatus.isPermanentlyDenied) {
        openAppSettings();
      }
      
      hasPermission.value = false;
      return false;
    } catch (e) {
      print('Permission error: $e');
      // Fallback for web/unsupported platforms
      hasPermission.value = true;
      return true;
    }
  }

  Future<void> startTracking() async {
    final granted = await requestPermission();
    if (!granted) {
      status.value = 'Permission denied';
      return;
    }

    isTracking.value = true;
    status.value = 'Tracking';

    // For Web and testing: Use simulated step counting
    // In real app with physical device, you would use pedometer package
    if (kIsWeb) {
      _startSimulatedTracking();
    } else {
      // Try to use actual pedometer on mobile
      try {
        _startSimulatedTracking(); // Fallback to simulation for now
        // TODO: Add actual pedometer integration for mobile
        // _stepCountSubscription = Pedometer.stepCountStream.listen(...)
      } catch (e) {
        print('Pedometer error: $e');
        _startSimulatedTracking();
      }
    }
  }

  void _startSimulatedTracking() {
    // Simulate step counting for demo purposes
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (isTracking.value) {
        // Add random steps (simulating walking)
        final newSteps = (DateTime.now().millisecond % 10) + 5;
        todaySteps.value += newSteps;
        storage.write(_keyTodaySteps, todaySteps.value);
        
        // Update status based on activity
        if (newSteps > 7) {
          status.value = 'Walking 🚶';
        } else {
          status.value = 'Tracking';
        }
      }
    });
  }

  void stopTracking() {
    _simulationTimer?.cancel();
    isTracking.value = false;
    status.value = 'Stopped';
  }

  void addSteps(int steps) {
    todaySteps.value += steps;
    storage.write(_keyTodaySteps, todaySteps.value);
  }

  void setDailyGoal(int goal) {
    dailyGoal.value = goal;
    storage.write(_keyDailyGoal, goal);
  }

  double get progressPercent => 
      dailyGoal.value > 0 ? (todaySteps.value / dailyGoal.value).clamp(0.0, 1.0) : 0.0;

  int get remainingSteps => 
      (dailyGoal.value - todaySteps.value).clamp(0, dailyGoal.value);

  double get caloriesBurned => todaySteps.value * 0.04; // Approx 0.04 calories per step

  double get distanceKm => todaySteps.value * 0.0008; // Approx 0.8m per step

  String get formattedTime {
    // Approx 1000 steps = 10 minutes
    final minutes = (todaySteps.value / 100).round();
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '$hours h $mins min';
  }
}
