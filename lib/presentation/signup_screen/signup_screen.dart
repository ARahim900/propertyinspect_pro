import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../mixins/validation_mixin.dart';
import '../../utils/validation_helper.dart';
import '../../services/error_service.dart';
import '../../services/performance_service.dart';
import '../../services/crash_reporting_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _companyController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _acceptTerms = false;
  String _selectedRole = 'staff';

  final List<String> _roles = ['staff', 'inspector', 'manager'];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),
                  _buildHeader(),
                  SizedBox(height: 4.h),
                  _buildSignUpForm(),
                  SizedBox(height: 4.h),
                  _buildSignUpButton(),
                  SizedBox(height: 3.h),
                  _buildSignInLink(),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Account',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Join PropertyInspect Pro and start managing your property inspections professionally',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name fields row
          Row(
            children: [
              Expanded(
                child: _buildFirstNameField(),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildLastNameField(),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          
          _buildEmailField(),
          SizedBox(height: 3.h),
          
          _buildCompanyField(),
          SizedBox(height: 3.h),
          
          _buildRoleField(),
          SizedBox(height: 3.h),
          
          _buildPasswordField(),
          SizedBox(height: 3.h),
          
          _buildConfirmPasswordField(),
          SizedBox(height: 3.h),
          
          _buildTermsCheckbox(),
        ],
      ),
    );
  }

  Widget _buildFirstNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'First Name',
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        buildValidatedTextField(
          fieldName: 'firstName',
          controller: _firstNameController,
          labelText: '',
          validators: [
            (value) => ValidationHelper.validateRequired(value, 'First name'),
            (value) => ValidationHelper.validateLength(value, 'First name', minLength: 2),
          ],
          enabled: !_isLoading,
          hintText: 'First name',
        ),
      ],
    );
  }

  Widget _buildLastNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last Name',
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        buildValidatedTextField(
          fieldName: 'lastName',
          controller: _lastNameController,
          labelText: '',
          validators: [
            (value) => ValidationHelper.validateRequired(value, 'Last name'),
            (value) => ValidationHelper.validateLength(value, 'Last name', minLength: 2),
          ],
          enabled: !_isLoading,
          hintText: 'Last name',
        ),
      ],
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

  Widget _buildCompanyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Company (Optional)',
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        buildValidatedTextField(
          fieldName: 'company',
          controller: _companyController,
          labelText: '',
          validators: [], // Optional field
          enabled: !_isLoading,
          hintText: 'Company name',
          prefixIcon: Padding(
            padding: EdgeInsets.all(3.w),
            child: CustomIconWidget(
              iconName: 'business',
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
              size: 5.w,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Role',
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        buildValidatedDropdown<String>(
          fieldName: 'role',
          value: _selectedRole,
          items: _roles.map((role) => DropdownMenuItem(
            value: role,
            child: Text(role.substring(0, 1).toUpperCase() + role.substring(1)),
          )).toList(),
          labelText: '',
          validators: [
            (value) => ValidationHelper.validateRequired(value, 'Role'),
          ],
          onChanged: (value) {
            setState(() {
              _selectedRole = value ?? 'staff';
            });
          },
          enabled: !_isLoading,
          hintText: 'Select your role',
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
            (value) => ValidationHelper.validateLength(value, 'Password', minLength: 8),
            (value) => _validatePasswordStrength(value),
          ],
          obscureText: !_isPasswordVisible,
          enabled: !_isLoading,
          hintText: 'Create a strong password',
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

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirm Password',
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        buildValidatedTextField(
          fieldName: 'confirmPassword',
          controller: _confirmPasswordController,
          labelText: '',
          validators: [
            (value) => ValidationHelper.validateRequired(value, 'Confirm password'),
            (value) => _validatePasswordMatch(value),
          ],
          obscureText: !_isConfirmPasswordVisible,
          enabled: !_isLoading,
          hintText: 'Confirm your password',
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
                    setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
                  },
            icon: CustomIconWidget(
              iconName: _isConfirmPasswordVisible ? 'visibility_off' : 'visibility',
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
              size: 5.w,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: _isLoading ? null : (value) {
            setState(() {
              _acceptTerms = value ?? false;
            });
          },
        ),
        Expanded(
          child: GestureDetector(
            onTap: _isLoading ? null : () {
              setState(() {
                _acceptTerms = !_acceptTerms;
              });
            },
            child: Padding(
              padding: EdgeInsets.only(top: 1.5.h),
              child: RichText(
                text: TextSpan(
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                  ),
                  children: [
                    const TextSpan(text: 'I agree to the '),
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: ElevatedButton(
        onPressed: (_isLoading || !_acceptTerms) ? null : _handleSignUp,
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
                'Create Account',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildSignInLink() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.7),
          ),
          children: [
            const TextSpan(text: 'Already have an account? '),
            WidgetSpan(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  'Sign In',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validatePasswordStrength(String? value) {
    if (value == null || value.isEmpty) return null;
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    
    bool hasUppercase = value.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = value.contains(RegExp(r'[a-z]'));
    bool hasDigits = value.contains(RegExp(r'[0-9]'));
    
    if (!hasUppercase || !hasLowercase || !hasDigits) {
      return 'Password must contain uppercase, lowercase, and numbers';
    }
    
    return null;
  }

  String? _validatePasswordMatch(String? value) {
    if (value == null || value.isEmpty) return null;
    
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  Future<void> _handleSignUp() async {
    PerformanceService.instance.startOperation('user_signup');
    
    // Validate form using ValidationMixin
    final formData = {
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'email': _emailController.text,
      'company': _companyController.text,
      'role': _selectedRole,
      'password': _passwordController.text,
      'confirmPassword': _confirmPasswordController.text,
    };
    
    final fieldValidators = {
      'firstName': [
        (String? value) => ValidationHelper.validateRequired(value, 'First name'),
        (String? value) => ValidationHelper.validateLength(value, 'First name', minLength: 2),
      ],
      'lastName': [
        (String? value) => ValidationHelper.validateRequired(value, 'Last name'),
        (String? value) => ValidationHelper.validateLength(value, 'Last name', minLength: 2),
      ],
      'email': [
        (String? value) => ValidationHelper.validateRequired(value, 'Email'),
        (String? value) => ValidationHelper.isValidEmail(value ?? '') ? null : 'Please enter a valid email address',
      ],
      'role': [
        (String? value) => ValidationHelper.validateRequired(value, 'Role'),
      ],
      'password': [
        (String? value) => ValidationHelper.validateRequired(value, 'Password'),
        (String? value) => ValidationHelper.validateLength(value, 'Password', minLength: 8),
        (String? value) => _validatePasswordStrength(value),
      ],
      'confirmPassword': [
        (String? value) => ValidationHelper.validateRequired(value, 'Confirm password'),
        (String? value) => _validatePasswordMatch(value),
      ],
    };
    
    if (!validateForm(formData, fieldValidators)) {
      PerformanceService.instance.endOperation('user_signup');
      showValidationSummary(context);
      return;
    }

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please accept the Terms of Service and Privacy Policy'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(4.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.w),
          ),
        ),
      );
      PerformanceService.instance.endOperation('user_signup');
      return;
    }

    FocusScope.of(context).unfocus();
    clearValidationErrors();

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 2000));

      // Success - trigger haptic feedback
      HapticFeedback.mediumImpact();
      
      // Track successful signup
      PerformanceService.instance.trackUserAction('signup_success', parameters: {
        'user_role': _selectedRole,
        'signup_method': 'email_password',
      });

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: AppTheme.successLight,
                  size: 6.w,
                ),
                SizedBox(width: 2.w),
                const Text('Account Created!'),
              ],
            ),
            content: const Text(
              'Your account has been created successfully. You can now sign in with your credentials.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to login
                },
                child: const Text('Sign In Now'),
              ),
            ],
          ),
        );
      }
    } catch (e, stackTrace) {
      // Network or other error
      ErrorService.instance.logError(
        'Signup failed',
        error: e,
        stackTrace: stackTrace,
        context: {'email': _emailController.text},
      );
      
      await CrashReportingService.instance.recordError(
        e,
        stackTrace,
        reason: 'Signup error',
        context: {'email': _emailController.text},
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
      PerformanceService.instance.endOperation('user_signup');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}