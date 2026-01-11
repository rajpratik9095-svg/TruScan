import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../services/supabase_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    setState(() => _isLoading = true);

    try {
      // Sign up with Supabase - No email verification required
      final response = await SupabaseService.client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      
      if (response.user != null) {
        // Create user profile in database
        try {
          await SupabaseService.client.from('users').insert({
            'id': response.user!.id,
            'email': email,
            'name': name,
          });
        } catch (e) {
          print('Profile creation: $e');
        }
        
        // Create default preferences
        try {
          await SupabaseService.client.from('user_preferences').insert({
            'user_id': response.user!.id,
          });
        } catch (e) {
          print('Preferences creation: $e');
        }
        
        setState(() => _isLoading = false);
        
        Get.snackbar(
          'Success!',
          'Account created successfully!',
          backgroundColor: AppTheme.success,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        
        // Navigate to home
        Get.offAllNamed('/home');
      } else {
        setState(() => _isLoading = false);
        Get.snackbar(
          'Error',
          'Registration failed. Try again.',
          backgroundColor: AppTheme.error,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      
      String errorMsg = 'Registration failed';
      if (e.toString().contains('already registered')) {
        // Show dialog for already registered
        _showAlreadyRegisteredDialog();
        return;
      }
      if (e.toString().contains('Password')) {
        errorMsg = 'Password must be at least 6 characters';
      }
      
      Get.snackbar('Error', errorMsg, backgroundColor: AppTheme.error, colorText: Colors.white);
    }
  }

  void _showAlreadyRegisteredDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.orange, size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                'Already Registered!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'This email is already registered.\nPlease login instead.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.off(() => const LoginScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGradientStart,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Go to Login', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return 'Name is required';
    if (value.length < 2) return 'Name too short';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!GetUtils.isEmail(value)) return 'Enter valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Minimum 6 characters';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) return 'Passwords don\'t match';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon
                Center(
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: const BoxDecoration(
                      gradient: AppTheme.secondaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_add, size: 40, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Title
                const Text(
                  'Join TrueScan',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your account to get started',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Name Field
                CustomTextField(
                  label: 'Full Name',
                  hint: 'Enter your name',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline,
                  validator: _validateName,
                ),
                const SizedBox(height: 16),
                
                // Email Field
                CustomTextField(
                  label: 'Email',
                  hint: 'your@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),
                
                // Password Field
                CustomTextField(
                  label: 'Password',
                  hint: 'Create password (min 6 chars)',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outline,
                  validator: _validatePassword,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Confirm Password Field
                CustomTextField(
                  label: 'Confirm Password',
                  hint: 'Confirm password',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: Icons.lock_outline,
                  validator: _validateConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Register Button
                CustomButton(
                  text: 'Create Account',
                  onPressed: _handleRegister,
                  isLoading: _isLoading,
                  icon: Icons.person_add,
                  gradient: AppTheme.secondaryGradient,
                ),
                const SizedBox(height: 24),
                
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? '),
                    TextButton(
                      onPressed: () => Get.off(() => const LoginScreen()),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGradientStart),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
