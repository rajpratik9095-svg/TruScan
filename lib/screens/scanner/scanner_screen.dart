import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart' as mlkit;
import '../../controllers/scanner_controller.dart';
import '../../config/theme.dart';
import '../../services/ai_service.dart';
import '../../services/openfoodfacts_service.dart';
import 'product_details_screen.dart';
import 'ai_product_screen.dart';
import 'product_search_screen.dart';
import 'real_product_details_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final scannerController = Get.find<ScannerController>();
  late MobileScannerController cameraController;
  bool isScanned = false;
  bool isFlashOn = false;
  bool isFrontCamera = false;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _toggleFlash() async {
    try {
      await cameraController.toggleTorch();
      setState(() => isFlashOn = !isFlashOn);
    } catch (e) {
      debugPrint('Flash error: $e');
    }
  }

  void _toggleCamera() async {
    try {
      await cameraController.switchCamera();
      setState(() => isFrontCamera = !isFrontCamera);
    } catch (e) {
      debugPrint('Camera switch error: $e');
    }
  }

  /// Smart Image Scanner - Google Lens like feature
  /// First tries barcode, then falls back to AI Vision recognition
  Future<void> _smartScanImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      
      if (image != null) {
        setState(() => isProcessing = true);
        
        Get.snackbar(
          '🔍 Scanning...',
          'Looking for barcode or identifying product',
          backgroundColor: const Color(0xFF667eea),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
        
        // Step 1: Try to find barcode in image
        bool barcodeFound = false;
        try {
          final inputImage = mlkit.InputImage.fromFilePath(image.path);
          final barcodeScanner = mlkit.BarcodeScanner();
          final List<mlkit.Barcode> barcodes = await barcodeScanner.processImage(inputImage);
          await barcodeScanner.close();
          
          if (barcodes.isNotEmpty) {
            final barcode = barcodes.first.rawValue;
            if (barcode != null && barcode.isNotEmpty) {
              barcodeFound = true;
              setState(() => isProcessing = false);
              
              Get.snackbar(
                '✅ Barcode Found!',
                'Fetching product details...',
                backgroundColor: Colors.green,
                colorText: Colors.white,
                snackPosition: SnackPosition.TOP,
                duration: const Duration(seconds: 1),
              );
              
              await _processBarcode(barcode);
              return;
            }
          }
        } catch (e) {
          debugPrint('Barcode scan: $e');
        }
        
        // Step 2: If no barcode, use AI Vision
        if (!barcodeFound) {
          Get.snackbar(
            '🤖 Using AI Vision',
            'Identifying product visually...',
            backgroundColor: const Color(0xFF764ba2),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 2),
          );
          
          try {
            final imageBytes = await image.readAsBytes();
            final recognizedProduct = await AIService.recognizeProductFromImage(imageBytes);
            
            setState(() => isProcessing = false);
            
            if (recognizedProduct != null) {
              Get.to(() => AIProductScreen(product: recognizedProduct));
            } else {
              Get.snackbar(
                'Could not identify',
                'Please try with a clearer product image',
                backgroundColor: Colors.orange,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          } catch (e) {
            debugPrint('AI Vision error: $e');
            Get.snackbar(
              'AI Error',
              'Could not analyze. Check API key in ai_service.dart',
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        }
        
        setState(() => isProcessing = false);
      }
    } catch (e) {
      debugPrint('Smart scan error: $e');
      setState(() => isProcessing = false);
    }
  }

  /// Capture photo from camera and scan
  Future<void> _captureAndScan() async {
    try {
      // On Web, camera capture via ImagePicker opens file picker
      // Instead, show helpful message that camera is already live for barcodes
      // and user should use Gallery for photo product scanning
      if (GetPlatform.isWeb) {
        Get.snackbar(
          '📷 Camera Already Active!',
          'Point at barcode to scan automatically.\nFor photo products, use Gallery button.',
          backgroundColor: const Color(0xFF667eea),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.info_outline, color: Colors.white),
        );
        return;
      }
      
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      
      if (image != null) {
        setState(() => isProcessing = true);
        
        Get.snackbar(
          '📷 Photo Captured!',
          'Analyzing with AI...',
          backgroundColor: const Color(0xFF667eea),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
        
        // First try barcode scan
        bool barcodeFound = false;
        try {
          final inputImage = mlkit.InputImage.fromFilePath(image.path);
          final barcodeScanner = mlkit.BarcodeScanner();
          final List<mlkit.Barcode> barcodes = await barcodeScanner.processImage(inputImage);
          await barcodeScanner.close();
          
          if (barcodes.isNotEmpty) {
            final barcode = barcodes.first.rawValue;
            if (barcode != null && barcode.isNotEmpty) {
              barcodeFound = true;
              setState(() => isProcessing = false);
              await _processBarcode(barcode);
              return;
            }
          }
        } catch (e) {
          debugPrint('Barcode scan: $e');
        }
        
        // If no barcode, use AI Vision
        if (!barcodeFound) {
          try {
            final imageBytes = await image.readAsBytes();
            final recognizedProduct = await AIService.recognizeProductFromImage(imageBytes);
            
            setState(() => isProcessing = false);
            
            if (recognizedProduct != null) {
              Get.to(() => AIProductScreen(product: recognizedProduct));
            } else {
              Get.snackbar(
                'Could not identify',
                'Try taking a clearer photo',
                backgroundColor: Colors.orange,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          } catch (e) {
            debugPrint('AI Vision error: $e');
            Get.snackbar(
              'AI Error',
              'Could not analyze. Check API key.',
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        }
        
        setState(() => isProcessing = false);
      }
    } catch (e) {
      debugPrint('Camera capture error: $e');
      setState(() => isProcessing = false);
    }
  }

  void _handleBarcode(BarcodeCapture capture) async {
    if (isScanned || isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first.rawValue;
    if (barcode == null) return;

    await _processBarcode(barcode);
  }

  Future<void> _processBarcode(String barcode) async {
    setState(() {
      isScanned = true;
      isProcessing = true;
    });

    Get.snackbar(
      '🔍 Searching...',
      'Looking up product: $barcode',
      backgroundColor: const Color(0xFF667eea),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );

    // Try OpenFoodFacts API first
    final product = await OpenFoodFactsService.getProductByBarcode(barcode);
    
    setState(() => isProcessing = false);

    if (product != null && product.productName.isNotEmpty) {
      Get.snackbar(
        '✅ Product Found!',
        product.productName,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 1),
      );
      Get.to(() => RealProductDetailsScreen(product: product));
    } else {
      // Fallback to local database
      final localProduct = await scannerController.scanBarcode(barcode);
      
      if (localProduct != null) {
        Get.to(() => const ProductDetailsScreen());
      } else {
        Get.snackbar(
          'Product Not Found',
          'Barcode: $barcode - Try searching by name',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          mainButton: TextButton(
            onPressed: () => Get.to(() => const ProductSearchScreen()),
            child: const Text('Search', style: TextStyle(color: Colors.white)),
          ),
        );
      }
    }

    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => isScanned = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera
          MobileScanner(
            controller: cameraController,
            onDetect: _handleBarcode,
          ),

          // Overlay
          CustomPaint(
            painter: ScannerOverlayPainter(),
            child: const SizedBox.expand(),
          ),

          // Processing
          if (isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text('Processing...', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),

          // Top Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Scan Barcode',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Row(
                    children: [
                      // Flash
                      GestureDetector(
                        onTap: _toggleFlash,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isFlashOn ? AppTheme.primaryGradientStart : Colors.black54,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isFlashOn ? Icons.flash_on : Icons.flash_off,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Camera Switch
                      GestureDetector(
                        onTap: _toggleCamera,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isFrontCamera ? AppTheme.primaryGradientStart : Colors.black54,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.cameraswitch, color: Colors.white, size: 22),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                ),
              ),
              child: Column(
                children: [
                  // Search Bar - Tap to open search
                  GestureDetector(
                    onTap: () => Get.to(() => const ProductSearchScreen()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.white70, size: 20),
                          const SizedBox(width: 10),
                          const Text(
                            'Search product name...',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Tap',
                              style: TextStyle(color: Colors.white54, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Action Buttons - Image | Camera | History
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Choose Image from Gallery
                      GestureDetector(
                        onTap: _smartScanImage,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.photo_library, color: Colors.white, size: 24),
                            ),
                            const SizedBox(height: 6),
                            const Text('Gallery', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                      
                      // Camera Capture Button - Take Photo
                      GestureDetector(
                        onTap: _captureAndScan,
                        child: Container(
                          width: 75,
                          height: 75,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF667eea).withOpacity(0.5),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, color: Colors.white, size: 28),
                              Text('Capture', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      
                      // History
                      GestureDetector(
                        onTap: _showHistory,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.history, color: Colors.white, size: 24),
                            ),
                            const SizedBox(height: 6),
                            const Text('History', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHistory() {
    final recentScans = scannerController.getRecentScans(limit: 5);
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Scans', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
              ],
            ),
            const SizedBox(height: 12),
            if (recentScans.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: Text('No recent scans', style: TextStyle(color: Colors.grey))),
              )
            else
              ...recentScans.map((product) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(product.imageUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.inventory_2, color: Colors.grey),
                    ),
                  ),
                ),
                title: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(product.brand, style: const TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Get.back();
                  scannerController.currentProduct.value = product;
                  Get.to(() => const ProductDetailsScreen());
                },
              )),
          ],
        ),
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.5);

    final scanArea = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 60),
      width: size.width * 0.72,
      height: size.width * 0.72,
    );

    canvas.drawPath(
      Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addRRect(RRect.fromRectAndRadius(scanArea, const Radius.circular(16)))
        ..fillType = PathFillType.evenOdd,
      overlayPaint,
    );

    final cornerPaint = Paint()
      ..color = AppTheme.primaryGradientStart
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLen = 30.0;

    // Corners
    canvas.drawLine(Offset(scanArea.left, scanArea.top + cornerLen), Offset(scanArea.left, scanArea.top), cornerPaint);
    canvas.drawLine(Offset(scanArea.left, scanArea.top), Offset(scanArea.left + cornerLen, scanArea.top), cornerPaint);
    canvas.drawLine(Offset(scanArea.right - cornerLen, scanArea.top), Offset(scanArea.right, scanArea.top), cornerPaint);
    canvas.drawLine(Offset(scanArea.right, scanArea.top), Offset(scanArea.right, scanArea.top + cornerLen), cornerPaint);
    canvas.drawLine(Offset(scanArea.left, scanArea.bottom - cornerLen), Offset(scanArea.left, scanArea.bottom), cornerPaint);
    canvas.drawLine(Offset(scanArea.left, scanArea.bottom), Offset(scanArea.left + cornerLen, scanArea.bottom), cornerPaint);
    canvas.drawLine(Offset(scanArea.right - cornerLen, scanArea.bottom), Offset(scanArea.right, scanArea.bottom), cornerPaint);
    canvas.drawLine(Offset(scanArea.right, scanArea.bottom - cornerLen), Offset(scanArea.right, scanArea.bottom), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
