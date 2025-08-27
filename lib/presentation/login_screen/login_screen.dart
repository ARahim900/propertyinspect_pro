import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/inspection.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  // Mock credentials for development/demo purposes
  final Map<String, Map<String, String>> _mockCredentials = {
    'inspector@propertyinspect.com': {
      'password': 'inspector123',
      'role': 'inspector',
      'name': 'John Inspector',
    },
    'admin@propertyinspect.com': {
      'password': 'admin123',
      'role': 'admin',
      'name': 'Sarah Admin',
    },
    'manager@propertyinspect.com': {
      'password': 'manager123',
      'role': 'manager',
      'name': 'Mike Manager',
    },
  };

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Column(
                    children: [
                      SizedBox(height: 8.h),
                      _buildLogo(),
                      SizedBox(height: 6.h),
                      _buildLoginForm(),
                      const Spacer(),
                      _buildNavigationHint(),
                      _buildFooter(),
                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.primary,
            borderRadius: BorderRadius.circular(4.w),
            boxShadow: [
              BoxShadow(
                color: AppTheme.lightTheme.colorScheme.primary.withValues(
                  alpha: 0.3,
                ),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CustomIconWidget(
            iconName: 'home_work',
            color: Colors.white,
            size: 8.w,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          'PropertyInspect Pro',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Professional Property Inspection Management',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
              alpha: 0.7,
            ),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sign In',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Enter your credentials to access your account',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                alpha: 0.7,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          _buildEmailField(),
          SizedBox(height: 3.h),
          _buildPasswordField(),
          SizedBox(height: 2.h),
          _buildForgotPasswordLink(),
          SizedBox(height: 4.h),
          _buildSignInButton(),
          SizedBox(height: 3.h),
          _buildDemoCredentials(),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: 'Enter your email address',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'email',
                color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                  alpha: 0.6,
                ),
                size: 5.w,
              ),
            ),
            errorText: _emailError,
            errorMaxLines: 2,
          ),
          onChanged: (value) {
            if (_emailError != null) {
              setState(() => _emailError = null);
            }
          },
          validator: _validateEmail,
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          textInputAction: TextInputAction.done,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: 'Enter your password',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'lock',
                color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                  alpha: 0.6,
                ),
                size: 5.w,
              ),
            ),
            suffixIcon: IconButton(
              onPressed:
                  _isLoading
                      ? null
                      : () {
                        setState(
                          () => _isPasswordVisible = !_isPasswordVisible,
                        );
                      },
              icon: CustomIconWidget(
                iconName: _isPasswordVisible ? 'visibility_off' : 'visibility',
                color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                  alpha: 0.6,
                ),
                size: 5.w,
              ),
            ),
            errorText: _passwordError,
            errorMaxLines: 2,
          ),
          onChanged: (value) {
            if (_passwordError != null) {
              setState(() => _passwordError = null);
            }
          },
          onFieldSubmitted: (_) => _handleSignIn(),
          validator: _validatePassword,
        ),
      ],
    );
  }

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _isLoading ? null : _handleForgotPassword,
        child: Text(
          'Forgot Password?',
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppTheme.lightTheme.colorScheme.primary.withValues(
            alpha: 0.3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.w),
          ),
        ),
        child:
            _isLoading
                ? SizedBox(
                  width: 5.w,
                  height: 5.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Text(
                  'Sign In',
                  style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }

  Widget _buildDemoCredentials() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'info',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Demo Credentials',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildCredentialRow(
            'Inspector',
            'inspector@propertyinspect.com',
            'inspector123',
          ),
          SizedBox(height: 1.h),
          _buildCredentialRow('Admin', 'admin@propertyinspect.com', 'admin123'),
          SizedBox(height: 1.h),
          _buildCredentialRow(
            'Manager',
            'manager@propertyinspect.com',
            'manager123',
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialRow(String role, String email, String password) {
    return GestureDetector(
      onTap: () {
        _emailController.text = email;
        _passwordController.text = password;
        setState(() {
          _emailError = null;
          _passwordError = null;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(1.w),
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.outline.withValues(
              alpha: 0.2,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                role,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Text(
                email,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                    alpha: 0.7,
                  ),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                password,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                    alpha: 0.7,
                  ),
                  fontFamily: 'monospace',
                ),
              ),
            ),
            CustomIconWidget(
              iconName: 'touch_app',
              color: AppTheme.lightTheme.colorScheme.primary.withValues(
                alpha: 0.6,
              ),
              size: 4.w,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationHint() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primaryContainer.withValues(
          alpha: 0.1,
        ),
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Need an account?',
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/auth-screen');
            },
            child: Text(
              'Go to Enhanced Auth Screen',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Secure Login • Data Encrypted',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
              alpha: 0.6,
            ),
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          '© 2025 PropertyInspect Pro. All rights reserved.',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
              alpha: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email address is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    return null;
  }

  void _handleForgotPassword() {
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Reset Password',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'Password reset functionality is available in the enhanced auth screen with real Supabase integration. For demo purposes, use the provided credentials above.',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _emailError = null;
      _passwordError = null;
    });

    try {
      // First try Supabase authentication with demo credential support
      final response = await AuthService.instance.signInWithDemoCredentials(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response?.user != null) {
        HapticFeedback.mediumImpact();

        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/dashboard-screen',
            (route) => false,
          );
        }
      } else {
        // Fallback to mock validation for demo purposes
        await _handleMockSignIn();
      }
    } catch (e) {
      // Fallback to mock validation if Supabase fails
      await _handleMockSignIn();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleMockSignIn() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));

    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    // Check mock credentials
    if (_mockCredentials.containsKey(email)) {
      final userCredentials = _mockCredentials[email]!;

      if (userCredentials['password'] == password) {
        // Success - trigger haptic feedback
        HapticFeedback.mediumImpact();

        // Navigate based on role
        final role = userCredentials['role']!;
        String route;

        switch (role) {
          case 'inspector':
            route = '/dashboard-screen';
            break;
          case 'admin':
          case 'manager':
            route = '/dashboard-screen'; // Admin dashboard
            break;
          default:
            route = '/dashboard-screen';
        }

        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
        }
      } else {
        // Wrong password
        setState(() {
          _passwordError = 'Incorrect password. Please try again.';
        });
        HapticFeedback.heavyImpact();
      }
    } else {
      // Email not found
      setState(() {
        _emailError = 'No account found with this email address.';
      });
      HapticFeedback.heavyImpact();
    }
  }
}
