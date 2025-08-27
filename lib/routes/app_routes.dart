import 'package:flutter/material.dart';
import '../presentation/inspection_detail_screen/inspection_detail_screen.dart';
import '../presentation/profile_settings_screen/profile_settings_screen.dart';
import '../presentation/dashboard_screen/dashboard_screen.dart';
import '../presentation/schedule_list_screen/schedule_list_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/invoice_generation_screen/invoice_generation_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String inspectionDetail = '/inspection-detail-screen';
  static const String profileSettings = '/profile-settings-screen';
  static const String dashboard = '/dashboard-screen';
  static const String scheduleList = '/schedule-list-screen';
  static const String login = '/login-screen';
  static const String invoiceGeneration = '/invoice-generation-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const LoginScreen(),
    inspectionDetail: (context) => const InspectionDetailScreen(),
    profileSettings: (context) => const ProfileSettingsScreen(),
    dashboard: (context) => const DashboardScreen(),
    scheduleList: (context) => const ScheduleListScreen(),
    login: (context) => const LoginScreen(),
    invoiceGeneration: (context) => const InvoiceGenerationScreen(),
    // TODO: Add your other routes here
  };
}
