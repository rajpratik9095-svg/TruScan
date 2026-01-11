import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/ai_service.dart';
import '../../config/theme.dart';

class AIProductScreen extends StatelessWidget {
  final RecognizedProduct product;
  
  const AIProductScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF667eea),
                      const Color(0xFF764ba2),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 50),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'AI Product Recognition',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
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
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.business, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        product.brand,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Health Score
                  _buildHealthScoreCard(),
                  const SizedBox(height: 20),
                  
                  // Category & Origin
                  Row(
                    children: [
                      Expanded(child: _buildInfoCard('📦 Category', product.category, Colors.blue)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildInfoCard('🌍 Origin', product.countryOfOrigin, Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildInfoCard('💰 Price', product.mrp, Colors.orange)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildInfoCard(product.isFood ? '🍽️ Food Item' : '📦 Non-Food', product.isFood ? 'Yes' : 'No', Colors.purple)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Description
                  _buildSectionTitle('📝 Description'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                      ],
                    ),
                    child: Text(
                      product.description.isNotEmpty ? product.description : 'No description available',
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Nutrition (if food)
                  if (product.isFood && product.estimatedNutrition.isNotEmpty) ...[
                    _buildSectionTitle('🍎 Estimated Nutrition'),
                    const SizedBox(height: 12),
                    _buildNutritionCard(),
                    const SizedBox(height: 20),
                  ],
                  
                  // Ingredients
                  if (product.ingredients.isNotEmpty) ...[
                    _buildSectionTitle('📋 Ingredients'),
                    const SizedBox(height: 12),
                    _buildIngredientsCard(isDark),
                    const SizedBox(height: 20),
                  ],
                  
                  // Allergens
                  if (product.allergens.isNotEmpty) ...[
                    _buildSectionTitle('⚠️ Allergens'),
                    const SizedBox(height: 12),
                    _buildAllergensCard(),
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

  Widget _buildHealthScoreCard() {
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

  Widget _buildInfoCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildNutritionCard() {
    final nutrition = product.estimatedNutrition;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          if (nutrition['calories'] != null) _buildNutritionRow('🔥 Calories', '${nutrition['calories']}', 'kcal'),
          if (nutrition['protein'] != null) _buildNutritionRow('💪 Protein', '${nutrition['protein']}', 'g'),
          if (nutrition['carbs'] != null) _buildNutritionRow('🌾 Carbs', '${nutrition['carbs']}', 'g'),
          if (nutrition['fats'] != null) _buildNutritionRow('💧 Fats', '${nutrition['fats']}', 'g'),
          if (nutrition['sugar'] != null) _buildNutritionRow('🍬 Sugar', '${nutrition['sugar']}', 'g'),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          Text('$value $unit', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildIngredientsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: product.ingredients.map((i) => Chip(
          label: Text(i),
          backgroundColor: isDark ? Colors.grey[700] : Colors.white,
        )).toList(),
      ),
    );
  }

  Widget _buildAllergensCard() {
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
    if (score >= 7.0) {
      return const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]);
    } else if (score >= 4.0) {
      return const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]);
    } else {
      return const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)]);
    }
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
}
