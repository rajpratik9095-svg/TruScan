import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'home_tab.dart';
import '../scanner/scanner_screen.dart';
import '../diet/diet_screen.dart';
import '../tips/tips_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller exists
    final controller = Get.find<HomeTabController>();
    
    return GetBuilder<HomeTabController>(
      builder: (ctrl) => Scaffold(
        body: IndexedStack(
          index: ctrl.currentIndex.value,
          children: const [
            HomeTab(),
            ScannerScreen(),
            DietScreen(),
            TipsScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: ctrl.currentIndex.value,
          onTap: (index) {
            ctrl.changeTab(index);
            ctrl.update(); // Trigger rebuild
          },
        ),
      ),
    );
  }
}
