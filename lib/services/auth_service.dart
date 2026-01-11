import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart' as app_models;
import 'supabase_service.dart';

/// Authentication Service using Supabase Auth
class AuthService {
  final _client = SupabaseService.client;
  
  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  
  /// Sign up with email and password (No OTP - Direct registration)
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
        emailRedirectTo: null,
      );
      
      // Create user profile immediately after signup
      if (response.user != null) {
        try {
          await _client.from('users').insert({
            'id': response.user!.id,
            'email': email,
            'name': name,
          });
          
          await _client.from('user_preferences').insert({
            'user_id': response.user!.id,
          });
        } catch (e) {
          print('Error creating user profile: $e');
          // Continue even if profile creation fails - can be retried later
        }
      }
      
      return response;
    } catch (e) {
      print('Error signing up: $e');
      rethrow;
    }
  }
  
  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }
  
  /// Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }
  
  /// Get current user profile from database
  Future<app_models.User?> getCurrentUserProfile() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return null;
      
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      
      return app_models.User(
        id: response['id'],
        name: response['name'],
        email: response['email'],
        avatarUrl: response['avatar_url'],
        createdAt: DateTime.parse(response['created_at']),
      );
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }
  
  /// Update user profile
  Future<void> updateProfile({
    String? name,
    String? avatarUrl,
  }) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) throw Exception('No user logged in');
      
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      
      if (updates.isNotEmpty) {
        updates['updated_at'] = DateTime.now().toIso8601String();
        await _client.from('users').update(updates).eq('id', userId);
      }
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }
  
  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      print('Error resetting password: $e');
      rethrow;
    }
  }
}
