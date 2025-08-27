import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/dashboard_screen/dashboard_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    AuthService.instance.authStateChanges.listen((AuthState data) {
      if (mounted) {
        final session = data.session;
        if (session != null) {
          // User is logged in, navigate to dashboard
          Navigator.of(context).pushReplacementNamed('/dashboard-screen');
        } else {
          // User is logged out, navigate to login
          Navigator.of(context).pushReplacementNamed('/login-screen');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show appropriate screen based on auth state
    return AuthService.instance.isAuthenticated
        ? const DashboardScreen()
        : const LoginScreen();
  }
}
