import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class HealthTip {
  final String id;
  final String title;
  final String content;
  final String category;
  final String? imageUrl;
  final String icon;
  final int priority;
  final DateTime createdAt;

  HealthTip({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.imageUrl,
    this.icon = 'lightbulb',
    this.priority = 0,
    required this.createdAt,
  });

  factory HealthTip.fromJson(Map<String, dynamic> json) {
    return HealthTip(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? 'health',
      imageUrl: json['image_url'],
      icon: json['icon'] ?? 'lightbulb',
      priority: json['priority'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'category': category,
    'image_url': imageUrl,
    'icon': icon,
    'priority': priority,
  };
}

class HealthTipsService {
  static final _supabase = SupabaseService.client;
  
  // Cache for offline access
  static List<HealthTip> _cachedTips = [];
  
  /// Fetch all active health tips from Supabase
  static Future<List<HealthTip>> fetchTips() async {
    try {
      final response = await _supabase
          .from('health_tips')
          .select()
          .eq('is_active', true)
          .order('priority', ascending: false)
          .limit(100);
      
      final tips = (response as List)
          .map((json) => HealthTip.fromJson(json))
          .toList();
      
      // Cache the tips
      _cachedTips = tips;
      
      print('📚 Fetched ${tips.length} health tips from Supabase');
      return tips;
    } catch (e) {
      print('❌ Error fetching health tips: $e');
      // Return cached tips if available
      if (_cachedTips.isNotEmpty) {
        return _cachedTips;
      }
      // Return demo tips as fallback
      return _getDemoTips();
    }
  }
  
  /// Fetch tips by category
  static Future<List<HealthTip>> fetchTipsByCategory(String category) async {
    try {
      if (category == 'all') {
        return fetchTips();
      }
      
      final response = await _supabase
          .from('health_tips')
          .select()
          .eq('is_active', true)
          .eq('category', category)
          .order('priority', ascending: false);
      
      return (response as List)
          .map((json) => HealthTip.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching tips by category: $e');
      return _getDemoTips().where((t) => t.category == category).toList();
    }
  }
  
  /// Get tip of the day (highest priority or random)
  static Future<HealthTip?> getTipOfTheDay() async {
    try {
      final tips = await fetchTips();
      if (tips.isEmpty) return null;
      
      // Return highest priority tip
      return tips.first;
    } catch (e) {
      return null;
    }
  }
  
  /// Demo tips fallback when Supabase is unavailable
  static List<HealthTip> _getDemoTips() {
    return [
      HealthTip(
        id: '1',
        title: 'Stay Hydrated',
        content: 'Drink at least 8 glasses of water daily. Water helps maintain body temperature, removes toxins, and keeps your skin healthy.',
        category: 'health',
        icon: 'water_drop',
        priority: 100,
        createdAt: DateTime.now(),
      ),
      HealthTip(
        id: '2',
        title: 'Eat More Vegetables',
        content: 'Include 5 servings of vegetables daily. Vegetables are rich in vitamins, minerals, and fiber.',
        category: 'nutrition',
        icon: 'eco',
        priority: 99,
        createdAt: DateTime.now(),
      ),
      HealthTip(
        id: '3',
        title: 'Walk 10,000 Steps Daily',
        content: 'Walking is the easiest form of exercise. Use a pedometer or phone app to track your steps.',
        category: 'fitness',
        icon: 'directions_walk',
        priority: 98,
        createdAt: DateTime.now(),
      ),
      HealthTip(
        id: '4',
        title: 'Practice Meditation',
        content: 'Just 10 minutes of daily meditation can reduce stress and improve focus.',
        category: 'mental',
        icon: 'self_improvement',
        priority: 97,
        createdAt: DateTime.now(),
      ),
      HealthTip(
        id: '5',
        title: 'Check Expiry Dates',
        content: 'Always check expiry dates before buying products. Use TrueScan to verify product information!',
        category: 'product',
        icon: 'event',
        priority: 96,
        createdAt: DateTime.now(),
      ),
    ];
  }
}
