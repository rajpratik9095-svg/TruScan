import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/user_model.dart' as app_models;
import '../services/auth_service.dart';
import '../services/supabase_service.dart';
import '../screens/auth/login_screen.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  
  final Rx<app_models.User?> currentUser = Rx<app_models.User?>(null);
  final RxBool isLoggedIn = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isGuest = false.obs;

  // Check if user is a guest
  bool get isGuestUser => isGuest.value && !isLoggedIn.value;

  // Show login required dialog for guest users
  void showLoginRequired({String? feature}) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button at top right
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 20, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Lock icon
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.lock_outline, color: Colors.white, size: 35),
            ),
            const SizedBox(height: 20),
            // Title
            const Text(
              'Login Required',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Message
            Text(
              feature != null 
                ? 'Please login to access $feature'
                : 'Please login to continue',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            // Login button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  Future.delayed(const Duration(milliseconds: 100), () {
                    isGuest.value = false;
                    Get.offAll(() => const LoginScreen());
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Login Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 12),
            // Cancel button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Get.back(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text('Maybe Later', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: true, // Allow tap outside to close
    );
  }

  // Continue as guest
  void continueAsGuest() {
    isGuest.value = true;
    isLoggedIn.value = false;
    currentUser.value = null;
  }

  @override
  void onInit() {
    super.onInit();
    _initAuth();
    _listenToAuthChanges();
  }

  void _initAuth() async {
    isLoading.value = true;
    
    // Check if user is already logged in
    if (SupabaseService.isAuthenticated) {
      await _loadUserProfile();
      isLoggedIn.value = true;
    }
    
    isLoading.value = false;
  }

  void _listenToAuthChanges() {
    _authService.authStateChanges.listen((supabase.AuthState state) {
      if (state.event == supabase.AuthChangeEvent.signedIn) {
        _loadUserProfile();
        isLoggedIn.value = true;
      } else if (state.event == supabase.AuthChangeEvent.signedOut) {
        currentUser.value = null;
        isLoggedIn.value = false;
      }
    });
  }

  Future<void> _loadUserProfile() async {
    final profile = await _authService.getCurrentUserProfile();
    currentUser.value = profile;
  }

  Future<void> refreshProfile() async {
    await _loadUserProfile();
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      isLoading.value = true;
      
      final response = await _authService.signUp(
        email: email,
        password: password,
        name: name,
      );
      
      if (response.user != null) {
        await _loadUserProfile();
        isLoggedIn.value = true;
        return true;
      }
      
      return false;
    } catch (e) {
      print('Registration error: $e');
      Get.snackbar('Error', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      
      final response = await _authService.signIn(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        await _loadUserProfile();
        isLoggedIn.value = true;
        return true;
      }
      
      return false;
    } catch (e) {
      print('Login error: $e');
      Get.snackbar('Error', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.signOut();
      currentUser.value = null;
      isLoggedIn.value = false;
    } catch (e) {
      print('Logout error: $e');
      Get.snackbar('Error', 'Failed to logout');
    }
  }

  // Validation methods
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'field_required'.tr;
    }
    if (!GetUtils.isEmail(value)) {
      return 'invalid_email'.tr;
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'field_required'.tr;
    }
    if (value.length < 6) {
      return 'password_too_short'.tr;
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'field_required'.tr;
    }
    return null;
  }
}
