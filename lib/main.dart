import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';
import '../widgets/custom_error_widget.dart';
import './services/app_initialization_service.dart';
import './services/crash_reporting_service.dart';
import './services/error_service.dart';
import './services/performance_service.dart';

void main() async {
  // Wrap entire app in error boundary
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize all app services
    await AppInitializationService.instance.initializeApp();

    // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
    ErrorWidget.builder = (FlutterErrorDetails details) {
      // Log error to our service
      ErrorService.instance.logError(
        'Widget error occurred',
        error: details.exception,
        stackTrace: details.stack,
        context: {
          'library': details.library,
          'context': details.context?.toString(),
        },
      );
      
      // Report to crash reporting
      CrashReportingService.instance.recordError(
        details.exception,
        details.stack,
        reason: 'Widget Error',
        context: {
          'library': details.library,
          'context': details.context?.toString(),
        },
      );
      
      return CustomErrorWidget(errorDetails: details);
    };

    // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    
    runApp(ErrorBoundary(
      child: MyApp(),
      onError: (details) {
        ErrorService.instance.logError(
          'Error boundary caught error',
          error: details.exception,
          stackTrace: details.stack,
        );
      },
    ));
    
  }, (error, stackTrace) {
    // Catch any uncaught errors
    ErrorService.instance.logError(
      'Uncaught error in main zone',
      error: error,
      stackTrace: stackTrace,
    );
    
    CrashReportingService.instance.recordError(
      error,
      stackTrace,
      reason: 'Uncaught zone error',
      fatal: true,
    );
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, screenType) {
      return MaterialApp(
        title: 'propertyinspect_pro',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(1.0),
            ),
            child: ErrorBoundary(
              child: child!,
              onError: (details) {
                // Additional error handling at app level
                ErrorService.instance.logError(
                  'App-level error boundary triggered',
                  error: details.exception,
                  stackTrace: details.stack,
                );
              },
            ),
          );
        },
        // 🚨 END CRITICAL SECTION
        debugShowCheckedModeBanner: false,
        routes: AppRoutes.routes,
        initialRoute: AppRoutes.initial,
      );
    });
  }
}
