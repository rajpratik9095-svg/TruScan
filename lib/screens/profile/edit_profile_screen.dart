import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../controllers/auth_controller.dart';
import '../../config/theme.dart';
import '../../services/supabase_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  bool _isLoading = false;
  bool _obscureNewPassword = true;
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value;
    
    _nameController.text = user?.name ?? '';
    _emailController.text = user?.email ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() => _selectedImage = image);
        await _uploadImage(image);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        backgroundColor: AppTheme.error,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _uploadImage(XFile image) async {
    setState(() => _isLoading = true);
    
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) throw Exception('Not logged in');

      final bytes = await image.readAsBytes();
      final fileName = 'avatar_$userId.jpg';
      final filePath = 'avatars/$fileName';

      // Upload to Supabase Storage
      await SupabaseService.client.storage
          .from('avatars')
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      // Get public URL
      final imageUrl = SupabaseService.client.storage
          .from('avatars')
          .getPublicUrl(filePath);

      // Update user profile
      await SupabaseService.client.from('users').update({
        'avatar_url': imageUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      // Refresh profile
      final authController = Get.find<AuthController>();
      await authController.refreshProfile();

      Get.snackbar(
        'Success',
        'Profile photo updated!',
        backgroundColor: AppTheme.success,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to upload photo. Make sure "avatars" bucket exists in Supabase Storage.',
        backgroundColor: AppTheme.error,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      print('Upload error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) throw Exception('Not logged in');

      await SupabaseService.client.from('users').update({
        'name': _nameController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      final authController = Get.find<AuthController>();
      await authController.refreshProfile();

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        backgroundColor: AppTheme.success,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile',
        backgroundColor: AppTheme.error,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text.isEmpty) {
      Get.snackbar('Error', 'Enter new password', backgroundColor: AppTheme.error, colorText: Colors.white);
      return;
    }
    if (_newPasswordController.text.length < 6) {
      Get.snackbar('Error', 'Password must be at least 6 characters', backgroundColor: AppTheme.error, colorText: Colors.white);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await SupabaseService.client.auth.updateUser(
        UserAttributes(password: _newPasswordController.text),
      );

      _newPasswordController.clear();

      Get.snackbar(
        'Success',
        'Password changed successfully',
        backgroundColor: AppTheme.success,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to change password',
        backgroundColor: AppTheme.error,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Photo
              Center(
                child: Stack(
                  children: [
                    Obx(() {
                      final user = authController.currentUser.value;
                      return Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.primaryGradient,
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: _selectedImage != null
                              ? (kIsWeb 
                                  ? NetworkImage(_selectedImage!.path)
                                  : FileImage(File(_selectedImage!.path)) as ImageProvider)
                              : (user?.avatarUrl != null
                                  ? NetworkImage(user!.avatarUrl!)
                                  : null),
                          child: (_selectedImage == null && user?.avatarUrl == null)
                              ? Text(
                                  (user?.name ?? 'U')[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 50,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                )
                              : null,
                        ),
                      );
                    }),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _isLoading ? null : _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGradientStart,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.camera_alt,
                                  size: 22,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: _isLoading ? null : _pickImage,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Change Photo'),
                ),
              ),
              const SizedBox(height: 24),

              // Personal Info Section
              _buildSectionTitle('Personal Information'),
              const SizedBox(height: 12),
              
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) => v?.isEmpty == true ? 'Name required' : null,
              ),
              const SizedBox(height: 16),
              
              // Email Field (Read-only)
              TextFormField(
                controller: _emailController,
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Email cannot be changed',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              const SizedBox(height: 24),

              // Update Profile Button
              ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGradientStart,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
              const SizedBox(height: 32),

              // Change Password Section
              _buildSectionTitle('Change Password'),
              const SizedBox(height: 12),
              
              // New Password
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureNewPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Change Password Button
              OutlinedButton(
                onPressed: _isLoading ? null : _changePassword,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppTheme.primaryGradientStart),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Change Password',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
