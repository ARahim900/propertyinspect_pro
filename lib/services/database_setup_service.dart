import 'package:flutter/foundation.dart';
import './supabase_service.dart';

/// Service for setting up and managing database schema
class DatabaseSetupService {
  static DatabaseSetupService? _instance;
  static DatabaseSetupService get instance => _instance ??= DatabaseSetupService._();
  
  DatabaseSetupService._();
  
  final _supabase = SupabaseService.instance;
  
  /// SQL scripts for creating tables
  static const String createProfilesTable = '''
    CREATE TABLE IF NOT EXISTS profiles (
      id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
      user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
      email TEXT NOT NULL,
      role TEXT DEFAULT 'staff' CHECK (role IN ('admin', 'manager', 'staff')),
      first_name TEXT,
      last_name TEXT,
      phone TEXT,
      company TEXT,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      UNIQUE(user_id)
    );
  ''';
  
  static const String createInspectionsTable = '''
    CREATE TABLE IF NOT EXISTS inspections (
      id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
      user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
      client_name TEXT,
      property_type TEXT NOT NULL,
      inspector_name TEXT NOT NULL,
      inspection_date DATE NOT NULL,
      property_location TEXT NOT NULL,
      status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
      notes TEXT,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );
  ''';
  
  static const String createInspectionAreasTable = '''
    CREATE TABLE IF NOT EXISTS inspection_areas (
      id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
      inspection_id UUID REFERENCES inspections(id) ON DELETE CASCADE,
      name TEXT NOT NULL,
      description TEXT,
      order_index INTEGER DEFAULT 0,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );
  ''';
  
  static const String createInspectionItemsTable = '''
    CREATE TABLE IF NOT EXISTS inspection_items (
      id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
      area_id UUID REFERENCES inspection_areas(id) ON DELETE CASCADE,
      point TEXT NOT NULL,
      category TEXT NOT NULL,
      status TEXT CHECK (status IN ('Pass', 'Fail', 'N/A', 'Needs Review')),
      comments TEXT,
      location TEXT,
      photos TEXT[] DEFAULT '{}',
      metadata JSONB DEFAULT '{}',
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );
  ''';
  
  static const String createInvoicesTable = '''
    CREATE TABLE IF NOT EXISTS invoices (
      id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
      inspection_id UUID REFERENCES inspections(id) ON DELETE CASCADE,
      user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
      invoice_number TEXT UNIQUE NOT NULL,
      client_name TEXT NOT NULL,
      client_email TEXT,
      client_address TEXT,
      amount DECIMAL(10,2) NOT NULL,
      tax_amount DECIMAL(10,2) DEFAULT 0,
      total_amount DECIMAL(10,2) NOT NULL,
      status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'sent', 'paid', 'overdue', 'cancelled')),
      due_date DATE,
      paid_date DATE,
      notes TEXT,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );
  ''';
  
  static const String createSchedulesTable = '''
    CREATE TABLE IF NOT EXISTS schedules (
      id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
      user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
      title TEXT NOT NULL,
      description TEXT,
      property_address TEXT NOT NULL,
      client_name TEXT,
      client_phone TEXT,
      client_email TEXT,
      scheduled_date TIMESTAMP WITH TIME ZONE NOT NULL,
      duration_minutes INTEGER DEFAULT 120,
      status TEXT DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'confirmed', 'in_progress', 'completed', 'cancelled')),
      property_type TEXT,
      special_instructions TEXT,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );
  ''';
  
  /// Create all required indexes
  static const List<String> createIndexes = [
    'CREATE INDEX IF NOT EXISTS idx_profiles_user_id ON profiles(user_id);',
    'CREATE INDEX IF NOT EXISTS idx_inspections_user_id ON inspections(user_id);',
    'CREATE INDEX IF NOT EXISTS idx_inspections_date ON inspections(inspection_date);',
    'CREATE INDEX IF NOT EXISTS idx_inspection_areas_inspection_id ON inspection_areas(inspection_id);',
    'CREATE INDEX IF NOT EXISTS idx_inspection_items_area_id ON inspection_items(area_id);',
    'CREATE INDEX IF NOT EXISTS idx_invoices_user_id ON invoices(user_id);',
    'CREATE INDEX IF NOT EXISTS idx_invoices_inspection_id ON invoices(inspection_id);',
    'CREATE INDEX IF NOT EXISTS idx_schedules_user_id ON schedules(user_id);',
    'CREATE INDEX IF NOT EXISTS idx_schedules_date ON schedules(scheduled_date);',
  ];
  
