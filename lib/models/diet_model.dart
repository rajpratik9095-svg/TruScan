class DietEntry {
  final String id;
  final String mealType; // breakfast, lunch, dinner, snacks
  final String foodName;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final DateTime timestamp;

  DietEntry({
    required this.id,
    required this.mealType,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'mealType': mealType,
    'foodName': foodName,
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fats': fats,
    'timestamp': timestamp.toIso8601String(),
  };

  factory DietEntry.fromJson(Map<String, dynamic> json) => DietEntry(
    id: json['id'],
    mealType: json['mealType'],
    foodName: json['foodName'],
    calories: json['calories'].toDouble(),
    protein: json['protein'].toDouble(),
    carbs: json['carbs'].toDouble(),
    fats: json['fats'].toDouble(),
    timestamp: DateTime.parse(json['timestamp']),
  );
}

class DailyNutrition {
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFats;
  final double calorieGoal;

  DailyNutrition({
    this.totalCalories = 0,
    this.totalProtein = 0,
    this.totalCarbs = 0,
    this.totalFats = 0,
    this.calorieGoal = 2000,
  });

  double get remainingCalories => calorieGoal - totalCalories;
  double get caloriesPercentage => (totalCalories / calorieGoal * 100).clamp(0, 100);
}
