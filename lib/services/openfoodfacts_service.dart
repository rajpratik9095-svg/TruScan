import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for fetching product data from OpenFoodFacts API
class OpenFoodFactsService {
  static const String _baseUrl = 'https://world.openfoodfacts.org';
  
  /// Get product by barcode
  static Future<OpenFoodFactsProduct?> getProductByBarcode(String barcode) async {
    try {
      final url = '$_baseUrl/api/v0/product/$barcode.json';
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () => http.Response('Timeout', 408),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 1 && data['product'] != null) {
          return OpenFoodFactsProduct.fromJson(data['product']);
        }
      }
      return null;
    } catch (e) {
      print('OpenFoodFacts API Error: $e');
      return null;
    }
  }
  
  /// Search products by name - with country filter
  static Future<List<OpenFoodFactsProduct>> searchProducts(String query, {String country = 'world'}) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      
      String url;
      if (country == 'world') {
        // World search - no country filter
        url = 'https://world.openfoodfacts.org/cgi/search.pl?'
            'search_terms=$encodedQuery&json=1&page_size=50&lc=en';
      } else if (country == 'in') {
        // INDIA SEARCH - Correct parameters!
        url = 'https://world.openfoodfacts.org/cgi/search.pl?'
            'search_terms=$encodedQuery&'
            'tagtype_0=countries&tag_contains_0=contains&tag_0=india&'
            'json=1&page_size=50&lc=en';
      } else {
        // Other country search
        url = 'https://world.openfoodfacts.org/cgi/search.pl?'
            'search_terms=$encodedQuery&'
            'tagtype_0=countries&tag_contains_0=contains&tag_0=$country&'
            'json=1&page_size=50&lc=en';
      }
      
      print('🔍 Searching: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'TrueScanApp/1.0'},
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => http.Response('Timeout', 408),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final products = data['products'] as List? ?? [];
        
        print('📦 Found ${products.length} products from API');
        
        if (products.isNotEmpty) {
          return products
              .map((p) => OpenFoodFactsProduct.fromJson(p))
              .where((p) => p.productName.isNotEmpty)
              .toList();
        }
      }
      
      // Fallback to demo products if API fails or no results
      print('⚠️ API returned no results, using demo products');
      return _getDemoProducts(query);
    } catch (e) {
      print('OpenFoodFacts Search Error: $e');
      // Return demo products on error
      return _getDemoProducts(query);
    }
  }
  
  /// Demo products for when API is blocked (CORS issue on web)
  static List<OpenFoodFactsProduct> _getDemoProducts(String query) {
    final lowerQuery = query.toLowerCase();
    
    // Sample product database
    final allProducts = [
      OpenFoodFactsProduct(
        barcode: '8901234567890',
        productName: 'Mango Slice Pickle',
        brand: 'Mother\'s Recipe',
        imageUrl: 'https://via.placeholder.com/150/FF9800/FFFFFF?text=Mango+Pickle',
        category: 'Pickles',
        quantity: '500g',
        calories: 150,
        protein: 1.5,
        carbs: 35,
        fat: 2,
        sugar: 8,
        fiber: 2,
        salt: 5,
        sodium: 2000,
        nutriscoreGrade: 'c',
        novaGroup: '3',
        ecoscoreGrade: 'c',
        ingredientsText: 'Mango, Salt, Oil, Spices, Vinegar',
        ingredients: ['Mango', 'Salt', 'Oil', 'Spices'],
        allergens: [],
        labels: ['Vegetarian'],
        countries: 'India',
        origins: 'India',
      ),
      OpenFoodFactsProduct(
        barcode: '5449000000996',
        productName: 'Coca-Cola Original',
        brand: 'Coca-Cola',
        imageUrl: 'https://via.placeholder.com/150/E91E63/FFFFFF?text=Coca+Cola',
        category: 'Beverages',
        quantity: '330ml',
        calories: 139,
        protein: 0,
        carbs: 35,
        fat: 0,
        sugar: 35,
        fiber: 0,
        salt: 0,
        sodium: 0,
        nutriscoreGrade: 'e',
        novaGroup: '4',
        ecoscoreGrade: 'd',
        ingredientsText: 'Carbonated Water, Sugar, Phosphoric Acid, Caffeine, Natural Flavors',
        ingredients: ['Water', 'Sugar', 'Phosphoric Acid', 'Caffeine'],
        allergens: [],
        labels: [],
        countries: 'USA',
        origins: 'USA',
      ),
      OpenFoodFactsProduct(
        barcode: '3017620422003',
        productName: 'Nutella Hazelnut Spread',
        brand: 'Ferrero',
        imageUrl: '',
        category: 'Spreads',
        quantity: '400g',
        calories: 539,
        protein: 6.3,
        carbs: 57.5,
        fat: 30.9,
        sugar: 56.3,
        fiber: 1.5,
        salt: 0.1,
        sodium: 41,
        nutriscoreGrade: 'e',
        novaGroup: '4',
        ecoscoreGrade: 'd',
        ingredientsText: 'Sugar, Palm Oil, Hazelnuts, Cocoa, Skim Milk, Lecithin, Vanillin',
        ingredients: ['Sugar', 'Palm Oil', 'Hazelnuts', 'Cocoa', 'Milk'],
        allergens: ['Milk', 'Nuts'],
        labels: [],
        countries: 'Italy',
        origins: 'Italy',
      ),
      OpenFoodFactsProduct(
        barcode: '8901725181234',
        productName: 'Lay\'s Classic Chips',
        brand: 'Lay\'s',
        imageUrl: '',
        category: 'Snacks',
        quantity: '180g',
        calories: 536,
        protein: 6.5,
        carbs: 52,
        fat: 33,
        sugar: 0.5,
        fiber: 4.4,
        salt: 1.5,
        sodium: 600,
        nutriscoreGrade: 'd',
        novaGroup: '4',
        ecoscoreGrade: 'd',
        ingredientsText: 'Potatoes, Vegetable Oil, Salt',
        ingredients: ['Potatoes', 'Vegetable Oil', 'Salt'],
        allergens: [],
        labels: ['Gluten Free'],
        countries: 'India',
        origins: 'India',
      ),
      OpenFoodFactsProduct(
        barcode: '8901234500001',
        productName: 'Fresh Alphonso Mango',
        brand: 'Fresh Farms',
        imageUrl: '',
        category: 'Fruits',
        quantity: '1kg',
        calories: 60,
        protein: 0.8,
        carbs: 15,
        fat: 0.4,
        sugar: 14,
        fiber: 1.6,
        salt: 0,
        sodium: 1,
        nutriscoreGrade: 'a',
        novaGroup: '1',
        ecoscoreGrade: 'a',
        ingredientsText: 'Fresh Alphonso Mango',
        ingredients: ['Mango'],
        allergens: [],
        labels: ['Organic', 'Fresh'],
        countries: 'India',
        origins: 'Maharashtra, India',
      ),
      OpenFoodFactsProduct(
        barcode: '8901234500002',
        productName: 'Mango Juice',
        brand: 'Tropicana',
        imageUrl: '',
        category: 'Beverages',
        quantity: '1L',
        calories: 52,
        protein: 0.3,
        carbs: 13,
        fat: 0,
        sugar: 12,
        fiber: 0.2,
        salt: 0,
        sodium: 3,
        nutriscoreGrade: 'c',
        novaGroup: '3',
        ecoscoreGrade: 'c',
        ingredientsText: 'Mango Pulp, Water, Sugar, Citric Acid',
        ingredients: ['Mango', 'Water', 'Sugar'],
        allergens: [],
        labels: [],
        countries: 'India',
        origins: 'India',
      ),
      OpenFoodFactsProduct(
        barcode: '7622210449283',
        productName: 'Oreo Original Cookies',
        brand: 'Oreo',
        imageUrl: '',
        category: 'Biscuits',
        quantity: '150g',
        calories: 480,
        protein: 4.5,
        carbs: 70,
        fat: 20,
        sugar: 40,
        fiber: 2,
        salt: 0.8,
        sodium: 320,
        nutriscoreGrade: 'd',
        novaGroup: '4',
        ecoscoreGrade: 'c',
        ingredientsText: 'Wheat Flour, Sugar, Vegetable Oil, Cocoa Powder, Baking Soda',
        ingredients: ['Wheat', 'Sugar', 'Oil', 'Cocoa'],
        allergens: ['Wheat', 'Gluten'],
        labels: [],
        countries: 'India',
        origins: 'India',
      ),
      OpenFoodFactsProduct(
        barcode: '8901233001234',
        productName: 'Amul Butter',
        brand: 'Amul',
        imageUrl: '',
        category: 'Dairy',
        quantity: '500g',
        calories: 717,
        protein: 0.9,
        carbs: 0.1,
        fat: 81,
        sugar: 0.1,
        fiber: 0,
        salt: 1.5,
        sodium: 600,
        nutriscoreGrade: 'e',
        novaGroup: '3',
        ecoscoreGrade: 'd',
        ingredientsText: 'Milk Fat, Salt',
        ingredients: ['Milk Fat', 'Salt'],
        allergens: ['Milk'],
        labels: ['Vegetarian'],
        countries: 'India',
        origins: 'Gujarat, India',
      ),
      // MOBILE PHONES
      OpenFoodFactsProduct(
        barcode: '8901234100001',
        productName: 'Samsung Galaxy S24 Ultra',
        brand: 'Samsung Electronics',
        imageUrl: '',
        category: 'Electronics / Smartphones',
        quantity: '1 Unit',
        calories: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
        sugar: 0,
        fiber: 0,
        salt: 0,
        sodium: 0,
        nutriscoreGrade: '',
        novaGroup: '',
        ecoscoreGrade: 'c',
        ingredientsText: '6.8" Dynamic AMOLED, 200MP Camera, Snapdragon 8 Gen 3, 5000mAh Battery, S Pen',
        ingredients: ['Display', 'Processor', 'Camera', 'Battery'],
        allergens: [],
        labels: ['5G', 'AI Camera', 'S Pen'],
        countries: 'South Korea',
        origins: 'Samsung Electronics Co., Ltd.',
      ),
      OpenFoodFactsProduct(
        barcode: '8901234100002',
        productName: 'iPhone 15 Pro Max',
        brand: 'Apple',
        imageUrl: '',
        category: 'Electronics / Smartphones',
        quantity: '1 Unit',
        calories: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
        sugar: 0,
        fiber: 0,
        salt: 0,
        sodium: 0,
        nutriscoreGrade: '',
        novaGroup: '',
        ecoscoreGrade: 'b',
        ingredientsText: '6.7" Super Retina XDR, 48MP Camera, A17 Pro Chip, Titanium Design, USB-C',
        ingredients: ['Display', 'Processor', 'Camera', 'Battery'],
        allergens: [],
        labels: ['5G', 'ProMotion', 'Titanium'],
        countries: 'USA',
        origins: 'Apple Inc., Cupertino, California',
      ),
      OpenFoodFactsProduct(
        barcode: '8901234100003',
        productName: 'OnePlus 12',
        brand: 'OnePlus',
        imageUrl: '',
        category: 'Electronics / Smartphones',
        quantity: '1 Unit',
        calories: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
        sugar: 0,
        fiber: 0,
        salt: 0,
        sodium: 0,
        nutriscoreGrade: '',
        novaGroup: '',
        ecoscoreGrade: 'c',
        ingredientsText: '6.82" AMOLED, Hasselblad Camera, Snapdragon 8 Gen 3, 100W Charging',
        ingredients: ['Display', 'Processor', 'Camera', 'Battery'],
        allergens: [],
        labels: ['5G', 'Hasselblad', 'Fast Charging'],
        countries: 'China',
        origins: 'OnePlus Technology Co., Ltd.',
      ),
      // FRUITS
      OpenFoodFactsProduct(
        barcode: '8901234200001',
        productName: 'Fresh Apple (Red Delicious)',
        brand: 'Fresh Farms',
        imageUrl: '',
        category: 'Fruits',
        quantity: '1kg',
        calories: 52,
        protein: 0.3,
        carbs: 14,
        fat: 0.2,
        sugar: 10,
        fiber: 2.4,
        salt: 0,
        sodium: 1,
        nutriscoreGrade: 'a',
        novaGroup: '1',
        ecoscoreGrade: 'a',
        ingredientsText: 'Fresh Red Delicious Apple',
        ingredients: ['Apple'],
        allergens: [],
        labels: ['Fresh', 'Organic', 'Natural'],
        countries: 'India',
        origins: 'Himachal Pradesh, India',
      ),
      OpenFoodFactsProduct(
        barcode: '8901234200002',
        productName: 'Fresh Orange (Nagpur)',
        brand: 'Fresh Farms',
        imageUrl: '',
        category: 'Fruits',
        quantity: '1kg',
        calories: 47,
        protein: 0.9,
        carbs: 12,
        fat: 0.1,
        sugar: 9,
        fiber: 2.4,
        salt: 0,
        sodium: 0,
        nutriscoreGrade: 'a',
        novaGroup: '1',
        ecoscoreGrade: 'a',
        ingredientsText: 'Fresh Nagpur Orange',
        ingredients: ['Orange'],
        allergens: [],
        labels: ['Fresh', 'Vitamin C', 'Natural'],
        countries: 'India',
        origins: 'Nagpur, Maharashtra, India',
      ),
      OpenFoodFactsProduct(
        barcode: '8901234200003',
        productName: 'Fresh Banana (Cavendish)',
        brand: 'Fresh Farms',
        imageUrl: '',
        category: 'Fruits',
        quantity: '1kg (6-8 pcs)',
        calories: 89,
        protein: 1.1,
        carbs: 23,
        fat: 0.3,
        sugar: 12,
        fiber: 2.6,
        salt: 0,
        sodium: 1,
        nutriscoreGrade: 'a',
        novaGroup: '1',
        ecoscoreGrade: 'a',
        ingredientsText: 'Fresh Cavendish Banana',
        ingredients: ['Banana'],
        allergens: [],
        labels: ['Fresh', 'Potassium Rich', 'Energy'],
        countries: 'India',
        origins: 'Tamil Nadu, India',
      ),
      // VEGETABLES
      OpenFoodFactsProduct(
        barcode: '8901234300001',
        productName: 'Fresh Potato',
        brand: 'Farm Fresh',
        imageUrl: '',
        category: 'Vegetables',
        quantity: '1kg',
        calories: 77,
        protein: 2,
        carbs: 17,
        fat: 0.1,
        sugar: 0.8,
        fiber: 2.2,
        salt: 0,
        sodium: 6,
        nutriscoreGrade: 'a',
        novaGroup: '1',
        ecoscoreGrade: 'a',
        ingredientsText: 'Fresh Potato (Aloo)',
        ingredients: ['Potato'],
        allergens: [],
        labels: ['Fresh', 'Organic', 'Carb Source'],
        countries: 'India',
        origins: 'Uttar Pradesh, India',
      ),
      OpenFoodFactsProduct(
        barcode: '8901234300002',
        productName: 'Fresh Onion (Red)',
        brand: 'Farm Fresh',
        imageUrl: '',
        category: 'Vegetables',
        quantity: '1kg',
        calories: 40,
        protein: 1.1,
        carbs: 9,
        fat: 0.1,
        sugar: 4.2,
        fiber: 1.7,
        salt: 0,
        sodium: 4,
        nutriscoreGrade: 'a',
        novaGroup: '1',
        ecoscoreGrade: 'a',
        ingredientsText: 'Fresh Red Onion (Pyaz)',
        ingredients: ['Onion'],
        allergens: [],
        labels: ['Fresh', 'Natural', 'Antioxidant'],
        countries: 'India',
        origins: 'Nashik, Maharashtra, India',
      ),
      OpenFoodFactsProduct(
        barcode: '8901234300003',
        productName: 'Fresh Tomato',
        brand: 'Farm Fresh',
        imageUrl: '',
        category: 'Vegetables',
        quantity: '1kg',
        calories: 18,
        protein: 0.9,
        carbs: 3.9,
        fat: 0.2,
        sugar: 2.6,
        fiber: 1.2,
        salt: 0,
        sodium: 5,
        nutriscoreGrade: 'a',
        novaGroup: '1',
        ecoscoreGrade: 'a',
        ingredientsText: 'Fresh Tomato (Tamatar)',
        ingredients: ['Tomato'],
        allergens: [],
        labels: ['Fresh', 'Lycopene Rich', 'Low Calorie'],
        countries: 'India',
        origins: 'Karnataka, India',
      ),
      // MEDICINES
      OpenFoodFactsProduct(
        barcode: '8901234400001',
        productName: 'Crocin Advance 500mg',
        brand: 'GSK (GlaxoSmithKline)',
        imageUrl: '',
        category: 'Medicines / Pain Relief',
        quantity: '15 Tablets',
        calories: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
        sugar: 0,
        fiber: 0,
        salt: 0,
        sodium: 0,
        nutriscoreGrade: '',
        novaGroup: '',
        ecoscoreGrade: '',
        ingredientsText: 'Paracetamol 500mg - For Fever, Headache, Body Pain',
        ingredients: ['Paracetamol'],
        allergens: [],
        labels: ['OTC', 'Pain Relief', 'Fever'],
        countries: 'India',
        origins: 'GlaxoSmithKline Pharmaceuticals Ltd.',
      ),
      OpenFoodFactsProduct(
        barcode: '8901234400002',
        productName: 'Dolo 650mg',
        brand: 'Micro Labs',
        imageUrl: '',
        category: 'Medicines / Pain Relief',
        quantity: '15 Tablets',
        calories: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
        sugar: 0,
        fiber: 0,
        salt: 0,
        sodium: 0,
        nutriscoreGrade: '',
        novaGroup: '',
        ecoscoreGrade: '',
        ingredientsText: 'Paracetamol 650mg - For Fever, Headache, Body Pain, Flu',
        ingredients: ['Paracetamol'],
        allergens: [],
        labels: ['OTC', 'Pain Relief', 'Fever'],
        countries: 'India',
        origins: 'Micro Labs Limited, Bangalore',
      ),
      OpenFoodFactsProduct(
        barcode: '8901234400003',
        productName: 'Vicks VapoRub',
        brand: 'Vicks (P&G)',
        imageUrl: '',
        category: 'Medicines / Cold & Cough',
        quantity: '50g',
        calories: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
        sugar: 0,
        fiber: 0,
        salt: 0,
        sodium: 0,
        nutriscoreGrade: '',
        novaGroup: '',
        ecoscoreGrade: '',
        ingredientsText: 'Menthol, Camphor, Eucalyptus Oil - For Cold, Cough, Nasal Congestion',
        ingredients: ['Menthol', 'Camphor', 'Eucalyptus'],
        allergens: [],
        labels: ['Topical', 'Cold Relief', 'Nasal'],
        countries: 'USA',
        origins: 'Procter & Gamble',
      ),
      // MORE ELECTRONICS
      OpenFoodFactsProduct(
        barcode: '8901234500001',
        productName: 'Sony WH-1000XM5 Headphones',
        brand: 'Sony',
        imageUrl: '',
        category: 'Electronics / Audio',
        quantity: '1 Unit',
        calories: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
        sugar: 0,
        fiber: 0,
        salt: 0,
        sodium: 0,
        nutriscoreGrade: '',
        novaGroup: '',
        ecoscoreGrade: 'c',
        ingredientsText: 'Premium Wireless Noise Canceling, 30hr Battery, Hi-Res Audio',
        ingredients: ['Drivers', 'Battery', 'Bluetooth', 'ANC'],
        allergens: [],
        labels: ['Wireless', 'ANC', 'Hi-Res'],
        countries: 'Japan',
        origins: 'Sony Corporation, Tokyo',
      ),
      OpenFoodFactsProduct(
        barcode: '8901234500002',
        productName: 'boAt Airdopes 141',
        brand: 'boAt',
        imageUrl: '',
        category: 'Electronics / Audio',
        quantity: '1 Unit',
        calories: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
        sugar: 0,
        fiber: 0,
        salt: 0,
        sodium: 0,
        nutriscoreGrade: '',
        novaGroup: '',
        ecoscoreGrade: 'c',
        ingredientsText: 'TWS Earbuds, 42hr Playback, IPX4, ENx Technology',
        ingredients: ['Drivers', 'Battery', 'Bluetooth'],
        allergens: [],
        labels: ['Wireless', 'TWS', 'Budget'],
        countries: 'India',
        origins: 'Imagine Marketing Pvt. Ltd., Delhi',
      ),
    ];
    
    // Filter by search query
    return allProducts.where((p) =>
        p.productName.toLowerCase().contains(lowerQuery) ||
        p.brand.toLowerCase().contains(lowerQuery) ||
        p.category.toLowerCase().contains(lowerQuery)
    ).toList();
  }
}

