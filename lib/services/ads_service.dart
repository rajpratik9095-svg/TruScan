import 'dart:math';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../services/supabase_service.dart';

class Ad {
  final String id;
  final String title;
  final String? description;
  final String imageUrl;
  final String? actionUrl;
  final int priority;

  Ad({
    required this.id,
    required this.title,
    this.description,
    required this.imageUrl,
    this.actionUrl,
    this.priority = 0,
  });

  factory Ad.fromJson(Map<String, dynamic> json) {
    return Ad(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      imageUrl: json['image_url'] ?? '',
      actionUrl: json['action_url'],
      priority: json['priority'] ?? 0,
    );
  }
}

class AdsService {
  static final _supabase = SupabaseService.client;
  static List<Ad> _cachedAds = [];
  
  /// Fetch all active ads from Supabase
  static Future<List<Ad>> fetchAds() async {
    try {
      final response = await _supabase
          .from('ads')
          .select()
          .eq('is_active', true)
          .order('priority', ascending: false);
      
      final ads = (response as List)
          .map((json) => Ad.fromJson(json))
          .toList();
      
      _cachedAds = ads;
      print('📢 Fetched ${ads.length} ads from Supabase');
      return ads;
    } catch (e) {
      print('❌ Error fetching ads: $e');
      if (_cachedAds.isNotEmpty) return _cachedAds;
      return _getDemoAds();
    }
  }
  
  /// Get a random ad to display
  static Future<Ad?> getRandomAd() async {
    final ads = await fetchAds();
    if (ads.isEmpty) return null;
    return ads[Random().nextInt(ads.length)];
  }
  
  /// Demo ads fallback
  static List<Ad> _getDemoAds() {
    return [
      Ad(
        id: '1',
        title: 'TrueScan Premium',
        description: 'Unlock all features! Remove ads, unlimited scans.',
        imageUrl: 'https://via.placeholder.com/400x100/667eea/ffffff?text=Premium',
        actionUrl: 'https://truescan.app/premium',
        priority: 100,
      ),
      Ad(
        id: '2',
        title: 'Healthy Recipe Book',
        description: 'Free healthy recipes ebook!',
        imageUrl: 'https://via.placeholder.com/400x100/10B981/ffffff?text=Recipes',
        priority: 90,
      ),
    ];
  }
}

/// Controller for managing ads state
class AdsController extends GetxController {
  final _storage = GetStorage();
  
  // Observable state
  final RxBool adsEnabled = true.obs;
  final RxList<Ad> ads = <Ad>[].obs;
  final Rx<Ad?> currentAd = Rx<Ad?>(null);
  
  @override
  void onInit() {
    super.onInit();
    // Load ads preference
    adsEnabled.value = _storage.read('ads_enabled') ?? true;
    // Fetch ads
    _loadAds();
  }
  
  Future<void> _loadAds() async {
    final fetchedAds = await AdsService.fetchAds();
    ads.value = fetchedAds;
    if (fetchedAds.isNotEmpty) {
      currentAd.value = fetchedAds.first;
    }
  }
  
  /// Toggle ads on/off
  void toggleAds(bool value) {
    adsEnabled.value = value;
    _storage.write('ads_enabled', value);
    print('📢 Ads ${value ? 'enabled' : 'disabled'}');
  }
  
  /// Get a random ad for display
  Ad? getRandomAd() {
    if (!adsEnabled.value || ads.isEmpty) return null;
    return ads[Random().nextInt(ads.length)];
  }
  
  /// Refresh ads from server
  Future<void> refreshAds() async {
    await _loadAds();
  }
}
