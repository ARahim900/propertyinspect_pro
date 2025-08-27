import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../mixins/validation_mixin.dart';
import '../../utils/validation_helper.dart';
import '../../services/error_service.dart';
import '../../services/performance_service.dart';
import '../../services/crash_reporting_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _showDemoCredentials = false;
  String? _emailError;
  String? _passwordError;

  // Mock credentials for different user types
  final Map<String, Map<String, String>> _mockCredentials = {
    'inspector@propertyinspect.com': {
      'password': 'inspector123',
      'role': 'inspector',
      'name': 'John Inspector'
    },
    'admin@propertyinspect.com': {
      'password': 'admin123',
      'role': 'admin',
      'name': 'Sarah Admin'
    },
    'manager@propertyinspect.com': {
      'password': 'manager123',
      'role': 'manager',
      'name': 'Mike Manager'
    }
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
                minHeight: MediaQuery.of(context).size.height -
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
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.3),
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
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.7),
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
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 4.h),
          _buildEmailField(),
          SizedBox(height: 3.h),
          _buildPasswordField(),
          SizedBox(height: 2.h),
          _buildForgotPasswordLink(),
          SizedBox(height: 4.h),
          _buildAuthButtons(),
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
        buildValidatedTextField(
          fieldName: 'email',
          controller: _emailController,
          labelText: '',
          validators: [
            (value) => ValidationHelper.validateRequired(value, 'Email'),
            (value) => ValidationHelper.isValidEmail(value ?? '') ? null : 'Please enter a valid email address',
          ],
          keyboardType: TextInputType.emailAddress,
          enabled: !_isLoading,
          hintText: 'Enter your email address',
          prefixIcon: Padding(
            padding: EdgeInsets.all(3.w),
            child: CustomIconWidget(
              iconName: 'email',
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
              size: 5.w,
            ),
          ),
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
        buildValidatedTextField(
          fieldName: 'password',
          controller: _passwordController,
          labelText: '',
          validators: [
            (value) => ValidationHelper.validateRequired(value, 'Password'),
            (value) => ValidationHelper.validateLength(value, 'Password', minLength: 6),
          ],
          obscureText: !_isPasswordVisible,
          enabled: !_isLoading,
          hintText: 'Enter your password',
          prefixIcon: Padding(
            padding: EdgeInsets.all(3.w),
            child: CustomIconWidget(
              iconName: 'lock',
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
              size: 5.w,
            ),
          ),
          suffixIcon: IconButton(
            onPressed: _isLoading
                ? null
                : () {
                    setState(() => _isPasswordVisible = !_isPasswordVisible);
                  },
            icon: CustomIconWidget(
              iconName: _isPasswordVisible ? 'visibility_off' : 'visibility',
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
              size: 5.w,
            ),
          ),
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

  Widget _buildAuthButtons() {
    return Column(
      children: [
        // Sign In Button
        SizedBox(
          width: double.infinity,
          height: 6.h,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSignIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 2,
              shadowColor:
                  AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.w),
              ),
            ),
            child: _isLoading
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
        ),
        
        SizedBox(height: 2.h),
        
        // Divider with "OR"
        Row(
          children: [
            Expanded(
              child: Divider(
                color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
                thickness: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'OR',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
                thickness: 1,
              ),
            ),
          ],
        ),
        
        SizedBox(height: 2.h),
        
        // Sign Up Button
        SizedBox(
          width: double.infinity,
          height: 6.h,
          child: OutlinedButton(
            onPressed: _isLoading ? null : _navigateToSignUp,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.lightTheme.colorScheme.primary,
              side: BorderSide(
                color: AppTheme.lightTheme.colorScheme.primary,
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.w),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'person_add',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 5.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Create New Account',
                  style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDemoCredentials() {
    return Container(
      width: double.infinity,
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
          // Header with toggle button
          InkWell(
            onTap: () {
              setState(() {
                _showDemoCredentials = !_showDemoCredentials;
              });
              HapticFeedback.lightImpact();
            },
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(2.w),
              bottom: _showDemoCredentials ? Radius.zero : Radius.circular(2.w),
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(1.w),
                    ),
                    child: CustomIconWidget(
                      iconName: 'info',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 4.w,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Demo Credentials',
                          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'Tap to ${_showDemoCredentials ? 'hide' : 'view'} test accounts',
                          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _showDemoCredentials ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: CustomIconWidget(
                      iconName: 'keyboard_arrow_down',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 6.w,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Expandable content
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _showDemoCredentials ? null : 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _showDemoCredentials ? 1.0 : 0.0,
              child: _showDemoCredentials ? Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(
                      color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
                      height: 1,
                    ),
                    SizedBox(height: 2.h),
                    
                    // Instructions
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(1.5.w),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'touch_app',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 4.w,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              'Tap any credential below to auto-fill the login form',
                              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 2.h),
                    
                    // Credentials list
                    _buildCredentialRow('Inspector', 'inspector@propertyinspect.com', 'inspector123', 'Conduct property inspections'),
                    SizedBox(height: 1.h),
                    _buildCredentialRow('Admin', 'admin@propertyinspect.com', 'admin123', 'Full system access'),
                    SizedBox(height: 1.h),
                    _buildCredentialRow('Manager', 'manager@propertyinspect.com', 'manager123', 'Team management'),
                  ],
                ),
              ) : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialRow(String role, String email, String password, String description) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _emailController.text = email;
          _passwordController.text = password;
          clearValidationErrors();
          HapticFeedback.lightImpact();
          
          // Show feedback
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$role credentials loaded'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(4.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.w),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(2.w),
        child: Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(2.w),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(1.5.w),
                    decoration: BoxDecoration(
                      color: _getRoleColor(role).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(1.w),
                    ),
                    child: CustomIconWidget(
                      iconName: _getRoleIcon(role),
                      color: _getRoleColor(role),
                      size: 4.w,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          role,
                          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          description,
                          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  CustomIconWidget(
                    iconName: 'arrow_forward_ios',
                    color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.6),
                    size: 4.w,
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(1.w),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Email: ',
                          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            email,
                            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface,
                              fontFamily: 'monospace',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        Text(
                          'Password: ',
                          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                        Text(
                          password,
                          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Secure Login • Data Encrypted',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.6),
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          '© 2025 PropertyInspect Pro. All rights reserved.',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email address is required';
    }

    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
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
      builder: (context) => AlertDialog(
        title: Text(
          'Reset Password',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Password reset functionality will be implemented with Supabase authentication. For demo purposes, use the provided credentials above.',
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
    PerformanceService.instance.startOperation('user_login');
    
    // Validate form using ValidationMixin
    final formData = {
      'email': _emailController.text,
      'password': _passwordController.text,
    };
    
    final fieldValidators = {
      'email': [
        (String? value) => ValidationHelper.validateRequired(value, 'Email'),
        (String? value) => ValidationHelper.isValidEmail(value ?? '') ? null : 'Please enter a valid email address',
      ],
      'password': [
        (String? value) => ValidationHelper.validateRequired(value, 'Password'),
        (String? value) => ValidationHelper.validateLength(value, 'Password', minLength: 6),
      ],
    };
    
    if (!validateForm(formData, fieldValidators)) {
      PerformanceService.instance.endOperation('user_login');
      showValidationSummary(context);
      return;
    }

    FocusScope.of(context).unfocus();
    clearValidationErrors();

    setState(() {
      _isLoading = true;
      _emailError = null;
      _passwordError = null;
    });

    try {
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
          
          // Set user context for crash reporting
          await CrashReportingService.instance.setUserId(email);
          await CrashReportingService.instance.setCustomKey('user_role', userCredentials['role']!);
          
          // Track successful login
          PerformanceService.instance.trackUserAction('login_success', parameters: {
            'user_role': userCredentials['role'],
            'login_method': 'email_password',
          });

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
            Navigator.pushNamedAndRemoveUntil(
              context,
              route,
              (route) => false,
            );
          }
        } else {
          // Wrong password
          setFieldError('password', 'Incorrect password. Please try again.');
          
          PerformanceService.instance.trackUserAction('login_failed', parameters: {
            'reason': 'wrong_password',
          });
          
          HapticFeedback.heavyImpact();
        }
      } else {
        // Email not found
        setFieldError('email', 'No account found with this email address.');
        
        PerformanceService.instance.trackUserAction('login_failed', parameters: {
          'reason': 'email_not_found',
        });
        
        HapticFeedback.heavyImpact();
      }
    } catch (e, stackTrace) {
      // Network or other error
      ErrorService.instance.logError(
        'Login failed',
        error: e,
        stackTrace: stackTrace,
        context: {'email': email},
      );
      
      await CrashReportingService.instance.recordError(
        e,
        stackTrace,
        reason: 'Login error',
        context: {'email': email},
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ErrorService.instance.formatApiError(e),
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(4.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2.w),
            ),
          ),
        );
      }
      HapticFeedback.heavyImpact();
    } finally {
      PerformanceService.instance.endOperation('user_login');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
