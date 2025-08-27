import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/inspection.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final _signInFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();

  // Sign In Controllers
  final _signInEmailController = TextEditingController();
  final _signInPasswordController = TextEditingController();

  // Sign Up Controllers
  final _signUpEmailController = TextEditingController();
  final _signUpPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  bool _isSignInPasswordVisible = false;
  bool _isSignUpPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
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
                child: Column(
                  children: [
                    SizedBox(height: 6.h),
                    _buildLogo(),
                    SizedBox(height: 4.h),
                    _buildTabBar(),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6.w),
                        child: TabBarView(
                          controller: _tabController,
                          children: [_buildSignInView(), _buildSignUpView()],
                        ),
                      ),
                    ),
                    _buildFooter(),
                    SizedBox(height: 4.h),
                  ],
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
          width: 18.w,
          height: 18.w,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.primary,
            borderRadius: BorderRadius.circular(3.w),
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
            size: 7.w,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          'PropertyInspect Pro',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 0.5.h),
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

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary,
          borderRadius: BorderRadius.circular(1.5.w),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.lightTheme.colorScheme.onSurface
            .withValues(alpha: 0.7),
        labelStyle: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTheme.lightTheme.textTheme.labelLarge,
        tabs: const [Tab(text: 'Sign In'), Tab(text: 'Sign Up')],
        onTap: (index) {
          setState(() {
            _errorMessage = null;
          });
        },
      ),
    );
  }

  Widget _buildSignInView() {
    return Padding(
      padding: EdgeInsets.only(top: 4.h),
      child: Form(
        key: _signInFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back',
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
            SizedBox(height: 3.h),
            if (_errorMessage != null) _buildErrorMessage(),
            _buildEmailField(
              _signInEmailController,
              'Email Address',
              'Enter your email address',
            ),
            SizedBox(height: 2.5.h),
            _buildPasswordField(
              _signInPasswordController,
              'Password',
              'Enter your password',
              _isSignInPasswordVisible,
              (value) => setState(() => _isSignInPasswordVisible = value),
              onFieldSubmitted: (_) => _handleSignIn(),
            ),
            SizedBox(height: 1.5.h),
            _buildForgotPasswordLink(),
            SizedBox(height: 3.h),
            _buildActionButton('Sign In', _handleSignIn),
            SizedBox(height: 3.h),
            _buildDemoCredentialsInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpView() {
    return Padding(
      padding: EdgeInsets.only(top: 4.h),
      child: Form(
        key: _signUpFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Account',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Sign up to get started with PropertyInspect Pro',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
            SizedBox(height: 3.h),
            if (_errorMessage != null) _buildErrorMessage(),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _firstNameController,
                    'First Name',
                    'Enter first name',
                    'person',
                    validator: _validateName,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: _buildTextField(
                    _lastNameController,
                    'Last Name',
                    'Enter last name',
                    'person',
                    validator: _validateName,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.5.h),
            _buildEmailField(
              _signUpEmailController,
              'Email Address',
              'Enter your email address',
            ),
            SizedBox(height: 2.5.h),
            _buildPasswordField(
              _signUpPasswordController,
              'Password',
              'Create a password',
              _isSignUpPasswordVisible,
              (value) => setState(() => _isSignUpPasswordVisible = value),
            ),
            SizedBox(height: 2.5.h),
            _buildPasswordField(
              _confirmPasswordController,
              'Confirm Password',
              'Confirm your password',
              _isConfirmPasswordVisible,
              (value) => setState(() => _isConfirmPasswordVisible = value),
              validator: _validateConfirmPassword,
            ),
            SizedBox(height: 3.h),
            _buildActionButton('Create Account', _handleSignUp),
            SizedBox(height: 2.h),
            _buildTermsText(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'error',
            color: AppTheme.lightTheme.colorScheme.error,
            size: 4.w,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              _errorMessage!,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField(
    TextEditingController controller,
    String label,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'email',
                color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                  alpha: 0.6,
                ),
                size: 4.5.w,
              ),
            ),
            errorMaxLines: 2,
          ),
          onChanged: (value) {
            if (_errorMessage != null) {
              setState(() => _errorMessage = null);
            }
          },
          validator: _validateEmail,
        ),
      ],
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String label,
    String hint,
    bool isVisible,
    Function(bool) onVisibilityChanged, {
    Function(String)? onFieldSubmitted,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: controller,
          obscureText: !isVisible,
          textInputAction:
              onFieldSubmitted != null
                  ? TextInputAction.done
                  : TextInputAction.next,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'lock',
                color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                  alpha: 0.6,
                ),
                size: 4.5.w,
              ),
            ),
            suffixIcon: IconButton(
              onPressed:
                  _isLoading ? null : () => onVisibilityChanged(!isVisible),
              icon: CustomIconWidget(
                iconName: isVisible ? 'visibility_off' : 'visibility',
                color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                  alpha: 0.6,
                ),
                size: 4.5.w,
              ),
            ),
            errorMaxLines: 2,
          ),
          onChanged: (value) {
            if (_errorMessage != null) {
              setState(() => _errorMessage = null);
            }
          },
          onFieldSubmitted: onFieldSubmitted,
          validator: validator ?? _validatePassword,
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
    String iconName, {
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: controller,
          textInputAction: TextInputAction.next,
          enabled: !_isLoading,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: iconName,
                color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                  alpha: 0.6,
                ),
                size: 4.5.w,
              ),
            ),
            errorMaxLines: 2,
          ),
          onChanged: (value) {
            if (_errorMessage != null) {
              setState(() => _errorMessage = null);
            }
          },
          validator: validator,
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

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
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
                  text,
                  style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }

  Widget _buildDemoCredentialsInfo() {
    return Container(
      width: double.infinity,
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
                'Development Mode',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'You can create a new account or use demo credentials for testing. Real authentication is powered by Supabase.',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                alpha: 0.7,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsText() {
    return Text(
      'By creating an account, you agree to our Terms of Service and Privacy Policy.',
      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
        color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Secure Authentication • Data Encrypted',
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

  // Validation methods
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

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters long';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != _signUpPasswordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Action handlers
  Future<void> _handleSignIn() async {
    if (!_signInFormKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await AuthService.instance.signIn(
        email: _signInEmailController.text.trim(),
        password: _signInPasswordController.text,
      );

      if (response.user != null) {
        HapticFeedback.mediumImpact();

        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.dashboard,
            (route) => false,
          );
        }
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      setState(() {
        _errorMessage = _getErrorMessage(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSignUp() async {
    if (!_signUpFormKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await AuthService.instance.signUp(
        email: _signUpEmailController.text.trim(),
        password: _signUpPasswordController.text,
      );

      if (response.user != null) {
        HapticFeedback.mediumImpact();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Account created successfully! Please check your email to verify your account.',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(4.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.w),
              ),
            ),
          );

          // Switch to sign in tab
          _tabController.animateTo(0);

          // Pre-fill email in sign in form
          _signInEmailController.text = _signUpEmailController.text;

          // Clear sign up form
          _signUpEmailController.clear();
          _signUpPasswordController.clear();
          _confirmPasswordController.clear();
          _firstNameController.clear();
          _lastNameController.clear();
        }
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      setState(() {
        _errorMessage = _getErrorMessage(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleForgotPassword() {
    HapticFeedback.lightImpact();

    final emailController = TextEditingController();

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
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Enter your email address and we\'ll send you a link to reset your password.',
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
                SizedBox(height: 2.h),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'Enter your email address',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                      alpha: 0.6,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (emailController.text.trim().isNotEmpty) {
                    try {
                      await AuthService.instance.resetPassword(
                        emailController.text.trim(),
                      );

                      if (context.mounted) {
                        Navigator.of(context).pop();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Password reset link sent to ${emailController.text.trim()}',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                            backgroundColor:
                                AppTheme.lightTheme.colorScheme.primary,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Failed to send reset email. Please try again.',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                            backgroundColor:
                                AppTheme.lightTheme.colorScheme.error,
                          ),
                        );
                      }
                    }
                  }
                },
                child: Text(
                  'Send Reset Link',
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

  String _getErrorMessage(String error) {
    if (error.contains('Invalid login credentials')) {
      return 'Invalid email or password. Please check your credentials and try again.';
    } else if (error.contains('User already registered')) {
      return 'An account with this email already exists. Please sign in instead.';
    } else if (error.contains('Invalid email')) {
      return 'Please enter a valid email address.';
    } else if (error.contains('Password should be at least 6 characters')) {
      return 'Password must be at least 6 characters long.';
    } else if (error.contains('Network request failed')) {
      return 'Network error. Please check your connection and try again.';
    } else {
      return 'Something went wrong. Please try again later.';
    }
  }
}
