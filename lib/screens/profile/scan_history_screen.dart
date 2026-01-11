import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/scanner_controller.dart';
import '../../config/theme.dart';
import '../../widgets/product_card.dart';
import '../scanner/product_details_screen.dart';

class ScanHistoryScreen extends StatelessWidget {
  const ScanHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scannerController = Get.find<ScannerController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showClearDialog(scannerController),
            tooltip: 'Clear History',
          ),
        ],
      ),
      body: Obx(() {
        final scans = scannerController.scanHistory;

        if (scans.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 100,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 24),
                const Text(
                  'No Scan History',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Products you scan will appear here',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Start Scanning'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGradientStart,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Stats Bar
            Container(
              padding: const EdgeInsets.all(16),
              color: AppTheme.primaryGradientStart.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Total', scans.length.toString()),
                  _buildStatItem('This Week', scannerController.getScansThisWeek().toString()),
                  _buildStatItem('This Month', scannerController.getScansThisMonth().toString()),
                ],
              ),
            ),
            
            // List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: scans.length,
                itemBuilder: (context, index) {
                  final product = scans[index];
                  return Dismissible(
                    key: Key(product.barcode),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) {
                      scannerController.removeFromHistory(product.barcode);
                      Get.snackbar('Deleted', '${product.name} removed from history',
                          backgroundColor: Colors.red, colorText: Colors.white);
                    },
                    child: ProductCard(
                      product: product,
                      onTap: () {
                        scannerController.currentProduct.value = product;
                        Get.to(() => const ProductDetailsScreen());
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGradientStart,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _showClearDialog(ScannerController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear History?'),
        content: const Text('This will delete all your scan history. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.clearHistory();
              Get.back();
              Get.snackbar('Cleared', 'Scan history cleared',
                  backgroundColor: AppTheme.success, colorText: Colors.white);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
