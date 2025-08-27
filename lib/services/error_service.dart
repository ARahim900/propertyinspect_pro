import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Centralized error handling and logging service
class ErrorService {
  static ErrorService? _instance;
  static ErrorService get instance => _instance ??= ErrorService._();
  
  ErrorService._();
  
  /// Log error with context
  void logError(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? userId,
    Map<String, dynamic>? context,
  }) {
    final errorData = {
      'message': message,
      'error': error?.toString(),
      'stackTrace': stackTrace?.toString(),
      'userId': userId,
      'timestamp': DateTime.now().toIso8601String(),
      'context': context,
    };
    
    if (kDebugMode) {
      developer.log(
        message,
        error: error,
        stackTrace: stackTrace,
        name: 'PropertyInspectPro',
      );
    }
    
    // In production, send to crash reporting service
    _sendToCrashReporting(errorData);
  }
  
  /// Log user action for analytics
  void logUserAction(String action, {Map<String, dynamic>? parameters}) {
    final actionData = {
      'action': action,
      'parameters': parameters,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    if (kDebugMode) {
      developer.log('User Action: $action', name: 'UserAnalytics');
    }
    
    // Send to analytics service
    _sendToAnalytics(actionData);
  }
  
  /// Handle and format API errors
  String formatApiError(dynamic error) {
    if (error.toString().contains('SocketException')) {
      return 'No internet connection. Please check your network and try again.';
    } else if (error.toString().contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    } else if (error.toString().contains('FormatException')) {
      return 'Invalid data format received. Please contact support.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }
  
  void _sendToCrashReporting(Map<String, dynamic> errorData) {
    // Implement crash reporting (Firebase Crashlytics, Sentry, etc.)
    // For now, just store locally for debugging
  }
  
  void _sendToAnalytics(Map<String, dynamic> actionData) {
    // Implement analytics (Firebase Analytics, Mixpanel, etc.)
    // For now, just log for debugging
  }
}