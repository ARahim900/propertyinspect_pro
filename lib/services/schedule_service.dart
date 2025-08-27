import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/schedule.dart';
import './auth_service.dart';
import './supabase_service.dart';

class ScheduleService {
  static ScheduleService? _instance;
  static ScheduleService get instance => _instance ??= ScheduleService._();

  ScheduleService._();

  final SupabaseClient _client = SupabaseService.instance.client;

  // Get all schedules for current user
  Future<List<Schedule>> getSchedules() async {
    final user = AuthService.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final response = await _client
          .from('schedules')
          .select()
          .eq('user_id', user.id)
          .order('date', ascending: true)
          .order('time', ascending: true);

      return response.map((json) => Schedule.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to get schedules: $error');
    }
  }

  // Get schedules for a specific date
  Future<List<Schedule>> getSchedulesByDate(DateTime date) async {
    final user = AuthService.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final dateString = date.toIso8601String().split('T')[0];

    try {
      final response = await _client
          .from('schedules')
          .select()
          .eq('user_id', user.id)
          .eq('date', dateString)
          .order('time', ascending: true);

      return response.map((json) => Schedule.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to get schedules for date: $error');
    }
  }

  // Get upcoming schedules
  Future<List<Schedule>> getUpcomingSchedules({int limit = 10}) async {
    final user = AuthService.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final today = DateTime.now().toIso8601String().split('T')[0];

    try {
      final response = await _client
          .from('schedules')
          .select()
          .eq('user_id', user.id)
          .gte('date', today)
          .order('date', ascending: true)
          .order('time', ascending: true)
          .limit(limit);

      return response.map((json) => Schedule.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to get upcoming schedules: $error');
    }
  }

  // Create new schedule
  Future<Schedule> createSchedule(Map<String, dynamic> data) async {
    final user = AuthService.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    data['user_id'] = user.id;

    try {
      final response =
          await _client.from('schedules').insert(data).select().single();

      return Schedule.fromJson(response);
    } catch (error) {
      throw Exception('Failed to create schedule: $error');
    }
  }

  // Update schedule
  Future<Schedule> updateSchedule(String id, Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from('schedules')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return Schedule.fromJson(response);
    } catch (error) {
      throw Exception('Failed to update schedule: $error');
    }
  }

  // Delete schedule
  Future<void> deleteSchedule(String id) async {
    try {
      await _client.from('schedules').delete().eq('id', id);
    } catch (error) {
      throw Exception('Failed to delete schedule: $error');
    }
  }

  // Get schedule by ID
  Future<Schedule> getScheduleById(String id) async {
    try {
      final response =
          await _client.from('schedules').select().eq('id', id).single();

      return Schedule.fromJson(response);
    } catch (error) {
      throw Exception('Failed to get schedule: $error');
    }
  }

  // Filter schedules
  Future<List<Schedule>> filterSchedules({
    String? status,
    String? priority,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final user = AuthService.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      var query = _client.from('schedules').select().eq('user_id', user.id);

      if (status != null) {
        query = query.eq('status', status);
      }

      if (priority != null) {
        query = query.eq('priority', priority);
      }

      if (startDate != null) {
        final startDateString = startDate.toIso8601String().split('T')[0];
        query = query.gte('date', startDateString);
      }

      if (endDate != null) {
        final endDateString = endDate.toIso8601String().split('T')[0];
        query = query.lte('date', endDateString);
      }

      final response = await query
          .order('date', ascending: true)
          .order('time', ascending: true);

      return response.map((json) => Schedule.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to filter schedules: $error');
    }
  }

  // Get today's schedules for dashboard
  Future<List<Schedule>> getTodaySchedules() async {
    final today = DateTime.now();
    return await getSchedulesByDate(today);
  }

  // Mark schedule as completed
  Future<Schedule> markAsCompleted(String id) async {
    return await updateSchedule(id, {'status': 'completed'});
  }

  // Mark schedule as cancelled
  Future<Schedule> markAsCancelled(String id) async {
    return await updateSchedule(id, {'status': 'cancelled'});
  }
}
