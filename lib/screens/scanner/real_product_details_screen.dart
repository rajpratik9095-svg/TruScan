import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/openfoodfacts_service.dart';
import '../../services/ai_service.dart';

class RealProductDetailsScreen extends StatefulWidget {
  final OpenFoodFactsProduct product;
  
  const RealProductDetailsScreen({super.key, required this.product});

  @override
  State<RealProductDetailsScreen> createState() => _RealProductDetailsScreenState();
}

class _RealProductDetailsScreenState extends State<RealProductDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Product Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: const Color(0xFF667eea),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Product Image
                  if (product.imageUrl.isNotEmpty)
                    Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                    )
                  else
                    _buildImagePlaceholder(),
                  
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  
                  // Nutriscore Badge
                  if (product.nutriscoreGrade.isNotEmpty)
                    Positioned(
                      top: 80,
                      right: 16,
                      child: _buildNutriscoreBadgeLarge(product.nutriscoreGrade),
                    ),
                ],
              ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name & Brand
                  Text(
                    product.productName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (product.brand.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.business, size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          product.brand,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  if (product.quantity.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      product.quantity,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                  const SizedBox(height: 20),
                  
                  // Health Score Card
                  _buildHealthScoreCard(product),
                  const SizedBox(height: 20),
                  
                  // Score Badges Row
                  _buildScoreBadges(product),
                  const SizedBox(height: 24),
                  
                  // Nutrition Facts
                  _buildSectionTitle('🍎 Nutrition Facts', 'Per 100g'),
                  const SizedBox(height: 12),
                  _buildNutritionCard(product, isDark),
                  const SizedBox(height: 24),
                  
                  // Allergens
                  if (product.allergens.isNotEmpty) ...[
                    _buildSectionTitle('⚠️ Allergens', ''),
                    const SizedBox(height: 12),
                    _buildAllergensCard(product),
                    const SizedBox(height: 24),
                  ],
                  
                  // Ingredients
                  if (product.ingredientsText.isNotEmpty) ...[
                    _buildSectionTitle('📋 Ingredients', ''),
                    const SizedBox(height: 12),
                    _buildIngredientsCard(product, isDark),
                    const SizedBox(height: 24),
                  ],
                  
                  // Labels
                  if (product.labels.isNotEmpty) ...[
                    _buildSectionTitle('🏷️ Labels', ''),
                    const SizedBox(height: 12),
                    _buildLabelsChips(product),
                    const SizedBox(height: 24),
                  ],
                  
                  // Origin
                  if (product.countries.isNotEmpty || product.origins.isNotEmpty) ...[
                    _buildSectionTitle('🌍 Origin', ''),
                    const SizedBox(height: 12),
                    _buildOriginCard(product, isDark),
                    const SizedBox(height: 24),
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

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.fastfood, size: 80, color: Colors.white54),
      ),
    );
  }

  Widget _buildNutriscoreBadgeLarge(String grade) {
    final colors = {
      'a': const Color(0xFF038141),
      'b': const Color(0xFF85BB2F),
      'c': const Color(0xFFFECB02),
      'd': const Color(0xFFEE8100),
      'e': const Color(0xFFE63E11),
    };
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors[grade.toLowerCase()] ?? Colors.grey,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Nutri-Score',
            style: TextStyle(color: Colors.white, fontSize: 10),
          ),
          Text(
            grade.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthScoreCard(OpenFoodFactsProduct product) {
    final score = product.healthScore;
    
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
                'Health Score',
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

  Widget _buildScoreBadges(OpenFoodFactsProduct product) {
    return Row(
      children: [
        if (product.novaGroup.isNotEmpty)
          Expanded(child: _buildScoreTile('NOVA', product.novaGroup, _getNovaColor(product.novaGroup))),
        const SizedBox(width: 12),
        if (product.ecoscoreGrade.isNotEmpty)
          Expanded(child: _buildScoreTile('Eco-Score', product.ecoscoreGrade.toUpperCase(), _getEcoColor(product.ecoscoreGrade))),
        const SizedBox(width: 12),
        Expanded(child: _buildScoreTile('Calories', '${product.calories.toStringAsFixed(0)}', Colors.orange)),
      ],
    );
  }

  Widget _buildScoreTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (subtitle.isNotEmpty)
          Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
      ],
    );
  }

  Widget _buildNutritionCard(OpenFoodFactsProduct product, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildNutritionRow('🔥 Energy', '${product.calories.toStringAsFixed(0)}', 'kcal', Colors.orange),
          _buildNutritionRow('💪 Protein', product.protein.toStringAsFixed(1), 'g', Colors.blue),
          _buildNutritionRow('🌾 Carbohydrates', product.carbs.toStringAsFixed(1), 'g', Colors.brown),
          _buildNutritionRow('🍬 Sugars', product.sugar.toStringAsFixed(1), 'g', Colors.pink),
          _buildNutritionRow('💧 Fat', product.fat.toStringAsFixed(1), 'g', Colors.amber),
          _buildNutritionRow('🥬 Fiber', product.fiber.toStringAsFixed(1), 'g', Colors.green),
          _buildNutritionRow('🧂 Salt', product.salt.toStringAsFixed(2), 'g', Colors.grey),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value, String unit, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color),
              ),
              const SizedBox(width: 4),
              Text(unit, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllergensCard(OpenFoodFactsProduct product) {
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
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: product.allergens.map((a) => Chip(
                label: Text(a, style: const TextStyle(fontSize: 12)),
                backgroundColor: Colors.red.shade100,
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsCard(OpenFoodFactsProduct product, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        product.ingredientsText,
        style: TextStyle(fontSize: 14, height: 1.5, color: isDark ? Colors.grey[300] : Colors.grey[700]),
      ),
    );
  }

  Widget _buildLabelsChips(OpenFoodFactsProduct product) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: product.labels.take(10).map((l) => Chip(
        label: Text(l, style: const TextStyle(fontSize: 11)),
        backgroundColor: Colors.blue.shade50,
      )).toList(),
    );
  }

  Widget _buildOriginCard(OpenFoodFactsProduct product, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.countries.isNotEmpty)
            Row(
              children: [
                const Icon(Icons.public, size: 20, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(child: Text(product.countries)),
              ],
            ),
          if (product.origins.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 20, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(child: Text(product.origins)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  LinearGradient _getScoreGradient(double score) {
    if (score >= 7.0) return const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]);
    if (score >= 4.0) return const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]);
    return const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)]);
  }

  IconData _getScoreIcon(double score) {
    if (score >= 7.0) return Icons.sentiment_very_satisfied;
    if (score >= 4.0) return Icons.sentiment_satisfied;
    return Icons.sentiment_dissatisfied;
  }

  String _getScoreLabel(double score) {
    if (score >= 7.0) return 'Good Choice!';
    if (score >= 4.0) return 'Moderate';
    return 'Not Recommended';
  }

  Color _getNovaColor(String nova) {
    switch (nova) {
      case '1': return Colors.green;
      case '2': return Colors.lightGreen;
      case '3': return Colors.orange;
      case '4': return Colors.red;
      default: return Colors.grey;
    }
  }

  Color _getEcoColor(String eco) {
    switch (eco.toLowerCase()) {
      case 'a': return Colors.green;
      case 'b': return Colors.lightGreen;
      case 'c': return Colors.yellow.shade700;
      case 'd': return Colors.orange;
      case 'e': return Colors.red;
      default: return Colors.grey;
    }
  }
}
