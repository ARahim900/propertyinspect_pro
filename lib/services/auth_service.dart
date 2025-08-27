import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import './supabase_service.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();

  AuthService._();

  final SupabaseClient _client = SupabaseService.instance.client;

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Get auth state stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Create user profile
        await _createUserProfile(response.user!);
      }

      return response;
    } catch (error) {
      throw Exception('Sign up failed: $error');
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (error) {
      throw Exception('Sign in failed: $error');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (error) {
      throw Exception('Sign out failed: $error');
    }
  }

  // Get current user profile
  Future<UserProfile?> getCurrentUserProfile() async {
    if (!isAuthenticated) return null;

    try {
      final response =
          await _client
              .from('profiles')
              .select()
              .eq('user_id', currentUser!.id)
              .single();

      return UserProfile.fromJson(response);
    } catch (error) {
      throw Exception('Failed to get user profile: $error');
    }
  }

  // Update user profile
  Future<UserProfile> updateUserProfile(Map<String, dynamic> updates) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    try {
      final response =
          await _client
              .from('profiles')
              .update({
                ...updates,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('user_id', currentUser!.id)
              .select()
              .single();

      return UserProfile.fromJson(response);
    } catch (error) {
      throw Exception('Failed to update user profile: $error');
    }
  }

  // Create user profile (called during sign up)
  Future<void> _createUserProfile(User user) async {
    try {
      await _client.from('profiles').insert({
        'user_id': user.id,
        'email': user.email ?? '',
        'role': 'staff', // Default role
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (error) {
      throw Exception('Failed to create user profile: $error');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (error) {
      throw Exception('Password reset failed: $error');
    }
  }

  // Check user role
  Future<String> getUserRole() async {
    if (!isAuthenticated) return 'staff';

    try {
      final profile = await getCurrentUserProfile();
      return profile?.role ?? 'staff';
    } catch (error) {
      return 'staff';
    }
  }

  // Check if user is admin
  Future<bool> isAdmin() async {
    final role = await getUserRole();
    return role == 'admin';
  }

  // Sign in with demo credentials (for development mode)
  Future<AuthResponse?> signInWithDemoCredentials({
    required String email,
    required String password,
  }) async {
    // Demo credentials mapping
    final Map<String, Map<String, String>> demoCredentials = {
      'inspector@propertyinspect.com': {
        'password': 'inspector123',
        'role': 'staff',
        'name': 'John Inspector',
      },
      'admin@propertyinspect.com': {
        'password': 'admin123',
        'role': 'admin',
        'name': 'Sarah Admin',
      },
      'manager@propertyinspect.com': {
        'password': 'manager123',
        'role': 'staff',
        'name': 'Mike Manager',
      },
    };

    try {
      // Check if it's a demo account first
      if (demoCredentials.containsKey(email.toLowerCase())) {
        final demoData = demoCredentials[email.toLowerCase()]!;
        if (demoData['password'] == password) {
          // Try to sign in with Supabase (in case the demo account exists in the database)
          try {
            return await signIn(email: email, password: password);
          } catch (e) {
            // If demo account doesn't exist in Supabase, create it
            try {
              final response = await signUp(email: email, password: password);
              // Update profile with demo data
              if (response.user != null) {
                await _client
                    .from('profiles')
                    .update({
                      'role': demoData['role'] == 'admin' ? 'admin' : 'staff',
                      'updated_at': DateTime.now().toIso8601String(),
                    })
                    .eq('user_id', response.user!.id);
              }
              return response;
            } catch (signupError) {
              // If signup also fails, return null
              return null;
            }
          }
        }
      }

      // For non-demo accounts, try regular sign in
      return await signIn(email: email, password: password);
    } catch (error) {
      throw Exception('Authentication failed: $error');
    }
  }
}
