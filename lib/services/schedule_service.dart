import './supabase_service.dart';

class ScheduleService {
  final SupabaseService _supabase = SupabaseService.instance;

  // Get schedules for current user
  Future<List<Map<String, dynamic>>> getUserSchedules({
    int? limit,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase.client
          .from('schedules')
          .select('*')
          .eq('user_id', _supabase.currentUserId!);

      if (status != null) {
        query = query.eq('status', status);
      }

      if (startDate != null) {
        query = query.gte('date', startDate.toIso8601String().split('T')[0]);
      }

      if (endDate != null) {
        query = query.lte('date', endDate.toIso8601String().split('T')[0]);
      }

      var orderedQuery =
          query.order('date', ascending: true).order('time', ascending: true);

      if (limit != null) {
        return await orderedQuery.limit(limit);
      }

      return await orderedQuery;
    } catch (error) {
      throw Exception('Failed to load schedules: $error');
    }
  }

  // Get single schedule details
  Future<Map<String, dynamic>> getScheduleDetails(String scheduleId) async {
    try {
      final response = await _supabase.client
          .from('schedules')
          .select('*')
          .eq('id', scheduleId)
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to load schedule details: $error');
    }
  }

  // Create new schedule
  Future<Map<String, dynamic>> createSchedule({
    required String title,
    required DateTime date,
    required String time,
    required String clientName,
    String? clientEmail,
    String? clientPhone,
    String? propertyLocation,
    String? propertyType,
    int duration = 60,
    String priority = 'medium',
    String? notes,
  }) async {
    try {
      final scheduleData = {
        'user_id': _supabase.currentUserId,
        'title': title,
        'date': date.toIso8601String().split('T')[0],
        'time': time,
        'client_name': clientName,
        'client_email': clientEmail,
        'client_phone': clientPhone,
        'property_location': propertyLocation,
        'property_type': propertyType,
        'duration': duration,
        'priority': priority,
        'notes': notes,
        'status': 'scheduled',
      };

      final response = await _supabase.client
          .from('schedules')
          .insert(scheduleData)
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to create schedule: $error');
    }
  }

  // Update schedule
  Future<Map<String, dynamic>> updateSchedule(
    String scheduleId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      // Add updated timestamp
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase.client
          .from('schedules')
          .update(updateData)
          .eq('id', scheduleId)
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to update schedule: $error');
    }
  }

  // Update schedule status
  Future<void> updateScheduleStatus(String scheduleId, String status) async {
    try {
      await _supabase.client
          .from('schedules')
          .update({'status': status}).eq('id', scheduleId);
    } catch (error) {
      throw Exception('Failed to update schedule status: $error');
    }
  }

  // Delete schedule
  Future<void> deleteSchedule(String scheduleId) async {
    try {
      await _supabase.client.from('schedules').delete().eq('id', scheduleId);
    } catch (error) {
      throw Exception('Failed to delete schedule: $error');
    }
  }

  // Get schedules for specific date
  Future<List<Map<String, dynamic>>> getSchedulesForDate(DateTime date) async {
    try {
      final dateString = date.toIso8601String().split('T')[0];

      final schedules = await _supabase.client
          .from('schedules')
          .select('*')
          .eq('user_id', _supabase.currentUserId!)
          .eq('date', dateString)
          .order('time', ascending: true);

      return schedules;
    } catch (error) {
      throw Exception('Failed to load schedules for date: $error');
    }
  }

  // Get upcoming schedules
  Future<List<Map<String, dynamic>>> getUpcomingSchedules(
      {int limit = 10}) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];

      final schedules = await _supabase.client
          .from('schedules')
          .select('*')
          .eq('user_id', _supabase.currentUserId!)
          .gte('date', today)
          .eq('status', 'scheduled')
          .order('date', ascending: true)
          .order('time', ascending: true)
          .limit(limit);

      return schedules;
    } catch (error) {
      throw Exception('Failed to load upcoming schedules: $error');
    }
  }

  // Get schedules statistics
  Future<Map<String, dynamic>> getScheduleStats() async {
    try {
      final userId = _supabase.currentUserId!;
      final today = DateTime.now().toIso8601String().split('T')[0];
      final weekStart = DateTime.now()
          .subtract(Duration(days: 7))
          .toIso8601String()
          .split('T')[0];

      // Today's schedules
      final todaySchedules = await _supabase.client
          .from('schedules')
          .select('*')
          .eq('user_id', userId)
          .eq('date', today);

      // This week's schedules
      final weekSchedules = await _supabase.client
          .from('schedules')
          .select('*')
          .eq('user_id', userId)
          .gte('date', weekStart);

      // Pending schedules (upcoming)
      final pendingSchedules = await _supabase.client
          .from('schedules')
          .select('*')
          .eq('user_id', userId)
          .gte('date', today)
          .eq('status', 'scheduled');

      // Completed schedules this month
      final monthStart =
          DateTime.now().toIso8601String().substring(0, 8) + '01';
      final completedSchedules = await _supabase.client
          .from('schedules')
          .select('*')
          .eq('user_id', userId)
          .gte('date', monthStart)
          .eq('status', 'completed');

      return {
        'todayCount': todaySchedules.length,
        'weekCount': weekSchedules.length,
        'pendingCount': pendingSchedules.length,
        'completedThisMonth': completedSchedules.length,
      };
    } catch (error) {
      throw Exception('Failed to load schedule stats: $error');
    }
  }

  // Search schedules
  Future<List<Map<String, dynamic>>> searchSchedules(String query) async {
    try {
      // Search in title, client name, and property location
      final schedules = await _supabase.client
          .from('schedules')
          .select('*')
          .eq('user_id', _supabase.currentUserId!)
          .or('title.ilike.%$query%,client_name.ilike.%$query%,property_location.ilike.%$query%')
          .order('date', ascending: false);

      return schedules;
    } catch (error) {
      throw Exception('Failed to search schedules: $error');
    }
  }

  // Convert schedule to inspection
  Future<Map<String, dynamic>> convertScheduleToInspection(
      String scheduleId) async {
    try {
      final schedule = await getScheduleDetails(scheduleId);

      // Create inspection from schedule data
      final inspectionData = {
        'user_id': _supabase.currentUserId,
        'client_name': schedule['client_name'],
        'property_location': schedule['property_location'] ?? 'Not specified',
        'property_type': schedule['property_type'] ?? 'residential',
        'inspector_name':
            'Inspector', // You might want to get this from user profile
        'inspection_date': schedule['date'],
      };

      final inspection = await _supabase.client
          .from('inspections')
          .insert(inspectionData)
          .select()
          .single();

      // Update schedule status
      await updateScheduleStatus(scheduleId, 'completed');

      return inspection;
    } catch (error) {
      throw Exception('Failed to convert schedule to inspection: $error');
    }
  }
}
