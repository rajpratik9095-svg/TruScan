import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../config/constants.dart';
import '../models/product_model.dart';
import 'dart:convert';

class ScannerController extends GetxController {
  final storage = GetStorage();
  
  final RxList<Product> scannedProducts = <Product>[].obs;
  final Rx<Product?> currentProduct = Rx<Product?>(null);
  final RxBool isScanning = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadScannedProducts();
  }

  void _loadScannedProducts() {
    final productsJson = storage.read(AppConstants.storageKeyScannedProducts);
    if (productsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(productsJson);
        scannedProducts.value = decoded.map((json) => Product.fromJson(json)).toList();
      } catch (e) {
        scannedProducts.value = [];
      }
    }
  }

  void _saveScannedProducts() {
    final jsonList = scannedProducts.map((product) => product.toJson()).toList();
    storage.write(AppConstants.storageKeyScannedProducts, jsonEncode(jsonList));
  }

  Future<Product?> scanBarcode(String barcode) async {
    isScanning.value = true;
    
    // Simulate scanning delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Get product from database
    final product = ProductDatabase.getProductByBarcode(barcode);
    
    if (product != null) {
      currentProduct.value = product;
      
      // Add to scan history
      scannedProducts.insert(0, product);
      
      // Keep only recent scans
      if (scannedProducts.length > AppConstants.maxScanHistory) {
        scannedProducts.removeLast();
      }
      
      _saveScannedProducts();
    }
    
    isScanning.value = false;
    return product;
  }

  void clearHistory() {
    scannedProducts.clear();
    _saveScannedProducts();
  }

  List<Product> getRecentScans({int limit = 5}) {
    return scannedProducts.take(limit).toList();
  }

  // Get all scan history
  List<Product> get scanHistory => scannedProducts.toList();

  // Remove specific product from history
  void removeFromHistory(String barcode) {
    scannedProducts.removeWhere((p) => p.barcode == barcode);
    _saveScannedProducts();
  }

  int get totalScans => scannedProducts.length;
  
  int getScansThisWeek() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return scannedProducts.where((p) => p.scannedAt.isAfter(weekAgo)).length;
  }
  
  int getScansThisMonth() {
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));
    return scannedProducts.where((p) => p.scannedAt.isAfter(monthAgo)).length;
  }
}
