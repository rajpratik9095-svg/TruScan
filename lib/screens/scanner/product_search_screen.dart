import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/openfoodfacts_service.dart';
import 'real_product_details_screen.dart';

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<OpenFoodFactsProduct> _results = [];
  bool _isLoading = false;
  String _searchQuery = '';
  
  // Country filter
  String _selectedCountry = 'in'; // India default
  final Map<String, String> _countries = {
    'in': '🇮🇳 India',
    'world': '🌍 World',
    'pk': '🇵🇰 Pakistan',
    'bd': '🇧🇩 Bangladesh',
    'us': '🇺🇸 USA',
    'uk': '🇬🇧 UK',
    'ae': '🇦🇪 UAE',
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    
    setState(() {
      _isLoading = true;
      _searchQuery = query;
    });
    
    final results = await OpenFoodFactsService.searchProducts(query, country: _selectedCountry);
    
    if (_searchQuery == query) {
      setState(() {
        _results = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // Header with gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button and title
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Product Search',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        onChanged: (value) => _search(value),
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Search milk, chips, biscuits...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.close, color: Colors.grey[600]),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _results = []);
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Country Chips
          Container(
            height: 55,
            padding: const EdgeInsets.only(top: 12),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _countries.entries.map((e) => _buildCountryChip(e.key, e.value)).toList(),
            ),
          ),
          
          // Results Header
          if (_results.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_results.length} Products Found',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          
          // Content Area
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _results.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _results.length,
                        itemBuilder: (context, index) => _buildProductCard(_results[index], isDark),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryChip(String code, String name) {
    final isSelected = _selectedCountry == code;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedCountry = code);
          if (_searchController.text.isNotEmpty) {
            _search(_searchController.text);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)])
                : null,
            color: isSelected ? null : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.3),
            ),
          ),
          child: Text(
            name,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Searching products...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Finding the best results for you',
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _searchController.text.isEmpty ? Icons.search : Icons.inbox_outlined,
                size: 50,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _searchController.text.isEmpty ? 'Start Searching' : 'No Products Found',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isEmpty
                  ? 'Search for any product by name'
                  : 'Try different keywords or change country',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            if (_searchController.text.isEmpty) ...[
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: ['Milk', 'Chips', 'Biscuits', 'Cola'].map((s) => 
                  ActionChip(
                    label: Text(s),
                    backgroundColor: const Color(0xFF667eea).withOpacity(0.1),
                    labelStyle: const TextStyle(color: Color(0xFF667eea)),
                    onPressed: () {
                      _searchController.text = s;
                      _search(s);
                    },
                  ),
                ).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(OpenFoodFactsProduct product, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2128) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.to(() => RealProductDetailsScreen(product: product)),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                    ),
                    child: product.imageUrl.isNotEmpty
                        ? Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(product),
                          )
                        : _buildPlaceholder(product),
                  ),
                ),
                const SizedBox(width: 14),
                
                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.productName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (product.brand.isNotEmpty)
                        Text(
                          product.brand,
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (product.nutriscoreGrade.isNotEmpty)
                            _buildNutriscoreBadge(product.nutriscoreGrade),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${product.calories.toStringAsFixed(0)} kcal',
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Arrow
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667eea).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF667eea)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(OpenFoodFactsProduct product) {
    Color bgColor = const Color(0xFF667eea);
    IconData icon = Icons.inventory_2;
    
    final name = product.productName.toLowerCase();
    if (name.contains('milk') || name.contains('dairy')) {
      bgColor = Colors.blue;
      icon = Icons.water_drop;
    } else if (name.contains('chip') || name.contains('snack')) {
      bgColor = Colors.orange;
      icon = Icons.lunch_dining;
    } else if (name.contains('cola') || name.contains('drink')) {
      bgColor = Colors.red;
      icon = Icons.local_drink;
    } else if (name.contains('biscuit') || name.contains('cookie')) {
      bgColor = Colors.brown;
      icon = Icons.cookie;
    }
    
    return Container(
      width: 75,
      height: 75,
      color: bgColor.withOpacity(0.2),
      child: Icon(icon, color: bgColor, size: 32),
    );
  }

  Widget _buildNutriscoreBadge(String grade) {
    final colors = {
      'a': const Color(0xFF038141),
      'b': const Color(0xFF85BB2F),
      'c': const Color(0xFFFECB02),
      'd': const Color(0xFFEE8100),
      'e': const Color(0xFFE63E11),
    };
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors[grade.toLowerCase()] ?? Colors.grey,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Nutri-${grade.toUpperCase()}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
