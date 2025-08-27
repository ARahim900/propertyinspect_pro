import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/inspection.dart';
import '../models/inspection_area.dart';
import '../models/inspection_item.dart';
import './auth_service.dart';
import './supabase_service.dart';

class InspectionService {
  static InspectionService? _instance;
  static InspectionService get instance => _instance ??= InspectionService._();

  InspectionService._();

  final SupabaseClient _client = SupabaseService.instance.client;

  // Get all inspections for current user
  Future<List<Inspection>> getInspections() async {
    final user = AuthService.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final response = await _client
          .from('inspections')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return response.map((json) => Inspection.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to get inspections: $error');
    }
  }

  // Get inspection by ID
  Future<Inspection> getInspectionById(String id) async {
    try {
      final response =
          await _client.from('inspections').select().eq('id', id).single();

      return Inspection.fromJson(response);
    } catch (error) {
      throw Exception('Failed to get inspection: $error');
    }
  }

  // Create new inspection
  Future<Inspection> createInspection(Map<String, dynamic> data) async {
    final user = AuthService.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    data['user_id'] = user.id;

    try {
      final response =
          await _client.from('inspections').insert(data).select().single();

      return Inspection.fromJson(response);
    } catch (error) {
      throw Exception('Failed to create inspection: $error');
    }
  }

  // Update inspection
  Future<Inspection> updateInspection(
      String id, Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from('inspections')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return Inspection.fromJson(response);
    } catch (error) {
      throw Exception('Failed to update inspection: $error');
    }
  }

  // Delete inspection
  Future<void> deleteInspection(String id) async {
    try {
      await _client.from('inspections').delete().eq('id', id);
    } catch (error) {
      throw Exception('Failed to delete inspection: $error');
    }
  }

  // Get inspection areas for an inspection
  Future<List<InspectionArea>> getInspectionAreas(String inspectionId) async {
    try {
      final response = await _client
          .from('inspection_areas')
          .select()
          .eq('inspection_id', inspectionId)
          .order('created_at', ascending: true);

      return response.map((json) => InspectionArea.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to get inspection areas: $error');
    }
  }

  // Create inspection area
  Future<InspectionArea> createInspectionArea(Map<String, dynamic> data) async {
    try {
      final response =
          await _client.from('inspection_areas').insert(data).select().single();

      return InspectionArea.fromJson(response);
    } catch (error) {
      throw Exception('Failed to create inspection area: $error');
    }
  }

  // Get inspection items for an area
  Future<List<InspectionItem>> getInspectionItems(String areaId) async {
    try {
      final response = await _client
          .from('inspection_items')
          .select()
          .eq('area_id', areaId)
          .order('created_at', ascending: true);

      return response.map((json) => InspectionItem.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to get inspection items: $error');
    }
  }

  // Create inspection item
  Future<InspectionItem> createInspectionItem(Map<String, dynamic> data) async {
    try {
      final response =
          await _client.from('inspection_items').insert(data).select().single();

      return InspectionItem.fromJson(response);
    } catch (error) {
      throw Exception('Failed to create inspection item: $error');
    }
  }

  // Update inspection item
  Future<InspectionItem> updateInspectionItem(
      String id, Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from('inspection_items')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return InspectionItem.fromJson(response);
    } catch (error) {
      throw Exception('Failed to update inspection item: $error');
    }
  }

  // Get inspection progress
  Future<Map<String, dynamic>> getInspectionProgress(
      String inspectionId) async {
    try {
      // Get all items for this inspection
      final areas = await getInspectionAreas(inspectionId);
      int totalItems = 0;
      int completedItems = 0;
      int failedItems = 0;
      int passedItems = 0;

      for (final area in areas) {
        final items = await getInspectionItems(area.id);
        totalItems += items.length;

        for (final item in items) {
          if (item.status != null && item.status != 'N/A') {
            completedItems++;
            if (item.isFailing) failedItems++;
            if (item.isPassing) passedItems++;
          }
        }
      }

      return {
        'totalItems': totalItems,
        'completedItems': completedItems,
        'passedItems': passedItems,
        'failedItems': failedItems,
        'progress': totalItems > 0 ? (completedItems / totalItems) : 0.0,
      };
    } catch (error) {
      throw Exception('Failed to get inspection progress: $error');
    }
  }

  // Get recent inspections for dashboard
  Future<List<Inspection>> getRecentInspections({int limit = 5}) async {
    final user = AuthService.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final response = await _client
          .from('inspections')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map((json) => Inspection.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to get recent inspections: $error');
    }
  }
}