/// Product model from OpenFoodFacts API
class OpenFoodFactsProduct {
  final String barcode;
  final String productName;
  final String brand;
  final String imageUrl;
  final String category;
  final String quantity;
  
  // Nutrition per 100g
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double sugar;
  final double fiber;
  final double salt;
  final double sodium;
  
  // Scores
  final String nutriscoreGrade; // a, b, c, d, e
  final String novaGroup; // 1, 2, 3, 4
  final String ecoscoreGrade; // a, b, c, d, e
  
  // Ingredients & Allergens
  final String ingredientsText;
  final List<String> ingredients;
  final List<String> allergens;
  final List<String> labels;
  
  // Origin
  final String countries;
  final String origins;

  OpenFoodFactsProduct({
    required this.barcode,
    required this.productName,
    required this.brand,
    required this.imageUrl,
    required this.category,
    required this.quantity,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.sugar,
    required this.fiber,
    required this.salt,
    required this.sodium,
    required this.nutriscoreGrade,
    required this.novaGroup,
    required this.ecoscoreGrade,
    required this.ingredientsText,
    required this.ingredients,
    required this.allergens,
    required this.labels,
    required this.countries,
    required this.origins,
  });

  factory OpenFoodFactsProduct.fromJson(Map<String, dynamic> json) {
    final nutriments = json['nutriments'] ?? {};
    
    return OpenFoodFactsProduct(
      barcode: json['code'] ?? '',
      productName: json['product_name'] ?? json['product_name_en'] ?? '',
      brand: json['brands'] ?? '',
      imageUrl: json['image_front_url'] ?? json['image_url'] ?? '',
      category: json['categories'] ?? '',
      quantity: json['quantity'] ?? '',
      
      // Nutrition
      calories: _parseDouble(nutriments['energy-kcal_100g'] ?? nutriments['energy_100g']),
      protein: _parseDouble(nutriments['proteins_100g']),
      carbs: _parseDouble(nutriments['carbohydrates_100g']),
      fat: _parseDouble(nutriments['fat_100g']),
      sugar: _parseDouble(nutriments['sugars_100g']),
      fiber: _parseDouble(nutriments['fiber_100g']),
      salt: _parseDouble(nutriments['salt_100g']),
      sodium: _parseDouble(nutriments['sodium_100g']) * 1000, // Convert to mg
      
      // Scores
      nutriscoreGrade: json['nutriscore_grade'] ?? '',
      novaGroup: json['nova_group']?.toString() ?? '',
      ecoscoreGrade: json['ecoscore_grade'] ?? '',
      
      // Ingredients
      ingredientsText: json['ingredients_text'] ?? json['ingredients_text_en'] ?? '',
      ingredients: _parseList(json['ingredients_tags']),
      allergens: _parseAllergens(json['allergens_tags']),
      labels: _parseList(json['labels_tags']),
      
      // Origin
      countries: json['countries'] ?? '',
      origins: json['origins'] ?? '',
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static List<String> _parseList(dynamic list) {
    if (list == null) return [];
    if (list is List) {
      return list.map((e) => e.toString().replaceAll('en:', '').replaceAll('-', ' ')).toList();
    }
    return [];
  }

  static List<String> _parseAllergens(dynamic list) {
    if (list == null) return [];
    if (list is List) {
      return list.map((e) {
        String allergen = e.toString().replaceAll('en:', '');
        return allergen[0].toUpperCase() + allergen.substring(1);
      }).toList();
    }
    return [];
  }

  /// Get health score based on nutriscore
  double get healthScore {
    switch (nutriscoreGrade.toLowerCase()) {
      case 'a': return 9.0;
      case 'b': return 7.5;
      case 'c': return 6.0;
      case 'd': return 4.0;
      case 'e': return 2.0;
      default: return 5.0;
    }
  }

  /// Check if product is healthy
  bool get isHealthy => nutriscoreGrade.toLowerCase() == 'a' || nutriscoreGrade.toLowerCase() == 'b';
}
