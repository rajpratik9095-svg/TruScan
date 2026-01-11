import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../config/theme.dart';
import '../welcome/welcome_screen.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> with SingleTickerProviderStateMixin {
  bool cameraGranted = false;
  bool notificationGranted = false;
  bool activityGranted = false;
  
  bool isRequesting = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
    _checkPermissions();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    try {
      final camera = await Permission.camera.status;
      final notification = await Permission.notification.status;
      final activity = await Permission.activityRecognition.status;
      
      setState(() {
        cameraGranted = camera.isGranted;
        notificationGranted = notification.isGranted;
        activityGranted = activity.isGranted;
      });
    } catch (e) {
      debugPrint('Permission check error: $e');
    }
  }

  Future<void> _requestAllPermissions() async {
    setState(() => isRequesting = true);

    try {
      // Request camera permission
      if (!cameraGranted) {
        final camera = await Permission.camera.request();
        cameraGranted = camera.isGranted;
      }

      // Request notification permission
      if (!notificationGranted) {
        final notification = await Permission.notification.request();
        notificationGranted = notification.isGranted;
      }

      // Request activity recognition permission (for step counter)
      if (!activityGranted) {
        final activity = await Permission.activityRecognition.request();
        activityGranted = activity.isGranted;
      }
    } catch (e) {
      debugPrint('Permission request error: $e');
    }

    setState(() => isRequesting = false);

    // Mark permissions as requested
    final storage = GetStorage();
    storage.write('permissions_requested', true);
    
    // Navigate to welcome screen
    Get.off(() => const WelcomeScreen());
  }

  void _skipPermissions() {
    final storage = GetStorage();
    storage.write('permissions_requested', true);
    Get.off(() => const WelcomeScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFF8E54E9),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  children: [
                    // App Logo with Glow Effect
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                          BoxShadow(
                            color: const Color(0xFF667eea).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner,
                        size: 60,
                        color: Color(0xFF667eea),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Welcome Text
                    const Text(
                      'Welcome to TrueScan!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'We need a few permissions to give you\nthe best experience',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 16,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Permission Cards
                    _buildPermissionCard(
                      icon: Icons.camera_alt_rounded,
                      title: 'Camera Access',
                      description: 'Scan product barcodes & take photos for AI recognition',
                      granted: cameraGranted,
                      color: Colors.blue,
                      delay: 0,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildPermissionCard(
                      icon: Icons.notifications_active_rounded,
                      title: 'Notifications',
                      description: 'Get health tips, water reminders & meal alerts',
                      granted: notificationGranted,
                      color: Colors.orange,
                      delay: 1,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildPermissionCard(
                      icon: Icons.directions_run_rounded,
                      title: 'Activity Recognition',
                      description: 'Track your daily steps & calories burned',
                      granted: activityGranted,
                      color: Colors.green,
                      delay: 2,
                    ),
                    const SizedBox(height: 40),

                    // Grant Permissions Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: isRequesting ? null : _requestAllPermissions,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF667eea),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isRequesting
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Color(0xFF667eea),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle_outline, size: 22),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Grant Permissions',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Skip Button
                    TextButton(
                      onPressed: _skipPermissions,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Skip for now',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Privacy Note
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lock_outline, color: Colors.white.withOpacity(0.8), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your data stays private. We only use permissions for app features.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionCard({
    required IconData icon,
    required String title,
    required String description,
    required bool granted,
    required Color color,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (delay * 150)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: granted ? Colors.greenAccent : Colors.white.withOpacity(0.25),
            width: granted ? 2 : 1,
          ),
          boxShadow: granted
              ? [
                  BoxShadow(
                    color: Colors.greenAccent.withOpacity(0.3),
                    blurRadius: 15,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Icon with colored background
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            
            // Status indicator
            if (granted)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 18,
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.circle_outlined,
                  color: Colors.white.withOpacity(0.6),
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
