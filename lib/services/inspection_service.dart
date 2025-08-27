import 'dart:io';
import './supabase_service.dart';

class InspectionService {
  final SupabaseService _supabase = SupabaseService.instance;

  // Get inspections for current user
  Future<List<Map<String, dynamic>>> getUserInspections({
    int? limit,
    String? status,
  }) async {
    try {
      var query = _supabase.client
          .from('inspections')
          .select('*, inspection_areas!inner(*, inspection_items(*))')
          .eq('user_id', _supabase.currentUserId!);

      if (status != null) {
        query = query.eq('status', status);
      }

      var orderedQuery = query.order('created_at', ascending: false);

      if (limit != null) {
        return await orderedQuery.limit(limit);
      }

      return await orderedQuery;
    } catch (error) {
      throw Exception('Failed to load inspections: $error');
    }
  }

  // Get single inspection with full details
  Future<Map<String, dynamic>> getInspectionDetails(String inspectionId) async {
    try {
      final response = await _supabase.client.from('inspections').select('''
            *,
            inspection_areas!inner(
              *,
              inspection_items(*)
            )
          ''').eq('id', inspectionId).single();

      return response;
    } catch (error) {
      throw Exception('Failed to load inspection details: $error');
    }
  }

  // Create new inspection
  Future<Map<String, dynamic>> createInspection({
    required String clientName,
    required String propertyLocation,
    required String propertyType,
    required String inspectorName,
    required DateTime inspectionDate,
  }) async {
    try {
      final inspectionData = {
        'user_id': _supabase.currentUserId,
        'client_name': clientName,
        'property_location': propertyLocation,
        'property_type': propertyType,
        'inspector_name': inspectorName,
        'inspection_date': inspectionDate.toIso8601String().split('T')[0],
      };

      final response = await _supabase.client
          .from('inspections')
          .insert(inspectionData)
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to create inspection: $error');
    }
  }

  // Update inspection status
  Future<void> updateInspectionStatus(
      String inspectionId, String status) async {
    try {
      await _supabase.client
          .from('inspections')
          .update({'status': status}).eq('id', inspectionId);
    } catch (error) {
      throw Exception('Failed to update inspection status: $error');
    }
  }

  // Create inspection area
  Future<Map<String, dynamic>> createInspectionArea({
    required String inspectionId,
    required String name,
  }) async {
    try {
      final areaData = {
        'inspection_id': inspectionId,
        'name': name,
      };

      final response = await _supabase.client
          .from('inspection_areas')
          .insert(areaData)
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to create inspection area: $error');
    }
  }

  // Create inspection item
  Future<Map<String, dynamic>> createInspectionItem({
    required String areaId,
    required String point,
    required String category,
    String? comments,
    String? location,
    String status = 'N/A',
  }) async {
    try {
      final itemData = {
        'area_id': areaId,
        'point': point,
        'category': category,
        'comments': comments,
        'location': location,
        'status': status,
        'photos': <String>[],
      };

      final response = await _supabase.client
          .from('inspection_items')
          .insert(itemData)
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to create inspection item: $error');
    }
  }

  // Update inspection item
  Future<void> updateInspectionItem(
    String itemId, {
    String? status,
    String? comments,
    List<String>? photos,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (status != null) updateData['status'] = status;
      if (comments != null) updateData['comments'] = comments;
      if (photos != null) updateData['photos'] = photos;

      await _supabase.client
          .from('inspection_items')
          .update(updateData)
          .eq('id', itemId);
    } catch (error) {
      throw Exception('Failed to update inspection item: $error');
    }
  }

  // Upload photo to storage and add to item
  Future<String> uploadInspectionPhoto(String filePath, String itemId) async {
    try {
      final fileName =
          'inspection_${itemId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _supabase.client.storage
          .from('inspection-photos')
          .upload(fileName, File(filePath));

      final publicUrl = _supabase.client.storage
          .from('inspection-photos')
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (error) {
      throw Exception('Failed to upload photo: $error');
    }
  }

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
          .eq('inspection_date', todayStart)
          .count();

      // Get this week's completed inspections
      final weekStart = DateTime.now()
          .subtract(Duration(days: 7))
          .toIso8601String()
          .split('T')[0];

      final weeklyInspections = await _supabase.client
          .from('inspections')
          .select('id')
          .eq('user_id', userId)
          .gte('inspection_date', weekStart)
          .count();

      // Get pending invoices count
      final pendingInvoices = await _supabase.client
          .from('invoices')
          .select('total_amount')
          .eq('user_id', userId)
          .eq('status', 'draft');

      final pendingTotal = pendingInvoices.fold<double>(0.0,
          (sum, invoice) => sum + (invoice['total_amount'] as num).toDouble());

      return {
        'todayInspections': todayInspections.count ?? 0,
        'weeklyCompleted': weeklyInspections.count ?? 0,
        'pendingInvoicesCount': pendingInvoices.length,
        'pendingInvoicesAmount': pendingTotal,
      };
    } catch (error) {
      throw Exception('Failed to load dashboard stats: $error');
    }
  }
}