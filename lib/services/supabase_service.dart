import 'package:supabase_flutter/supabase_flutter.dart';

/// Central Supabase Service
/// Handles initialization and provides access to Supabase client
class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;
  
  static bool _initialized = false;
  
  /// Initialize Supabase
  /// Call this once in main() before runApp()
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    if (_initialized) return;
    
    try {
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );
      
      _initialized = true;
      print('✅ Supabase initialized successfully');
    } catch (e) {
      print('❌ Error initializing Supabase: $e');
      rethrow;
    }
  }
  
  /// Get current user session
  static Session? get currentSession => client.auth.currentSession;
  
  /// Get current user
  static User? get currentUser => client.auth.currentUser;
  
  /// Check if user is authenticated
  static bool get isAuthenticated => currentSession != null;
  
  /// Sign out
  static Future<void> signOut() async {
    await client.auth.signOut();
  }
}
