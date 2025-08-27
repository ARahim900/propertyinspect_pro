import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://epirocvvdzxiypdvdlwf.supabase.co');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVwaXJvY3Z2ZHp4aXlwZHZkbHdmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQzNjI1MzgsImV4cCI6MjA2OTkzODUzOH0.Y0VlkV8XqO55En1zTLZ7iinorMHt72O37oFDbhywdTE');

  bool _isInitialized = false;
  bool _connectionTested = false;

  // Initialize Supabase - call this in main()
  static Future<void> initialize() async {
    try {
      if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
        throw Exception(
            'SUPABASE_URL and SUPABASE_ANON_KEY must be defined using --dart-define.');
      }

      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: kDebugMode,
      );

      instance._isInitialized = true;
      
      // Test connection
      await instance.testConnection();
      
      debugPrint('✅ Supabase initialized successfully');
      debugPrint('🔗 Connected to: $supabaseUrl');
      
    } catch (e) {
      debugPrint('❌ Supabase initialization failed: $e');
      rethrow;
    }
  }

  // Get Supabase client
  SupabaseClient get client {
    if (!_isInitialized) {
      throw Exception('Supabase not initialized. Call SupabaseService.initialize() first.');
    }
    return Supabase.instance.client;
  }

  // Test database connection
  Future<bool> testConnection() async {
    try {
      // Simple query to test connection
      final response = await client
          .from('profiles')
          .select('count')
          .limit(1);
      
      _connectionTested = true;
      debugPrint('✅ Database connection test successful');
      return true;
    } catch (e) {
      debugPrint('❌ Database connection test failed: $e');
      _connectionTested = false;
      return false;
    }
  }

  // Check if connected and authenticated
  bool get isConnected => _isInitialized && _connectionTested;
  
  // Get current user
  User? get currentUser => client.auth.currentUser;
  
  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Get connection status
  Map<String, dynamic> get connectionStatus => {
    'initialized': _isInitialized,
    'connectionTested': _connectionTested,
    'authenticated': isAuthenticated,
    'userId': currentUser?.id,
    'userEmail': currentUser?.email,
    'url': supabaseUrl,
  };

  // Create database tables if they don't exist
  Future<void> ensureDatabaseSchema() async {
    try {
      debugPrint('🔧 Ensuring database schema...');
      
      // Check if tables exist by trying to query them
      await _ensureProfilesTable();
      await _ensureInspectionsTable();
      await _ensureInspectionAreasTable();
      await _ensureInspectionItemsTable();
      await _ensureInvoicesTable();
      await _ensureSchedulesTable();
      
      debugPrint('✅ Database schema verified');
    } catch (e) {
      debugPrint('⚠️ Database schema check failed: $e');
      // Don't throw error as tables might not exist yet
    }
  }

  Future<void> _ensureProfilesTable() async {
    try {
      await client.from('profiles').select('id').limit(1);
      debugPrint('✅ profiles table exists');
    } catch (e) {
      debugPrint('⚠️ profiles table might not exist: $e');
    }
  }

  Future<void> _ensureInspectionsTable() async {
    try {
      await client.from('inspections').select('id').limit(1);
      debugPrint('✅ inspections table exists');
    } catch (e) {
      debugPrint('⚠️ inspections table might not exist: $e');
    }
  }

  Future<void> _ensureInspectionAreasTable() async {
    try {
      await client.from('inspection_areas').select('id').limit(1);
      debugPrint('✅ inspection_areas table exists');
    } catch (e) {
      debugPrint('⚠️ inspection_areas table might not exist: $e');
    }
  }

  Future<void> _ensureInspectionItemsTable() async {
    try {
      await client.from('inspection_items').select('id').limit(1);
      debugPrint('✅ inspection_items table exists');
    } catch (e) {
      debugPrint('⚠️ inspection_items table might not exist: $e');
    }
  }

  Future<void> _ensureInvoicesTable() async {
    try {
      await client.from('invoices').select('id').limit(1);
      debugPrint('✅ invoices table exists');
    } catch (e) {
      debugPrint('⚠️ invoices table might not exist: $e');
    }
  }

  Future<void> _ensureSchedulesTable() async {
    try {
      await client.from('schedules').select('id').limit(1);
      debugPrint('✅ schedules table exists');
    } catch (e) {
      debugPrint('⚠️ schedules table might not exist: $e');
    }
  }

  // Handle Supabase errors
  String handleSupabaseError(dynamic error) {
    if (error is PostgrestException) {
      switch (error.code) {
        case '23505':
          return 'This record already exists.';
        case '23503':
          return 'Cannot delete this record as it is referenced by other data.';
        case '42P01':
          return 'Database table not found. Please contact support.';
        case '42703':
          return 'Database column not found. Please contact support.';
        default:
          return 'Database error: ${error.message}';
      }
    } else if (error is AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return 'Invalid email or password.';
        case 'Email not confirmed':
          return 'Please check your email and confirm your account.';
        case 'User not found':
          return 'No account found with this email address.';
        default:
          return 'Authentication error: ${error.message}';
      }
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // Get database statistics
  Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      final stats = <String, dynamic>{};
      
      // Count records in each table
      final profilesCount = await client.from('profiles').select('id', const FetchOptions(count: CountOption.exact));
      stats['profiles_count'] = profilesCount.count;
      
      final inspectionsCount = await client.from('inspections').select('id', const FetchOptions(count: CountOption.exact));
      stats['inspections_count'] = inspectionsCount.count;
      
      final areasCount = await client.from('inspection_areas').select('id', const FetchOptions(count: CountOption.exact));
      stats['areas_count'] = areasCount.count;
      
      final itemsCount = await client.from('inspection_items').select('id', const FetchOptions(count: CountOption.exact));
      stats['items_count'] = itemsCount.count;
      
      return stats;
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
