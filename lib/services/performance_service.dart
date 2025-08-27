import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Service for monitoring app performance and user analytics
class PerformanceService {
  static PerformanceService? _instance;
  static PerformanceService get instance => _instance ??= PerformanceService._();
  
  PerformanceService._();
  
  final Map<String, DateTime> _operationStartTimes = {};
  final List<Map<String, dynamic>> _performanceMetrics = [];
  
  /// Start timing an operation
  void startOperation(String operationName) {
    _operationStartTimes[operationName] = DateTime.now();
  }
  
  /// End timing an operation and log the duration
  void endOperation(String operationName, {Map<String, dynamic>? metadata}) {
    final startTime = _operationStartTimes[operationName];
    if (startTime == null) return;
    
    final duration = DateTime.now().difference(startTime);
    _operationStartTimes.remove(operationName);
    
    final metric = {
      'operation': operationName,
      'duration_ms': duration.inMilliseconds,
      'timestamp': DateTime.now().toIso8601String(),
      'metadata': metadata,
    };
    
    _performanceMetrics.add(metric);
    
    if (kDebugMode) {
      developer.log(
        'Operation: $operationName took ${duration.inMilliseconds}ms',
        name: 'Performance',
      );
    }
    
    // Send to analytics if duration is concerning
    if (duration.inMilliseconds > 3000) {
      _reportSlowOperation(operationName, duration.inMilliseconds, metadata);
    }
  }
  
  /// Track screen view
  void trackScreenView(String screenName, {Map<String, dynamic>? parameters}) {
    final event = {
      'event_type': 'screen_view',
      'screen_name': screenName,
      'timestamp': DateTime.now().toIso8601String(),
      'parameters': parameters,
    };
    
    if (kDebugMode) {
      developer.log('Screen View: $screenName', name: 'Analytics');
    }
    
    _sendAnalyticsEvent(event);
  }
  
  /// Track user action
  void trackUserAction(String action, {Map<String, dynamic>? parameters}) {
    final event = {
      'event_type': 'user_action',
      'action': action,
      'timestamp': DateTime.now().toIso8601String(),
      'parameters': parameters,
    };
    
    if (kDebugMode) {
      developer.log('User Action: $action', name: 'Analytics');
    }
    
    _sendAnalyticsEvent(event);
  }
  
  /// Track inspection completion
  void trackInspectionCompleted({
    required String inspectionId,
    required int itemCount,
    required int duration,
    required String propertyType,
  }) {
    trackUserAction('inspection_completed', parameters: {
      'inspection_id': inspectionId,
      'item_count': itemCount,
      'duration_minutes': duration,
      'property_type': propertyType,
    });
  }
  
  /// Track photo capture
  void trackPhotoCapture({
    required String context,
    required int photoCount,
    required double totalSizeMB,
  }) {
    trackUserAction('photos_captured', parameters: {
      'context': context,
      'photo_count': photoCount,
      'total_size_mb': totalSizeMB,
    });
  }
  
  /// Get performance summary
  Map<String, dynamic> getPerformanceSummary() {
    if (_performanceMetrics.isEmpty) {
      return {'total_operations': 0};
    }
    
    final durations = _performanceMetrics
        .map((m) => m['duration_ms'] as int)
        .toList();
    
    durations.sort();
    
    return {
      'total_operations': _performanceMetrics.length,
      'avg_duration_ms': durations.reduce((a, b) => a + b) / durations.length,
      'median_duration_ms': durations[durations.length ~/ 2],
      'max_duration_ms': durations.last,
      'min_duration_ms': durations.first,
    };
  }
  
  /// Clear old metrics to prevent memory issues
  void clearOldMetrics() {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    _performanceMetrics.removeWhere((metric) {
      final timestamp = DateTime.parse(metric['timestamp']);
      return timestamp.isBefore(cutoff);
    });
  }
  
  void _reportSlowOperation(String operation, int durationMs, Map<String, dynamic>? metadata) {
    // Report slow operations to monitoring service
    if (kDebugMode) {
      developer.log(
        'SLOW OPERATION: $operation took ${durationMs}ms',
        name: 'Performance Warning',
      );
    }
  }
  
  void _sendAnalyticsEvent(Map<String, dynamic> event) {
    // Send to analytics service (Firebase Analytics, Mixpanel, etc.)
    // For now, just store locally
  }
}