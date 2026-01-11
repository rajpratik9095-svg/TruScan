import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../config/theme.dart';

class PermissionBottomSheet {
  static final storage = GetStorage();
  
  static Future<void> showCameraPermission() async {
    final shown = storage.read('camera_permission_shown') ?? false;
    if (shown) return;

    await Get.bottomSheet(
      _buildCameraSheet(),
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
    );
  }

  static Widget _buildCameraSheet() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          
          // Icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt_outlined,
              color: Colors.red,
              size: 45,
            ),
          ),
          const SizedBox(height: 24),
          
          // Title
          const Text(
            'Camera Permission Required',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          
          // Description
          Text(
            'TrueScan needs camera access to scan\nproduct barcodes and QR codes.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          
          // Enable button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                storage.write('camera_permission_shown', true);
                Get.back(); // Close bottom sheet first
                await Permission.camera.request();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'ENABLE PERMISSION',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Not now button
          TextButton(
            onPressed: () {
              storage.write('camera_permission_shown', true);
              Get.back();
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            ),
            child: Text(
              'NOT NOW',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
