import 'package:supabase_flutter/supabase_flutter.dart';

import './auth_service.dart';
import './inspection_service.dart';
import './invoice_service.dart';
import './schedule_service.dart';
import './supabase_service.dart';

class DashboardService {
  static DashboardService? _instance;
  static DashboardService get instance => _instance ??= DashboardService._();

  DashboardService._();

  final SupabaseClient _client = SupabaseService.instance.client;

  // Get comprehensive dashboard data
  Future<Map<String, dynamic>> getDashboardData() async {
    final user = AuthService.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Get all data in parallel for better performance
      final results = await Future.wait([
        _getInspectionStats(),
        _getScheduleStats(),
        _getInvoiceStats(),
        _getRecentActivity(),
      ]);

      return {
        'inspections': results[0],
        'schedules': results[1],
        'invoices': results[2],
        'recentActivity': results[3],
        'user': await AuthService.instance.getCurrentUserProfile(),
      };
    } catch (error) {
      throw Exception('Failed to get dashboard data: $error');
    }
  }

  // Get inspection statistics
  Future<Map<String, dynamic>> _getInspectionStats() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return {};

    try {
      // Get inspection counts
      final totalResponse = await _client
          .from('inspections')
          .select()
          .eq('user_id', user.id)
          .count();

      // Get this month's inspections
      final now = DateTime.now();
      final thisMonth = DateTime(now.year, now.month, 1);
      final thisMonthResponse = await _client
          .from('inspections')
          .select()
          .eq('user_id', user.id)
          .gte('created_at', thisMonth.toIso8601String())
          .count();

      // Get recent inspections
      final recentInspections =
          await InspectionService.instance.getRecentInspections(limit: 5);

      return {
        'total': totalResponse.count ?? 0,
        'thisMonth': thisMonthResponse.count ?? 0,
        'recent': recentInspections
            .map((i) => {
                  'id': i.id,
                  'clientName': i.clientName ?? 'Unknown Client',
                  'propertyLocation': i.propertyLocation,
                  'inspectionDate': i.inspectionDate.toIso8601String(),
                })
            .toList(),
      };
    } catch (error) {
      return {
        'total': 0,
        'thisMonth': 0,
        'recent': [],
      };
    }
  }

  // Get schedule statistics
  Future<Map<String, dynamic>> _getScheduleStats() async {
    try {
      final todaySchedules = await ScheduleService.instance.getTodaySchedules();
      final upcomingSchedules =
          await ScheduleService.instance.getUpcomingSchedules(limit: 5);

      return {
        'today': todaySchedules.length,
        'upcoming': upcomingSchedules
            .map((s) => {
                  'id': s.id,
                  'title': s.title,
                  'clientName': s.clientName,
                  'date': s.date.toIso8601String(),
                  'time': s.time,
                  'priority': s.priority,
                })
            .toList(),
      };
    } catch (error) {
      return {
        'today': 0,
        'upcoming': [],
      };
    }
  }

  // Get invoice statistics
  Future<Map<String, dynamic>> _getInvoiceStats() async {
    try {
      final invoiceStats = await InvoiceService.instance.getInvoiceStats();
      return invoiceStats;
    } catch (error) {
      return {
        'totalInvoices': 0,
        'totalAmount': 0.0,
        'paidAmount': 0.0,
        'pendingAmount': 0.0,
        'draftCount': 0,
        'sentCount': 0,
        'paidCount': 0,
        'overdueCount': 0,
      };
    }
  }

  // Get recent activity
  Future<List<Map<String, dynamic>>> _getRecentActivity() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return [];

    try {
      final activities = <Map<String, dynamic>>[];

      // Get recent inspections
      final recentInspections = await _client
          .from('inspections')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(3);

      for (final inspection in recentInspections) {
        activities.add({
          'type': 'inspection',
          'title': 'Inspection Created',
          'description': 'Property: ${inspection['property_location']}',
          'timestamp': inspection['created_at'],
          'icon': 'inspection',
        });
      }

      // Get recent schedules
      final recentSchedules = await _client
          .from('schedules')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(2);

      for (final schedule in recentSchedules) {
        activities.add({
          'type': 'schedule',
          'title': 'Appointment Scheduled',
          'description': 'Client: ${schedule['client_name']}',
          'timestamp': schedule['created_at'],
          'icon': 'calendar',
        });
      }

      // Get recent invoices
      final recentInvoices = await _client
          .from('invoices')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(2);

      for (final invoice in recentInvoices) {
        activities.add({
          'type': 'invoice',
          'title': 'Invoice Generated',
          'description': 'Invoice: ${invoice['invoice_number']}',
          'timestamp': invoice['created_at'],
          'icon': 'document',
        });
      }

      // Sort by timestamp
      activities.sort((a, b) => DateTime.parse(b['timestamp'])
          .compareTo(DateTime.parse(a['timestamp'])));

      return activities.take(5).toList();
    } catch (error) {
      return [];
    }
  }

  // Get monthly inspection trend
  Future<List<Map<String, dynamic>>> getMonthlyInspectionTrend() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return [];

    try {
      final now = DateTime.now();
      final months = <Map<String, dynamic>>[];

      for (int i = 5; i >= 0; i--) {
        final monthDate = DateTime(now.year, now.month - i, 1);
        final nextMonthDate = DateTime(now.year, now.month - i + 1, 1);

        final response = await _client
            .from('inspections')
            .select()
            .eq('user_id', user.id)
            .gte('created_at', monthDate.toIso8601String())
            .lt('created_at', nextMonthDate.toIso8601String())
            .count();

        months.add({
          'month': monthDate.month,
          'year': monthDate.year,
          'count': response.count ?? 0,
          'monthName': _getMonthName(monthDate.month),
        });
      }

      return months;
    } catch (error) {
      return [];
    }
  }

  // Get inspection status distribution
  Future<Map<String, int>> getInspectionStatusDistribution(
      String inspectionId) async {
    try {
      final areas =
          await InspectionService.instance.getInspectionAreas(inspectionId);

      int passedCount = 0;
      int failedCount = 0;
      int naCount = 0;

      for (final area in areas) {
        final items =
            await InspectionService.instance.getInspectionItems(area.id);
        for (final item in items) {
          switch (item.status?.toLowerCase()) {
            case 'pass':
              passedCount++;
              break;
            case 'fail':
              failedCount++;
              break;
            case 'n/a':
            default:
              naCount++;
              break;
          }
        }
      }

      return {
        'passed': passedCount,
        'failed': failedCount,
        'na': naCount,
      };
    } catch (error) {
      return {
        'passed': 0,
        'failed': 0,
        'na': 0,
      };
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
