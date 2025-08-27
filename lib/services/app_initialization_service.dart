import 'package:flutter/foundation.dart';
import './supabase_service.dart';
import './database_setup_service.dart';
import './crash_reporting_service.dart';
import './error_service.dart';
import './performance_service.dart';
import './backup_service.dart';
import './offline_service.dart';
import './state_service.dart';

/// Service to handle complete app initialization
class AppInitializationService {
  static AppInitializationService? _instance;
  static AppInitializationService get instance => _instance ??= AppInitializationService._();
  
  AppInitializationService._();
  
  bool _isInitialized = false;
  final List<String> _initializationSteps = [];
  final List<String> _failedSteps = [];
  
  /// Initialize all app services
  Future<void> initializeApp() async {
    if (_isInitialized) return;
    
    debugPrint('🚀 Starting app initialization...');
    PerformanceService.instance.startOperation('app_initialization');
    
    try {
      // Step 1: Initialize crash reporting
      await _initializeStep('Crash Reporting', () async {
        await CrashReportingService.initialize();
      });
      
      // Step 2: Initialize Supabase
      await _initializeStep('Supabase Connection', () async {
        await SupabaseService.initialize();
      });
      
      // Step 3: Setup database schema
      await _initializeStep('Database Schema', () async {
        await DatabaseSetupService.instance.setupDatabase();
      });
      
      // Step 4: Initialize state management
      await _initializeStep('State Management', () async {
        // Initialize app state
        StateService.instance.setLoading(false);
      });
      
      // Step 5: Check connectivity and setup offline service
      await _initializeStep('Offline Service', () async {
        final isOnline = await OfflineService.instance.isOnline();
        StateService.instance.setOnlineStatus(isOnline);
        
        if (isOnline) {
          await OfflineService.instance.syncPendingData();
        }
      });
      
      // Step 6: Setup automatic backup (non-critical)
      await _initializeStep('Backup Service', () async {
        await BackupService.instance.performAutoBackup();
      }, critical: false);
      
      // Step 7: Create sample data in debug mode
      if (kDebugMode) {
        await _initializeStep('Sample Data', () async {
          await DatabaseSetupService.instance.createSampleData();
        }, critical: false);
      }
      
      _isInitialized = true;
      
      PerformanceService.instance.endOperation('app_initialization');
      
      debugPrint('✅ App initialization completed successfully');
      debugPrint('📊 Initialized steps: ${_initializationSteps.length}');
      if (_failedSteps.isNotEmpty) {
        debugPrint('⚠️ Failed steps: ${_failedSteps.join(', ')}');
      }
      
      // Track initialization success
      PerformanceService.instance.trackUserAction('app_initialized', parameters: {
        'successful_steps': _initializationSteps.length,
        'failed_steps': _failedSteps.length,
        'initialization_time': PerformanceService.instance.getPerformanceSummary()['avg_duration_ms'],
      });
      
    } catch (e, stackTrace) {
      PerformanceService.instance.endOperation('app_initialization');
      
      ErrorService.instance.logError(
        'App initialization failed',
        error: e,
        stackTrace: stackTrace,
        context: {
          'successful_steps': _initializationSteps,
          'failed_steps': _failedSteps,
        },
      );
      
      await CrashReportingService.instance.recordError(
        e,
        stackTrace,
        reason: 'App initialization failure',
        context: {
          'successful_steps': _initializationSteps.join(', '),
          'failed_steps': _failedSteps.join(', '),
        },
        fatal: true,
      );
      
      rethrow;
    }
  }
  
  /// Initialize a single step with error handling
  Future<void> _initializeStep(
    String stepName,
    Future<void> Function() initFunction, {
    bool critical = true,
  }) async {
    try {
      debugPrint('🔧 Initializing: $stepName');
      await initFunction();
      _initializationSteps.add(stepName);
      debugPrint('✅ $stepName initialized successfully');
    } catch (e, stackTrace) {
      _failedSteps.add(stepName);
      debugPrint('❌ $stepName initialization failed: $e');
      
      ErrorService.instance.logError(
        '$stepName initialization failed',
        error: e,
        stackTrace: stackTrace,
        context: {'step': stepName, 'critical': critical},
      );
      
      await CrashReportingService.instance.recordError(
        e,
        stackTrace,
        reason: '$stepName initialization failed',
        context: {'step': stepName, 'critical': critical},
        fatal: critical,
      );
      
      if (critical) {
        rethrow;
      }
    }
  }
  
  /// Get initialization status
  Map<String, dynamic> get initializationStatus => {
    'initialized': _isInitialized,
    'successful_steps': _initializationSteps,
    'failed_steps': _failedSteps,
    'total_steps': _initializationSteps.length + _failedSteps.length,
    'success_rate': _initializationSteps.length / (_initializationSteps.length + _failedSteps.length),
  };
  
  /// Check if app is fully initialized
  bool get isInitialized => _isInitialized;
  
  /// Get initialization summary
  String get initializationSummary {
    if (!_isInitialized) {
      return 'App initialization in progress...';
    }
    
    final total = _initializationSteps.length + _failedSteps.length;
    final success = _initializationSteps.length;
    
    if (_failedSteps.isEmpty) {
      return 'App fully initialized ($success/$total steps)';
    } else {
      return 'App partially initialized ($success/$total steps, ${_failedSteps.length} failed)';
    }
  }
  
  /// Retry failed initialization steps
  Future<void> retryFailedSteps() async {
    if (_failedSteps.isEmpty) return;
    
    debugPrint('🔄 Retrying failed initialization steps...');
    
    final failedStepsCopy = List<String>.from(_failedSteps);
    _failedSteps.clear();
    
    for (final stepName in failedStepsCopy) {
      try {
        switch (stepName) {
          case 'Crash Reporting':
            await _initializeStep('Crash Reporting', () async {
              await CrashReportingService.initialize();
            });
            break;
          case 'Supabase Connection':
            await _initializeStep('Supabase Connection', () async {
              await SupabaseService.initialize();
            });
            break;
          case 'Database Schema':
            await _initializeStep('Database Schema', () async {
              await DatabaseSetupService.instance.setupDatabase();
            });
            break;
          case 'Offline Service':
            await _initializeStep('Offline Service', () async {
              final isOnline = await OfflineService.instance.isOnline();
              StateService.instance.setOnlineStatus(isOnline);
            });
            break;
          case 'Backup Service':
            await _initializeStep('Backup Service', () async {
              await BackupService.instance.performAutoBackup();
            }, critical: false);
            break;
        }
      } catch (e) {
        // Step failed again, will remain in failed list
        debugPrint('❌ Retry failed for $stepName: $e');
      }
    }
    
    debugPrint('🔄 Retry completed. Remaining failed steps: ${_failedSteps.length}');
  }
}