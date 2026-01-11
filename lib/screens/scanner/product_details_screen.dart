import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/scanner_controller.dart';
import '../../config/theme.dart';
import '../../services/ai_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final scannerController = Get.find<ScannerController>();
  AIProductAnalysis? _aiAnalysis;
  bool _isAnalyzing = true;

  @override
  void initState() {
    super.initState();
    _analyzeProduct();
  }

  Future<void> _analyzeProduct() async {
    final product = scannerController.currentProduct.value;
    if (product != null) {
      final analysis = await AIService.analyzeProduct(product);
      if (mounted) {
        setState(() {
          _aiAnalysis = analysis;
          _isAnalyzing = false;
        });
      }
    } else {
      setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = scannerController.currentProduct.value!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Product Image
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                        child: const Icon(Icons.shopping_bag, size: 100),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.brand,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Health Score Card
                  _buildHealthScoreCard(product.healthScore),
                  const SizedBox(height: 20),
                  
                  // AI Analysis Section
                  _buildAISection(),
                  const SizedBox(height: 20),
                  
                  // Nutrition Facts
                  _buildSectionTitle('🍎 ${'nutrition_facts'.tr}'),
                  const SizedBox(height: 12),
                  _buildNutritionCard(product),
                  const SizedBox(height: 20),
                 
                  // Ingredients
                  _buildSectionTitle('📝 ${'ingredients'.tr}'),
                  const SizedBox(height: 12),
                  _buildIngredientsCard(product, isDark),
                  const SizedBox(height: 20),

                  // Allergens
                  if (product.allergens.isNotEmpty) ...[
                    _buildSectionTitle('⚠️ ${'allergens'.tr}'),
                    const SizedBox(height: 12),
                    _buildAllergensCard(product),
                    const SizedBox(height: 20),
                  ],
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthScoreCard(double score) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: _getScoreGradient(score),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getScoreGradient(score).colors.first.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'health_score'.tr,
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
              ),
              const SizedBox(height: 6),
              Text(
                '${score.toStringAsFixed(1)}/10',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getScoreLabel(score),
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getScoreIcon(score),
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAISection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'AI Analysis',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_isAnalyzing) ...[
              const SizedBox(width: 12),
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        
        if (_isAnalyzing)
          _buildAnalyzingCard()
        else if (_aiAnalysis != null)
          _buildAIInsightsCards()
        else
          _buildAIErrorCard(),
      ],
    );
  }

  Widget _buildAnalyzingCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade100, Colors.blue.shade100],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Analyzing product...',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'AI is reviewing nutritional data',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsightsCards() {
    final analysis = _aiAnalysis!;
    
    return Column(
      children: [
        // Health Summary
        _buildInsightCard(
          icon: Icons.health_and_safety,
          iconColor: Colors.green,
          title: 'Health Summary',
          content: analysis.healthSummary,
          gradient: [Colors.green.shade50, Colors.teal.shade50],
        ),
        const SizedBox(height: 12),
        
        // Benefits
        if (analysis.benefits.isNotEmpty)
          _buildListCard(
            icon: Icons.thumb_up,
            iconColor: Colors.blue,
            title: 'Benefits',
            items: analysis.benefits,
            gradient: [Colors.blue.shade50, Colors.cyan.shade50],
          ),
        const SizedBox(height: 12),
        
        // Concerns
        if (analysis.concerns.isNotEmpty)
          _buildListCard(
            icon: Icons.warning_amber,
            iconColor: Colors.orange,
            title: 'Things to Consider',
            items: analysis.concerns,
            gradient: [Colors.orange.shade50, Colors.amber.shade50],
          ),
        const SizedBox(height: 12),
        
        // Diet Compatibility
        _buildDietCompatibilityCard(analysis.dietCompatibility),
        const SizedBox(height: 12),
        
        // Recommendations
        if (analysis.recommendations.isNotEmpty)
          _buildInsightCard(
            icon: Icons.lightbulb,
            iconColor: Colors.purple,
            title: 'Recommendations',
            content: analysis.recommendations,
            gradient: [Colors.purple.shade50, Colors.pink.shade50],
          ),
      ],
    );
  }

  Widget _buildInsightCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildListCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<String> items,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 16)),
                Expanded(child: Text(item, style: const TextStyle(fontSize: 14))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildDietCompatibilityCard(DietCompatibility diet) {
    final diets = [
      {'name': 'Vegan', 'icon': '🌱', 'compatible': diet.vegan},
      {'name': 'Vegetarian', 'icon': '🥗', 'compatible': diet.vegetarian},
      {'name': 'Keto', 'icon': '🥑', 'compatible': diet.keto},
      {'name': 'Diabetic Friendly', 'icon': '💉', 'compatible': diet.diabeticFriendly},
      {'name': 'Gluten Free', 'icon': '🌾', 'compatible': diet.glutenFree},
      {'name': 'Dairy Free', 'icon': '🥛', 'compatible': diet.dairyFree},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.restaurant_menu, color: Colors.deepPurple, size: 24),
              SizedBox(width: 10),
              Text(
                'Diet Compatibility',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: diets.map((d) => Chip(
              avatar: Text(d['icon'] as String, style: const TextStyle(fontSize: 16)),
              label: Text(d['name'] as String),
              backgroundColor: (d['compatible'] as bool) 
                ? Colors.green.shade100 
                : Colors.grey.shade200,
              side: BorderSide(
                color: (d['compatible'] as bool) ? Colors.green : Colors.grey.shade400,
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAIErrorCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey),
          SizedBox(width: 12),
          Expanded(
            child: Text('AI analysis not available. Check your API key.'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildNutritionCard(product) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          _buildNutritionRow('🔥 ${'calories'.tr}', '${product.nutritionFacts.calories}', 'kcal', Colors.orange),
          const Divider(height: 24),
          _buildNutritionRow('💪 ${'protein'.tr}', '${product.nutritionFacts.protein}', 'g', Colors.green),
          const Divider(height: 24),
          _buildNutritionRow('🌾 ${'carbs'.tr}', '${product.nutritionFacts.carbs}', 'g', Colors.amber),
          const Divider(height: 24),
          _buildNutritionRow('💧 ${'fats'.tr}', '${product.nutritionFacts.fats}', 'g', Colors.blue),
          const Divider(height: 24),
          _buildNutritionRow('🌿 ${'fiber'.tr}', '${product.nutritionFacts.fiber}', 'g', Colors.teal),
          const Divider(height: 24),
          _buildNutritionRow('🍬 ${'sugar'.tr}', '${product.nutritionFacts.sugar}', 'g', Colors.pink),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value, String unit, Color color) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 15)),
        const Spacer(),
        Text(
          '$value $unit',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientsCard(product, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: product.ingredients.map<Widget>((ingredient) {
          return Chip(
            label: Text(ingredient),
            backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAllergensCard(product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.red, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              product.allergens.join(', '),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getScoreGradient(double score) {
    if (score >= 8.0) {
      return const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]);
    } else if (score >= 6.0) {
      return const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]);
    } else {
      return const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)]);
    }
  }

  IconData _getScoreIcon(double score) {
    if (score >= 8.0) return Icons.sentiment_very_satisfied;
    if (score >= 6.0) return Icons.sentiment_satisfied;
    return Icons.sentiment_dissatisfied;
  }

  String _getScoreLabel(double score) {
    if (score >= 8.0) return 'Excellent Choice!';
    if (score >= 6.0) return 'Moderate';
    return 'Not Recommended';
  }
}
