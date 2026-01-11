class Product {
  final String id;
  final String barcode;
  final String name;
  final String brand;
  final String category;
  final String imageUrl;
  final List<String> ingredients;
  final NutritionFacts nutritionFacts;
  final List<String> allergens;
  final double healthScore; // 0-10 scale
  final DateTime scannedAt;

  Product({
    required this.id,
    required this.barcode,
    required this.name,
    required this.brand,
    required this.category,
    required this.imageUrl,
    required this.ingredients,
    required this.nutritionFacts,
    required this.allergens,
    required this.healthScore,
    DateTime? scannedAt,
  }) : scannedAt = scannedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'barcode': barcode,
    'name': name,
    'brand': brand,
    'category': category,
    'imageUrl': imageUrl,
    'ingredients': ingredients,
    'nutritionFacts': nutritionFacts.toJson(),
    'allergens': allergens,
    'healthScore': healthScore,
    'scannedAt': scannedAt.toIso8601String(),
  };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    barcode: json['barcode'],
    name: json['name'],
    brand: json['brand'],
    category: json['category'],
    imageUrl: json['imageUrl'],
    ingredients: List<String>.from(json['ingredients']),
    nutritionFacts: NutritionFacts.fromJson(json['nutritionFacts']),
    allergens: List<String>.from(json['allergens']),
    healthScore: json['healthScore'].toDouble(),
    scannedAt: DateTime.parse(json['scannedAt']),
  );
}

class NutritionFacts {
  final double calories;
  final double protein; // in grams
  final double carbs; // in grams
  final double fats; // in grams
  final double fiber; // in grams
  final double sugar; // in grams
  final double sodium; // in mg

  NutritionFacts({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.fiber,
    required this.sugar,
    required this.sodium,
  });

  Map<String, dynamic> toJson() => {
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fats': fats,
    'fiber': fiber,
    'sugar': sugar,
    'sodium': sodium,
  };

  factory NutritionFacts.fromJson(Map<String, dynamic> json) => NutritionFacts(
    calories: json['calories'].toDouble(),
    protein: json['protein'].toDouble(),
    carbs: json['carbs'].toDouble(),
    fats: json['fats'].toDouble(),
    fiber: json['fiber'].toDouble(),
    sugar: json['sugar'].toDouble(),
    sodium: json['sodium'].toDouble(),
  );
}

// Sample product database
class ProductDatabase {
  static final Map<String, Product> _products = {
    '1234567890123': Product(
      id: '1',
      barcode: '1234567890123',
      name: 'Whole Wheat Bread',
      brand: 'Healthy Bakery',
      category: 'Bakery',
      imageUrl: 'https://via.placeholder.com/300x300.png?text=Whole+Wheat+Bread',
      ingredients: [
        'Whole Wheat Flour',
        'Water',
        'Yeast',
        'Salt',
        'Honey',
        'Olive Oil'
      ],
      nutritionFacts: NutritionFacts(
        calories: 247,
        protein: 13.0,
        carbs: 41.0,
        fats: 4.0,
        fiber: 7.0,
        sugar: 4.0,
        sodium: 400,
      ),
      allergens: ['Gluten', 'Wheat'],
      healthScore: 8.5,
    ),
    '9876543210987': Product(
      id: '2',
      barcode: '9876543210987',
      name: 'Organic Milk',
      brand: 'Pure Dairy',
      category: 'Dairy',
      imageUrl: 'https://via.placeholder.com/300x300.png?text=Organic+Milk',
      ingredients: [
        'Organic Whole Milk',
        'Vitamin D3',
      ],
      nutritionFacts: NutritionFacts(
        calories: 149,
        protein: 8.0,
        carbs: 12.0,
        fats: 8.0,
        fiber: 0.0,
        sugar: 12.0,
        sodium: 105,
      ),
      allergens: ['Milk', 'Lactose'],
      healthScore: 7.5,
    ),
    '5555555555555': Product(
      id: '3',
      barcode: '5555555555555',
      name: 'Mixed Nuts',
      brand: 'Nature\'s Best',
      category: 'Snacks',
      imageUrl: 'https://via.placeholder.com/300x300.png?text=Mixed+Nuts',
      ingredients: [
        'Almonds',
        'Cashews',
        'Walnuts',
        'Pistachios',
        'Sea Salt'
      ],
      nutritionFacts: NutritionFacts(
        calories: 607,
        protein: 20.0,
        carbs: 27.0,
        fats: 54.0,
        fiber: 7.0,
        sugar: 5.0,
        sodium: 16,
      ),
      allergens: ['Tree Nuts'],
      healthScore: 9.0,
    ),
  };

  static Product? getProductByBarcode(String barcode) {
    return _products[barcode];
  }

  static List<Product> getAllProducts() {
    return _products.values.toList();
  }
}