  /// Row Level Security (RLS) policies
  static const List<String> createRLSPolicies = [
    'ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;',
    'ALTER TABLE inspections ENABLE ROW LEVEL SECURITY;',
    'ALTER TABLE inspection_areas ENABLE ROW LEVEL SECURITY;',
    'ALTER TABLE inspection_items ENABLE ROW LEVEL SECURITY;',
    'ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;',
    'ALTER TABLE schedules ENABLE ROW LEVEL SECURITY;',
    
    // Profiles policies
    '''CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = user_id);''',
    '''CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = user_id);''',
    '''CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = user_id);''',
    
    // Inspections policies
    '''CREATE POLICY "Users can view own inspections" ON inspections FOR SELECT USING (auth.uid() = user_id);''',
    '''CREATE POLICY "Users can insert own inspections" ON inspections FOR INSERT WITH CHECK (auth.uid() = user_id);''',
    '''CREATE POLICY "Users can update own inspections" ON inspections FOR UPDATE USING (auth.uid() = user_id);''',
    '''CREATE POLICY "Users can delete own inspections" ON inspections FOR DELETE USING (auth.uid() = user_id);''',
    
    // Inspection areas policies
    '''CREATE POLICY "Users can view inspection areas" ON inspection_areas FOR SELECT USING (
      EXISTS (SELECT 1 FROM inspections WHERE inspections.id = inspection_areas.inspection_id AND inspections.user_id = auth.uid())
    );''',
    '''CREATE POLICY "Users can insert inspection areas" ON inspection_areas FOR INSERT WITH CHECK (
      EXISTS (SELECT 1 FROM inspections WHERE inspections.id = inspection_areas.inspection_id AND inspections.user_id = auth.uid())
    );''',
    '''CREATE POLICY "Users can update inspection areas" ON inspection_areas FOR UPDATE USING (
      EXISTS (SELECT 1 FROM inspections WHERE inspections.id = inspection_areas.inspection_id AND inspections.user_id = auth.uid())
    );''',
    '''CREATE POLICY "Users can delete inspection areas" ON inspection_areas FOR DELETE USING (
      EXISTS (SELECT 1 FROM inspections WHERE inspections.id = inspection_areas.inspection_id AND inspections.user_id = auth.uid())
    );''',
    
    // Inspection items policies
    '''CREATE POLICY "Users can view inspection items" ON inspection_items FOR SELECT USING (
      EXISTS (
        SELECT 1 FROM inspection_areas 
        JOIN inspections ON inspections.id = inspection_areas.inspection_id 
        WHERE inspection_areas.id = inspection_items.area_id AND inspections.user_id = auth.uid()
      )
    );''',
    '''CREATE POLICY "Users can insert inspection items" ON inspection_items FOR INSERT WITH CHECK (
      EXISTS (
        SELECT 1 FROM inspection_areas 
        JOIN inspections ON inspections.id = inspection_areas.inspection_id 
        WHERE inspection_areas.id = inspection_items.area_id AND inspections.user_id = auth.uid()
      )
    );''',
    '''CREATE POLICY "Users can update inspection items" ON inspection_items FOR UPDATE USING (
      EXISTS (
        SELECT 1 FROM inspection_areas 
        JOIN inspections ON inspections.id = inspection_areas.inspection_id 
        WHERE inspection_areas.id = inspection_items.area_id AND inspections.user_id = auth.uid()
      )
    );''',
    '''CREATE POLICY "Users can delete inspection items" ON inspection_items FOR DELETE USING (
      EXISTS (
        SELECT 1 FROM inspection_areas 
        JOIN inspections ON inspections.id = inspection_areas.inspection_id 
        WHERE inspection_areas.id = inspection_items.area_id AND inspections.user_id = auth.uid()
      )
    );''',
    
    // Invoices policies
    '''CREATE POLICY "Users can view own invoices" ON invoices FOR SELECT USING (auth.uid() = user_id);''',
    '''CREATE POLICY "Users can insert own invoices" ON invoices FOR INSERT WITH CHECK (auth.uid() = user_id);''',
    '''CREATE POLICY "Users can update own invoices" ON invoices FOR UPDATE USING (auth.uid() = user_id);''',
    '''CREATE POLICY "Users can delete own invoices" ON invoices FOR DELETE USING (auth.uid() = user_id);''',
    
    // Schedules policies
    '''CREATE POLICY "Users can view own schedules" ON schedules FOR SELECT USING (auth.uid() = user_id);''',
    '''CREATE POLICY "Users can insert own schedules" ON schedules FOR INSERT WITH CHECK (auth.uid() = user_id);''',
    '''CREATE POLICY "Users can update own schedules" ON schedules FOR UPDATE USING (auth.uid() = user_id);''',
    '''CREATE POLICY "Users can delete own schedules" ON schedules FOR DELETE USING (auth.uid() = user_id);''',
  ];
  
