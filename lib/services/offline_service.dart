import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import './error_service.dart';
import './performance_service.dart';
import './supabase_service.dart';

/// Service for handling offline functionality and data synchronization
class OfflineService {
  static OfflineService? _instance;
  static OfflineService get instance => _instance ??= OfflineService._();
  
  OfflineService._();
  
  static const String _offlineDataKey = 'offline_inspections';
  static const String _pendingSyncKey = 'pending_sync_data';
  
  /// Check if device is online
  Future<bool> isOnline() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasConnection = connectivityResult != ConnectivityResult.none;
      
      // Also test actual internet connectivity
      if (hasConnection) {
        try {
          final isSupabaseConnected = await SupabaseService.instance.testConnection();
          return isSupabaseConnected;
        } catch (e) {
          return false;
        }
      }
      
      return false;
    } catch (e, stackTrace) {
      ErrorService.instance.logError(
        'Failed to check online status',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
  
  /// Save inspection data for offline use
  Future<void> saveOfflineInspection(Map<String, dynamic> inspectionData) async {
    PerformanceService.instance.startOperation('save_offline_inspection');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingData = prefs.getString(_offlineDataKey) ?? '[]';
      final List<dynamic> offlineInspections = json.decode(existingData);
      
      // Add timestamp and offline flag
      inspectionData['offline_created'] = DateTime.now().toIso8601String();
      inspectionData['needs_sync'] = true;
      inspectionData['offline_id'] = DateTime.now().millisecondsSinceEpoch.toString();
      
      offlineInspections.add(inspectionData);
      await prefs.setString(_offlineDataKey, json.encode(offlineInspections));
      
      debugPrint('✅ Saved offline inspection: ${inspectionData['offline_id']}');
      
      PerformanceService.instance.trackUserAction('offline_inspection_saved', parameters: {
        'inspection_type': inspectionData['property_type'],
        'offline_id': inspectionData['offline_id'],
      });
      
    } catch (e, stackTrace) {
      ErrorService.instance.logError(
        'Failed to save offline inspection',
        error: e,
        stackTrace: stackTrace,
        context: {'inspectionData': inspectionData.toString()},
      );
      rethrow;
    } finally {
      PerformanceService.instance.endOperation('save_offline_inspection');
    }
  }
  
  /// Get offline inspections
  Future<List<Map<String, dynamic>>> getOfflineInspections() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_offlineDataKey) ?? '[]';
    return List<Map<String, dynamic>>.from(json.decode(data));
  }
  
  /// Queue data for sync when online
  Future<void> queueForSync(String dataType, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final existingQueue = prefs.getString(_pendingSyncKey) ?? '[]';
    final List<dynamic> syncQueue = json.decode(existingQueue);
    
    syncQueue.add({
      'type': dataType,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    await prefs.setString(_pendingSyncKey, json.encode(syncQueue));
  }
  
  /// Sync pending data when online
  Future<void> syncPendingData() async {
    if (!await isOnline()) return;
    
    final prefs = await SharedPreferences.getInstance();
    final queueData = prefs.getString(_pendingSyncKey) ?? '[]';
    final List<dynamic> syncQueue = json.decode(queueData);
    
    // Process sync queue (implement actual sync logic)
    for (final item in syncQueue) {
      try {
        // Sync individual items based on type
        await _syncItem(item);
      } catch (e) {
        // Log error but continue with other items
        print('Sync failed for item: $e');
      }
    }
    
    // Clear synced items
    await prefs.remove(_pendingSyncKey);
  }
  
  Future<void> _syncItem(Map<String, dynamic> item) async {
    // Implement actual sync logic based on item type
    final type = item['type'];
    final data = item['data'];
    
    switch (type) {
      case 'inspection':
        // Sync inspection data
        break;
      case 'photo':
        // Sync photo uploads
        break;
      case 'invoice':
        // Sync invoice data
        break;
    }
  }
}