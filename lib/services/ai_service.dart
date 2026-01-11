import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

class AIService {
  // Fallback API key - used when Supabase fetch fails
  static const String _fallbackApiKey = 'AIzaSyB1-h6KC5d_jmMYDlaBnVDxWgqcPOqXyTs';
  
  static String _currentApiKey = _fallbackApiKey;
  static GenerativeModel? _model;
  
  /// Fetch API key from Supabase admin_users table
  static Future<void> fetchApiKeyFromSupabase() async {
    try {
      final supabase = Supabase.instance.client;
      
      // Get first admin's API key (you can modify this logic)
      final response = await supabase
          .from('admin_users')
          .select('gemini_api_key')
          .not('gemini_api_key', 'is', null)
          .limit(1)
          .maybeSingle();
      
      if (response != null && response['gemini_api_key'] != null) {
        _currentApiKey = response['gemini_api_key'];
        print('✅ AI: Loaded API key from Supabase');
        // Reinitialize model with new key
        _model = null;
        initialize();
      } else {
        print('⚠️ AI: No API key in Supabase, using fallback');
      }
    } catch (e) {
      print('⚠️ AI: Could not fetch API key from Supabase: $e');
      print('⚠️ AI: Using fallback API key');
    }
  }
  
  static void initialize() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _currentApiKey,
    );
  }
  
  /// Analyze a product and return AI insights
  static Future<AIProductAnalysis?> analyzeProduct(Product product) async {
    if (_model == null) {
      initialize();
    }
    
    try {
      final prompt = '''
Analyze this food product and provide a comprehensive health analysis in JSON format.

Product: ${product.name}
Brand: ${product.brand}
Nutrition per serving:
- Calories: ${product.nutritionFacts.calories} kcal
- Protein: ${product.nutritionFacts.protein}g
- Carbs: ${product.nutritionFacts.carbs}g
- Fats: ${product.nutritionFacts.fats}g
- Fiber: ${product.nutritionFacts.fiber}g
- Sugar: ${product.nutritionFacts.sugar}g
- Sodium: ${product.nutritionFacts.sodium}mg

Ingredients: ${product.ingredients.join(', ')}
Allergens: ${product.allergens.join(', ')}

Please respond ONLY with valid JSON in this exact format:
{
  "healthSummary": "Brief 2-3 sentence overall health assessment",
  "benefits": ["benefit1", "benefit2", "benefit3"],
  "concerns": ["concern1", "concern2"],
  "dietCompatibility": {
    "vegan": true/false,
    "vegetarian": true/false,
    "keto": true/false,
    "diabeticFriendly": true/false,
    "glutenFree": true/false,
    "dairyFree": true/false
  },
  "healthRating": "Good/Moderate/Poor",
  "recommendations": "What to pair with or when to consume",
  "environmentalImpact": "Low/Medium/High"
}
''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      final text = response.text;
      
      if (text == null) return null;
      
      // Parse JSON from response
      final jsonStr = _extractJson(text);
      if (jsonStr == null) return null;
      
      return AIProductAnalysis.fromJson(jsonStr);
    } catch (e) {
      print('AI Analysis Error: $e');
      return null;
    }
  }
  
  static String? _extractJson(String text) {
    // Find JSON in the response
    final startIndex = text.indexOf('{');
    final endIndex = text.lastIndexOf('}');
    
    if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
      return text.substring(startIndex, endIndex + 1);
    }
    return null;
  }
  
  /// Recognize product from image using Gemini Vision
  static Future<RecognizedProduct?> recognizeProductFromImage(List<int> imageBytes) async {
    if (_model == null) {
      initialize();
    }
    
    try {
      print('🔍 AI: Starting image recognition...');
      print('📦 Image size: ${imageBytes.length} bytes');
      
      final prompt = '''
Look at this product image carefully and identify:
1. What product/item is this? (Be specific with exact product name)
2. Which company/brand makes it? (Company name, manufacturer)
3. What category does it belong to (food, beverage, cosmetic, electronics, medicine, fruit, vegetable, etc.)?
4. Estimate nutritional values if it's a food item.

IMPORTANT: You MUST respond with valid JSON only. No other text.

{
  "productName": "Full product name with variant",
  "brand": "Company or Brand name (manufacturer)",
  "category": "Product category",
  "description": "Brief 2-3 sentence product description",
  "isFood": true or false,
  "estimatedNutrition": {
    "calories": number,
    "protein": number,
    "carbs": number,
    "fats": number,
    "sugar": number
  },
  "ingredients": ["ingredient1", "ingredient2"],
  "allergens": ["allergen1"],
  "healthScore": 7.5,
  "countryOfOrigin": "Country name",
  "mrp": "Price if visible"
}
''';

      final imagePart = DataPart('image/jpeg', Uint8List.fromList(imageBytes));
      
      print('🤖 AI: Sending to Gemini...');
      
      final response = await _model!.generateContent([
        Content.multi([
          TextPart(prompt),
          imagePart,
        ]),
      ]);
      
      final text = response.text;
      print('📝 AI Response: ${text?.substring(0, text.length > 200 ? 200 : text.length)}...');
      
      if (text == null || text.isEmpty) {
        print('❌ AI: Empty response');
        return null;
      }
      
      final jsonStr = _extractJson(text);
      if (jsonStr == null) {
        print('❌ AI: Could not extract JSON from response');
        return null;
      }
      
      print('✅ AI: Successfully parsed product');
      return RecognizedProduct.fromJson(jsonStr);
    } catch (e) {
      print('❌ AI Image Recognition Error: $e');
      return null;
    }
  }
}

class AIProductAnalysis {
  final String healthSummary;
  final List<String> benefits;
  final List<String> concerns;
  final DietCompatibility dietCompatibility;
  final String healthRating;
  final String recommendations;
  final String environmentalImpact;

  AIProductAnalysis({
    required this.healthSummary,
    required this.benefits,
    required this.concerns,
    required this.dietCompatibility,
    required this.healthRating,
    required this.recommendations,
    required this.environmentalImpact,
  });

  factory AIProductAnalysis.fromJson(String jsonStr) {
    try {
      // Simple JSON parsing
      final Map<String, dynamic> json = _parseJson(jsonStr);
      
      return AIProductAnalysis(
        healthSummary: json['healthSummary'] ?? 'Analysis not available',
        benefits: List<String>.from(json['benefits'] ?? []),
        concerns: List<String>.from(json['concerns'] ?? []),
        dietCompatibility: DietCompatibility.fromJson(json['dietCompatibility'] ?? {}),
        healthRating: json['healthRating'] ?? 'Unknown',
        recommendations: json['recommendations'] ?? '',
        environmentalImpact: json['environmentalImpact'] ?? 'Unknown',
      );
    } catch (e) {
      print('Parse error: $e');
      return AIProductAnalysis(
        healthSummary: 'Unable to analyze product',
        benefits: [],
        concerns: [],
        dietCompatibility: DietCompatibility.empty(),
        healthRating: 'Unknown',
        recommendations: '',
        environmentalImpact: 'Unknown',
      );
    }
  }
  
  static Map<String, dynamic> _parseJson(String jsonStr) {
    try {
      return Map<String, dynamic>.from(jsonDecode(jsonStr));
    } catch (e) {
      return {};
    }
  }
}

class DietCompatibility {
  final bool vegan;
  final bool vegetarian;
  final bool keto;
  final bool diabeticFriendly;
  final bool glutenFree;
  final bool dairyFree;

  DietCompatibility({
    required this.vegan,
    required this.vegetarian,
    required this.keto,
    required this.diabeticFriendly,
    required this.glutenFree,
    required this.dairyFree,
  });

  factory DietCompatibility.fromJson(Map<String, dynamic> json) {
    return DietCompatibility(
      vegan: json['vegan'] ?? false,
      vegetarian: json['vegetarian'] ?? false,
      keto: json['keto'] ?? false,
      diabeticFriendly: json['diabeticFriendly'] ?? false,
      glutenFree: json['glutenFree'] ?? false,
      dairyFree: json['dairyFree'] ?? false,
    );
  }
  
  factory DietCompatibility.empty() {
    return DietCompatibility(
      vegan: false,
      vegetarian: false,
      keto: false,
      diabeticFriendly: false,
      glutenFree: false,
      dairyFree: false,
    );
  }
}

/// Product recognized from image using AI Vision
class RecognizedProduct {
  final String productName;
  final String brand;
  final String category;
  final String description;
  final bool isFood;
  final Map<String, dynamic> estimatedNutrition;
  final List<String> ingredients;
  final List<String> allergens;
  final double healthScore;
  final String countryOfOrigin;
  final String mrp;

  RecognizedProduct({
    required this.productName,
    required this.brand,
    required this.category,
    required this.description,
    required this.isFood,
    required this.estimatedNutrition,
    required this.ingredients,
    required this.allergens,
    required this.healthScore,
    required this.countryOfOrigin,
    required this.mrp,
  });

  factory RecognizedProduct.fromJson(String jsonStr) {
    try {
      final Map<String, dynamic> json = Map<String, dynamic>.from(jsonDecode(jsonStr));
      
      return RecognizedProduct(
        productName: json['productName'] ?? 'Unknown Product',
        brand: json['brand'] ?? 'Unknown Brand',
        category: json['category'] ?? 'Unknown',
        description: json['description'] ?? '',
        isFood: json['isFood'] ?? false,
        estimatedNutrition: Map<String, dynamic>.from(json['estimatedNutrition'] ?? {}),
        ingredients: List<String>.from(json['ingredients'] ?? []),
        allergens: List<String>.from(json['allergens'] ?? []),
        healthScore: (json['healthScore'] ?? 5.0).toDouble(),
        countryOfOrigin: json['countryOfOrigin'] ?? 'Unknown',
        mrp: json['mrp'] ?? 'N/A',
      );
    } catch (e) {
      print('RecognizedProduct parse error: $e');
      return RecognizedProduct(
        productName: 'Could not identify product',
        brand: 'Unknown',
        category: 'Unknown',
        description: 'Unable to analyze this image. Please try another image.',
        isFood: false,
        estimatedNutrition: {},
        ingredients: [],
        allergens: [],
        healthScore: 0,
        countryOfOrigin: 'Unknown',
        mrp: 'N/A',
      );
    }
  }
}
