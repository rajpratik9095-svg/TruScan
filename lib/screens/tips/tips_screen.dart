import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/health_tips_service.dart';
import '../../services/ads_service.dart';
import '../../config/theme.dart';

class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  String selectedCategory = 'all';
  final searchController = TextEditingController();
  List<HealthTip> allTips = [];
  List<HealthTip> filteredTips = [];
  bool isLoading = true;
  HealthTip? tipOfTheDay;
  
  // Get ads controller
  late AdsController adsController;

  final List<Map<String, dynamic>> categories = [
    {'key': 'all', 'label': 'All', 'icon': Icons.apps, 'color': const Color(0xFF667eea)},
    {'key': 'health', 'label': 'Health', 'icon': Icons.favorite, 'color': Colors.red},
    {'key': 'nutrition', 'label': 'Nutrition', 'icon': Icons.restaurant, 'color': Colors.green},
    {'key': 'fitness', 'label': 'Fitness', 'icon': Icons.fitness_center, 'color': Colors.orange},
    {'key': 'mental', 'label': 'Mental', 'icon': Icons.psychology, 'color': Colors.purple},
    {'key': 'product', 'label': 'Products', 'icon': Icons.qr_code_scanner, 'color': Colors.teal},
  ];

  @override
  void initState() {
    super.initState();
    // Initialize ads controller if not already
    if (!Get.isRegistered<AdsController>()) {
      Get.put(AdsController(), permanent: true);
    }
    adsController = Get.find<AdsController>();
    _loadTips();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTips() async {
    setState(() => isLoading = true);
    
    final tips = await HealthTipsService.fetchTips();
    tipOfTheDay = await HealthTipsService.getTipOfTheDay();
    
    setState(() {
      allTips = tips;
      filteredTips = tips;
      isLoading = false;
    });
  }

  void _filterTips() {
    setState(() {
      var tips = allTips;
      
      // Filter by category
      if (selectedCategory != 'all') {
        tips = tips.where((tip) => tip.category == selectedCategory).toList();
      }
      
      // Filter by search query
      if (searchController.text.isNotEmpty) {
        final query = searchController.text.toLowerCase();
        tips = tips.where((tip) {
          return tip.title.toLowerCase().contains(query) ||
              tip.content.toLowerCase().contains(query);
        }).toList();
      }
      
      filteredTips = tips;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: _loadTips,
        color: const Color(0xFF667eea),
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFF667eea),
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('Health Tips', style: TextStyle(fontWeight: FontWeight.bold)),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                  ),
                ),
              ),
            ),
            
            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) => _filterTips(),
                    decoration: InputDecoration(
                      hintText: 'Search health tips...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF667eea)),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                searchController.clear();
                                _filterTips();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ),
              ),
            ),
            
            // Tip of the Day
            if (tipOfTheDay != null && !isLoading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildTipOfTheDay(tipOfTheDay!),
                ),
              ),
            
            // Category Chips
            SliverToBoxAdapter(
              child: Container(
                height: 50,
                margin: const EdgeInsets.only(top: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return _buildCategoryChip(cat);
                  },
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            
            // Loading or Content
            if (isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: Color(0xFF667eea))),
              )
            else if (filteredTips.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('No tips found', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                    ],
                  ),
                ),
              )
            else
              // Tips Grid with Ads
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // Insert ad every 4 tips
                      if (index > 0 && index % 4 == 0) {
                        return Column(
                          children: [
                            _buildAdBanner(),
                            const SizedBox(height: 12),
                            _buildTipCard(filteredTips[index], isDark),
                          ],
                        );
                      }
                      return _buildTipCard(filteredTips[index], isDark);
                    },
                    childCount: filteredTips.length,
                  ),
                ),
              ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildTipOfTheDay(HealthTip tip) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.lightbulb, color: Colors.yellow, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                '💡 Tip of the Day',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            tip.title,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            tip.content,
            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, height: 1.5),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(Map<String, dynamic> cat) {
    final isSelected = selectedCategory == cat['key'];
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () {
          setState(() => selectedCategory = cat['key']);
          _filterTips();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(colors: [cat['color'], (cat['color'] as Color).withOpacity(0.7)])
                : null,
            color: isSelected ? null : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: [
              Icon(cat['icon'], size: 18, color: isSelected ? Colors.white : cat['color']),
              const SizedBox(width: 6),
              Text(
                cat['label'],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipCard(HealthTip tip, bool isDark) {
    final categoryData = categories.firstWhere(
      (c) => c['key'] == tip.category,
      orElse: () => categories.first,
    );
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2128) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showTipDetails(tip),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: (categoryData['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconData(tip.icon),
                    color: categoryData['color'],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: (categoryData['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          categoryData['label'],
                          style: TextStyle(
                            color: categoryData['color'],
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        tip.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tip.content,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdBanner() {
    final storage = GetStorage();
    final adsEnabled = storage.read('ads_enabled') ?? true;
    
    if (!adsEnabled) return const SizedBox.shrink();
    
    final ad = adsController.getRandomAd();
    if (ad == null) return const SizedBox.shrink();
    
    return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade100, Colors.deepPurple.shade50],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.purple.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sponsored tag
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Sponsored',
                    style: TextStyle(fontSize: 9, color: Colors.purple, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                // Close button
                GestureDetector(
                  onTap: () {
                    // Optionally hide this specific ad
                    setState(() {});
                  },
                  child: Icon(Icons.close, size: 18, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // Ad Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    ad.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.purple.shade200,
                      child: const Icon(Icons.campaign, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Ad Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ad.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      if (ad.description != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          ad.description!,
                          style: TextStyle(color: Colors.grey[700], fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                // Learn More
                if (ad.actionUrl != null)
                  ElevatedButton(
                    onPressed: () async {
                      if (await canLaunchUrl(Uri.parse(ad.actionUrl!))) {
                        await launchUrl(Uri.parse(ad.actionUrl!));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Learn More', style: TextStyle(fontSize: 11)),
                  ),
              ],
            ),
          ],
        ),
      );
  }

  IconData _getIconData(String iconName) {
    final icons = {
      'water_drop': Icons.water_drop,
      'bedtime': Icons.bedtime,
      'medical_services': Icons.medical_services,
      'clean_hands': Icons.clean_hands,
      'accessibility': Icons.accessibility,
      'visibility': Icons.visibility,
      'air': Icons.air,
      'wb_sunny': Icons.wb_sunny,
      'vaccines': Icons.vaccines,
      'monitor_weight': Icons.monitor_weight,
      'eco': Icons.eco,
      'grain': Icons.grain,
      'no_food': Icons.no_food,
      'restaurant': Icons.restaurant,
      'opacity': Icons.opacity,
      'local_dining': Icons.local_dining,
      'free_breakfast': Icons.free_breakfast,
      'straighten': Icons.straighten,
      'grass': Icons.grass,
      'fastfood': Icons.fastfood,
      'palette': Icons.palette,
      'self_improvement': Icons.self_improvement,
      'directions_walk': Icons.directions_walk,
      'fitness_center': Icons.fitness_center,
      'event_seat': Icons.event_seat,
      'whatshot': Icons.whatshot,
      'ac_unit': Icons.ac_unit,
      'sports_tennis': Icons.sports_tennis,
      'track_changes': Icons.track_changes,
      'park': Icons.park,
      'people': Icons.people,
      'favorite': Icons.favorite,
      'phonelink_off': Icons.phonelink_off,
      'school': Icons.school,
      'spa': Icons.spa,
      'support_agent': Icons.support_agent,
      'home': Icons.home,
      'sentiment_satisfied': Icons.sentiment_satisfied,
      'event': Icons.event,
      'fact_check': Icons.fact_check,
      'list': Icons.list,
      'warning': Icons.warning,
      'science': Icons.science,
      'compare_arrows': Icons.compare_arrows,
      'verified': Icons.verified,
      'grade': Icons.grade,
      'stairs': Icons.stairs,
    };
    return icons[iconName] ?? Icons.lightbulb;
  }

  void _showTipDetails(HealthTip tip) {
    final categoryData = categories.firstWhere(
      (c) => c['key'] == tip.category,
      orElse: () => categories.first,
    );
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Icon and Category
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (categoryData['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_getIconData(tip.icon), color: categoryData['color'], size: 28),
                ),
                const SizedBox(width: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (categoryData['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    categoryData['label'],
                    style: TextStyle(
                      color: categoryData['color'],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              tip.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  tip.content,
                  style: TextStyle(fontSize: 16, height: 1.6, color: Colors.grey[700]),
                ),
              ),
            ),
            
            // Close Button
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Got it!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