  /// Setup complete database schema
  Future<void> setupDatabase() async {
    try {
      debugPrint('🔧 Setting up database schema...');
      
      // Note: In a real app, you would run these SQL commands through Supabase Dashboard
      // or using a migration system. For now, we'll just verify the tables exist.
      
      await _verifyTables();
      
      debugPrint('✅ Database schema setup completed');
    } catch (e) {
      debugPrint('❌ Database schema setup failed: $e');
      rethrow;
    }
  }
  
  /// Verify all required tables exist
  Future<void> _verifyTables() async {
    final requiredTables = [
      'profiles',
      'inspections', 
      'inspection_areas',
      'inspection_items',
      'invoices',
      'schedules',
    ];
    
    for (final table in requiredTables) {
      try {
        await _supabase.client.from(table).select('*').limit(1);
        debugPrint('✅ Table $table exists');
      } catch (e) {
        debugPrint('❌ Table $table missing or inaccessible: $e');
        throw Exception('Required table $table is missing. Please run database migrations.');
      }
    }
  }
  
  /// Create sample data for testing
  Future<void> createSampleData() async {
    try {
      if (!kDebugMode) return; // Only in debug mode
      
      debugPrint('🔧 Creating sample data...');
      
      // Check if sample data already exists
      final existingInspections = await _supabase.client
          .from('inspections')
          .select('id')
          .limit(1);
      
      if (existingInspections.isNotEmpty) {
        debugPrint('ℹ️ Sample data already exists');
        return;
      }
      
      // Create sample inspection
      final inspection = await _supabase.client
          .from('inspections')
          .insert({
            'client_name': 'Sample Client',
            'property_type': 'Residential',
            'inspector_name': 'John Inspector',
            'inspection_date': DateTime.now().toIso8601String().split('T')[0],
            'property_location': '123 Sample Street, Sample City, SC 12345',
            'status': 'pending',
            'notes': 'Sample inspection for testing purposes',
          })
          .select()
          .single();
      
      // Create sample areas
      final areas = [
        {'name': 'Kitchen', 'description': 'Kitchen area inspection'},
        {'name': 'Living Room', 'description': 'Living room area inspection'},
        {'name': 'Bathroom', 'description': 'Bathroom area inspection'},
      ];
      
      for (final area in areas) {
        await _supabase.client.from('inspection_areas').insert({
          'inspection_id': inspection['id'],
          'name': area['name'],
          'description': area['description'],
        });
      }
      
      debugPrint('✅ Sample data created successfully');
    } catch (e) {
      debugPrint('⚠️ Failed to create sample data: $e');
      // Don't throw error as this is optional
    }
  }
  
  /// Get database schema information
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    try {
      final info = <String, dynamic>{};
      
      // Get table counts
      final tables = ['profiles', 'inspections', 'inspection_areas', 'inspection_items', 'invoices', 'schedules'];
      
      for (final table in tables) {
        try {
          final result = await _supabase.client
              .from(table)
              .select('*', const FetchOptions(count: CountOption.exact))
              .limit(0);
          info['${table}_count'] = result.count ?? 0;
        } catch (e) {
          info['${table}_count'] = 'Error: ${e.toString()}';
        }
      }
      
      info['connection_status'] = _supabase.connectionStatus;
      info['timestamp'] = DateTime.now().toIso8601String();
      
      return info;
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}