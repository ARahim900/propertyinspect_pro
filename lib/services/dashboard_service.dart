import './supabase_service.dart';

class DashboardService {
  final SupabaseService _supabase = SupabaseService.instance;

  // Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final userId = _supabase.currentUserId!;

      // Get today's inspections count
      final todayStart = DateTime.now().toIso8601String().split('T')[0];

      final todayInspections = await _supabase.client
          .from('inspections')
          .select('id')
          .eq('user_id', userId)
          .eq('inspection_date', todayStart);

      // Get this week's completed inspections
      final weekStart = DateTime.now()
          .subtract(Duration(days: 7))
          .toIso8601String()
          .split('T')[0];

      final weeklyInspections = await _supabase.client
          .from('inspections')
          .select('id')
          .eq('user_id', userId)
          .gte('inspection_date', weekStart);

      // Get pending invoices
      final pendingInvoices = await _supabase.client
          .from('invoices')
          .select('total_amount')
          .eq('user_id', userId)
          .eq('status', 'draft');

      final pendingTotal = pendingInvoices.fold<double>(0.0,
          (sum, invoice) => sum + (invoice['total_amount'] as num).toDouble());

      // Get monthly revenue (completed invoices)
      final monthStart =
          DateTime.now().toIso8601String().substring(0, 8) + '01';

      final monthlyInvoices = await _supabase.client
          .from('invoices')
          .select('total_amount')
          .eq('user_id', userId)
          .eq('status', 'paid')
          .gte('issue_date', monthStart);

      final monthlyRevenue = monthlyInvoices.fold<double>(0.0,
          (sum, invoice) => sum + (invoice['total_amount'] as num).toDouble());

      return {
        'todayInspections': todayInspections.length,
        'weeklyCompleted': weeklyInspections.length,
        'pendingInvoicesCount': pendingInvoices.length,
        'pendingInvoicesAmount': pendingTotal,
        'monthlyRevenue': monthlyRevenue,
        'monthlyInvoicesCount': monthlyInvoices.length,
      };
    } catch (error) {
      throw Exception('Failed to load dashboard stats: $error');
    }
  }

  // Get recent inspections
  Future<List<Map<String, dynamic>>> getRecentInspections(
      {int limit = 5}) async {
    try {
      final userId = _supabase.currentUserId!;

      final inspections = await _supabase.client
          .from('inspections')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return inspections;
    } catch (error) {
      throw Exception('Failed to load recent inspections: $error');
    }
  }

  // Get recent invoices
  Future<List<Map<String, dynamic>>> getRecentInvoices({int limit = 5}) async {
    try {
      final userId = _supabase.currentUserId!;

      final invoices = await _supabase.client
          .from('invoices')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return invoices;
    } catch (error) {
      throw Exception('Failed to load recent invoices: $error');
    }
  }

  // Get upcoming schedules
  Future<List<Map<String, dynamic>>> getUpcomingSchedules(
      {int limit = 5}) async {
    try {
      final userId = _supabase.currentUserId!;
      final today = DateTime.now().toIso8601String().split('T')[0];

      final schedules = await _supabase.client
          .from('schedules')
          .select('*')
          .eq('user_id', userId)
          .gte('date', today)
          .order('date', ascending: true)
          .order('time', ascending: true)
          .limit(limit);

      return schedules;
    } catch (error) {
      throw Exception('Failed to load upcoming schedules: $error');
    }
  }

  // Get activity feed
  Future<List<Map<String, dynamic>>> getActivityFeed({int limit = 10}) async {
    try {
      final userId = _supabase.currentUserId!;

      // Combine recent inspections, invoices, and schedules into activity feed
      final recentInspections = await _supabase.client
          .from('inspections')
          .select('id, client_name, property_location, created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(5);

      final recentInvoices = await _supabase.client
          .from('invoices')
          .select('id, client_name, total_amount, status, created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(5);

      // Create activity feed items
      List<Map<String, dynamic>> activities = [];

      // Add inspections
      for (final inspection in recentInspections) {
        activities.add({
          'id': inspection['id'],
          'type': 'inspection',
          'title': 'Inspection for ${inspection['client_name']}',
          'subtitle': inspection['property_location'],
          'timestamp': inspection['created_at'],
          'data': inspection,
        });
      }

      // Add invoices
      for (final invoice in recentInvoices) {
        activities.add({
          'id': invoice['id'],
          'type': 'invoice',
          'title': 'Invoice for ${invoice['client_name']}',
          'subtitle':
              'OMR ${(invoice['total_amount'] as num).toDouble().toStringAsFixed(2)} - ${invoice['status']}',
          'timestamp': invoice['created_at'],
          'data': invoice,
        });
      }

      // Sort by timestamp
      activities.sort((a, b) => DateTime.parse(b['timestamp'])
          .compareTo(DateTime.parse(a['timestamp'])));

      return activities.take(limit).toList();
    } catch (error) {
      throw Exception('Failed to load activity feed: $error');
    }
  }

  // Get charts data for analytics
  Future<Map<String, dynamic>> getChartsData() async {
    try {
      final userId = _supabase.currentUserId!;
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      // Get daily inspection counts for current month
      final monthlyInspections = await _supabase.client
          .from('inspections')
          .select('inspection_date')
          .eq('user_id', userId)
          .gte('inspection_date', startOfMonth.toIso8601String().split('T')[0]);

      // Group by day
      Map<String, int> dailyCounts = {};
      for (final inspection in monthlyInspections) {
        final date = inspection['inspection_date'] as String;
        dailyCounts[date] = (dailyCounts[date] ?? 0) + 1;
      }

      // Get monthly revenue data
      final monthlyRevenue = await _supabase.client
          .from('invoices')
          .select('issue_date, total_amount, status')
          .eq('user_id', userId)
          .eq('status', 'paid')
          .gte('issue_date', startOfMonth.toIso8601String().split('T')[0]);

      Map<String, double> dailyRevenue = {};
      for (final invoice in monthlyRevenue) {
        final date = invoice['issue_date'] as String;
        final amount = (invoice['total_amount'] as num).toDouble();
        dailyRevenue[date] = (dailyRevenue[date] ?? 0.0) + amount;
      }

      return {
        'dailyInspections': dailyCounts,
        'dailyRevenue': dailyRevenue,
        'monthStart': startOfMonth.toIso8601String().split('T')[0],
      };
    } catch (error) {
      throw Exception('Failed to load charts data: $error');
    }
  }
}
