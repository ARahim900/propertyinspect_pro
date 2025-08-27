import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;
  late SupabaseClient _client;

  SupabaseService._();

  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  SupabaseClient get client => _client;

  Future<void> initialize() async {
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    );
    _client = Supabase.instance.client;
  }

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Get current user ID
  String? get currentUserId => currentUser?.id;

  // Authentication methods
  Future<AuthResponse> signUp(String email, String password) async {
    try {
      return await _client.auth.signUp(
        email: email,
        password: password,
      );
    } catch (error) {
      throw Exception('Sign-up failed: $error');
    }
  }

  Future<AuthResponse> signIn(String email, String password) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (error) {
      throw Exception('Sign-in failed: $error');
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (error) {
      throw Exception('Sign-out failed: $error');
    }
  }

  // Generic CRUD operations
  Future<List<dynamic>> select(
    String table, {
    String columns = '*',
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    try {
      dynamic query = _client.from(table).select(columns);

      if (filters != null) {
        filters.forEach((key, value) {
          query = query.eq(key, value);
        });
      }

      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }

      if (limit != null) {
        return await query.limit(limit);
      }

      return await query;
    } catch (error) {
      throw Exception('Select failed: $error');
    }
  }

  Future<List<dynamic>> insert(String table, Map<String, dynamic> data) async {
    try {
      return await _client.from(table).insert(data).select();
    } catch (error) {
      throw Exception('Insert failed: $error');
    }
  }

  Future<List<dynamic>> update(String table, Map<String, dynamic> data,
      String column, dynamic value) async {
    try {
      return await _client.from(table).update(data).eq(column, value).select();
    } catch (error) {
      throw Exception('Update failed: $error');
    }
  }

  Future<List<dynamic>> delete(
      String table, String column, dynamic value) async {
    try {
      return await _client.from(table).delete().eq(column, value).select();
    } catch (error) {
      throw Exception('Delete failed: $error');
    }
  }
}
