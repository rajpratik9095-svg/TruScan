import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../config/constants.dart';
import '../models/diet_model.dart';
import 'dart:convert';

class DietController extends GetxController {
  final storage = GetStorage();
  
  final RxList<DietEntry> dietEntries = <DietEntry>[].obs;
  final Rx<DailyNutrition> dailyNutrition = DailyNutrition().obs;
  final RxDouble calorieGoal = 2000.0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDietEntries();
    _calculateDailyNutrition();
  }

  void _loadDietEntries() {
    final entriesJson = storage.read(AppConstants.storageKeyDietEntries);
    if (entriesJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(entriesJson);
        dietEntries.value = decoded.map((json) => DietEntry.fromJson(json)).toList();
      } catch (e) {
        dietEntries.value = [];
      }
    }
  }

  void _saveDietEntries() {
    final jsonList = dietEntries.map((entry) => entry.toJson()).toList();
    storage.write(AppConstants.storageKeyDietEntries, jsonEncode(jsonList));
  }

  void _calculateDailyNutrition() {
    final today = DateTime.now();
    final todayEntries = dietEntries.where((entry) {
      return entry.timestamp.year == today.year &&
          entry.timestamp.month == today.month &&
          entry.timestamp.day == today.day;
    }).toList();

    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFats = 0;

    for (var entry in todayEntries) {
      totalCalories += entry.calories;
      totalProtein += entry.protein;
      totalCarbs += entry.carbs;
      totalFats += entry.fats;
    }

    dailyNutrition.value = DailyNutrition(
      totalCalories: totalCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFats: totalFats,
      calorieGoal: calorieGoal.value,
    );
  }

  void addMeal(String mealType, String foodName, double calories, double protein, double carbs, double fats) {
    final entry = DietEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mealType: mealType,
      foodName: foodName,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fats: fats,
    );

    dietEntries.insert(0, entry);
    _saveDietEntries();
    _calculateDailyNutrition();
  }

  void deleteMeal(String id) {
    dietEntries.removeWhere((entry) => entry.id == id);
    _saveDietEntries();
    _calculateDailyNutrition();
  }

  List<DietEntry> getTodayMeals() {
    final today = DateTime.now();
    return dietEntries.where((entry) {
      return entry.timestamp.year == today.year &&
          entry.timestamp.month == today.month &&
          entry.timestamp.day == today.day;
    }).toList();
  }

  List<DietEntry> getMealsByType(String mealType) {
    return getTodayMeals().where((entry) => entry.mealType == mealType).toList();
  }

  void updateCalorieGoal(double newGoal) {
    calorieGoal.value = newGoal;
    _calculateDailyNutrition();
  }
}
