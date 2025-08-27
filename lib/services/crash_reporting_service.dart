import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../firebase_options.dart';

/// Service for handling crash reporting and analytics
class CrashReportingService {
  static CrashReportingService? _instance;
  static CrashReportingService get instance => _instance ??= CrashReportingService._();
  
  CrashReportingService._();
  
  bool _isInitialized = false;
  
  /// Initialize crash reporting
  static Future<void> initialize() async {
    try {
      // Initialize Firebase with options
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      // Set up Crashlytics
      if (!kDebugMode) {
        // Only enable in release mode
        FlutterError.onError = (errorDetails) {
          FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
        };
        
        // Pass all uncaught asynchronous errors to Crashlytics
        PlatformDispatcher.instance.onError = (error, stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return true;
        };
      } else {
        // In debug mode, disable crash reporting collection
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
      }
      
      instance._isInitialized = true;
      debugPrint('✅ Crash reporting initialized');
    } catch (e) {
      debugPrint('⚠️ Failed to initialize crash reporting: $e');
      // Don't throw error as app should continue without crash reporting
    }
  }
  
  /// Record a non-fatal error
  Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    Map<String, dynamic>? context,
    bool fatal = false,
  }) async {
    if (!_isInitialized) return;
    
    try {
      await FirebaseCrashlytics.instance.recordError(
        exception,
        stackTrace,
        reason: reason,
        information: context?.entries.map((e) => '${e.key}: ${e.value}').toList() ?? [],
        fatal: fatal,
      );
      
      if (kDebugMode) {
        debugPrint('🔥 Crash recorded: $exception');
        if (context != null) {
          debugPrint('Context: $context');
        }
      }
    } catch (e) {
      debugPrint('Failed to record crash: $e');
    }
  }
  
  /// Set user identifier for crash reports
  Future<void> setUserId(String userId) async {
    if (!_isInitialized) return;
    
    try {
      await FirebaseCrashlytics.instance.setUserIdentifier(userId);
    } catch (e) {
      debugPrint('Failed to set user ID for crash reporting: $e');
    }
  }
  
  /// Set custom key-value pairs for crash context
  Future<void> setCustomKey(String key, dynamic value) async {
    if (!_isInitialized) return;
    
    try {
      if (value is String) {
        await FirebaseCrashlytics.instance.setCustomKey(key, value);
      } else if (value is int) {
        await FirebaseCrashlytics.instance.setCustomKey(key, value);
      } else if (value is double) {
        await FirebaseCrashlytics.instance.setCustomKey(key, value);
      } else if (value is bool) {
        await FirebaseCrashlytics.instance.setCustomKey(key, value);
      } else {
        await FirebaseCrashlytics.instance.setCustomKey(key, value.toString());
      }
    } catch (e) {
      debugPrint('Failed to set custom key for crash reporting: $e');
    }
  }
  
  /// Log a message for crash context
  Future<void> log(String message) async {
    if (!_isInitialized) return;
    
    try {
      await FirebaseCrashlytics.instance.log(message);
    } catch (e) {
      debugPrint('Failed to log message for crash reporting: $e');
    }
  }
  
  /// Check if crash reporting is available
  bool get isAvailable => _isInitialized;
  
  /// Force a crash for testing (debug only)
  void testCrash() {
    if (kDebugMode) {
      FirebaseCrashlytics.instance.crash();
    }
  }
}

/// Error boundary widget to catch and handle widget errors
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(FlutterErrorDetails)? errorBuilder;
  final void Function(FlutterErrorDetails)? onError;
  
  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });
  
  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _errorDetails;
  
  @override
  Widget build(BuildContext context) {
    if (_errorDetails != null) {
      return widget.errorBuilder?.call(_errorDetails!) ?? 
             _buildDefaultErrorWidget(_errorDetails!);
    }
    
    return widget.child;
  }
  
  Widget _buildDefaultErrorWidget(FlutterErrorDetails errorDetails) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'We\'re sorry for the inconvenience. The error has been reported.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _errorDetails = null;
                  });
                },
                child: const Text('Try Again'),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 16),
                ExpansionTile(
                  title: const Text('Error Details'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        errorDetails.toString(),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  void initState() {
    super.initState();
    
    // Set up error handling for this widget tree
    FlutterError.onError = (FlutterErrorDetails details) {
      // Report to crash reporting service
      CrashReportingService.instance.recordError(
        details.exception,
        details.stack,
        reason: 'Widget Error',
        context: {
          'library': details.library,
          'context': details.context?.toString(),
        },
      );
      
      // Call custom error handler
      widget.onError?.call(details);
      
      // Update UI to show error
      if (mounted) {
        setState(() {
          _errorDetails = details;
        });
      }
    };
  }
}