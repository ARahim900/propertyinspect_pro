import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/logout_button_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/sync_status_widget.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _inspectionReminders = true;
  bool _scheduleUpdates = true;
  bool _invoiceNotifications = false;
  bool _offlineSync = true;
  bool _highQualityPhotos = true;
  bool _metricUnits = false;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  // Mock user data
  final Map<String, dynamic> _userData = {
    "id": 1,
    "name": "Sarah Johnson",
    "role": "Senior Inspector",
    "email": "sarah.johnson@propertyinspect.com",
    "phone": "+1 (555) 123-4567",
    "company": "PropertyInspect Pro",
    "avatar":
        "https://images.unsplash.com/photo-1494790108755-2616b612b786?fm=jpg&q=60&w=400&ixlib=rb-4.0.3",
    "joinDate": "2023-01-15",
    "totalInspections": 247,
    "completionRate": 98.5,
  };

  @override
  void initState() {
    super.initState();
    _lastSyncTime = DateTime.now().subtract(const Duration(minutes: 15));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        title: 'Profile & Settings',
        variant: CustomAppBarVariant.standard,
        showBackButton: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              ProfileHeaderWidget(
                userName: _userData["name"] as String,
                userRole: _userData["role"] as String,
                avatarUrl: _userData["avatar"] as String?,
                onAvatarTap: _handleAvatarUpdate,
              ),

              SizedBox(height: 3.h),

              // Account Settings Section
              SettingsSectionWidget(
                title: 'Account Settings',
                items: [
                  SettingsItem(
                    title: 'Personal Information',
                    subtitle: 'Update your profile details',
                    icon: 'person_outline',
                    onTap: _showPersonalInfoDialog,
                  ),
                  SettingsItem(
                    title: 'Contact Information',
                    subtitle: _userData["email"] as String,
                    icon: 'email_outlined',
                    onTap: _showContactInfoDialog,
                  ),
                  SettingsItem(
                    title: 'Company Details',
                    subtitle: _userData["company"] as String,
                    icon: 'business_outlined',
                    onTap: _showCompanyDialog,
                  ),
                  SettingsItem(
                    title: 'Change Password',
                    subtitle: 'Update your account password',
                    icon: 'lock_outline',
                    onTap: _showPasswordDialog,
                  ),
                ],
              ),

              // Notification Settings Section
              SettingsSectionWidget(
                title: 'Notification Preferences',
                items: [
                  SettingsItem(
                    title: 'Push Notifications',
                    subtitle: _notificationsEnabled ? 'Enabled' : 'Disabled',
                    icon: 'notifications_outlined',
                    showDisclosure: false,
                    trailing: Switch(
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        setState(() => _notificationsEnabled = value);
                        _showSettingUpdateToast(
                            'Push notifications ${value ? 'enabled' : 'disabled'}');
                      },
                    ),
                  ),
                  SettingsItem(
                    title: 'Inspection Reminders',
                    subtitle: 'Get notified before inspections',
                    icon: 'schedule_outlined',
                    showDisclosure: false,
                    trailing: Switch(
                      value: _inspectionReminders,
                      onChanged: _notificationsEnabled
                          ? (value) {
                              HapticFeedback.lightImpact();
                              setState(() => _inspectionReminders = value);
                              _showSettingUpdateToast(
                                  'Inspection reminders ${value ? 'enabled' : 'disabled'}');
                            }
                          : null,
                    ),
                  ),
                  SettingsItem(
                    title: 'Schedule Updates',
                    subtitle: 'Notifications for schedule changes',
                    icon: 'update_outlined',
                    showDisclosure: false,
                    trailing: Switch(
                      value: _scheduleUpdates,
                      onChanged: _notificationsEnabled
                          ? (value) {
                              HapticFeedback.lightImpact();
                              setState(() => _scheduleUpdates = value);
                              _showSettingUpdateToast(
                                  'Schedule updates ${value ? 'enabled' : 'disabled'}');
                            }
                          : null,
                    ),
                  ),
                  SettingsItem(
                    title: 'Invoice Notifications',
                    subtitle: 'Payment and invoice updates',
                    icon: 'receipt_outlined',
                    showDisclosure: false,
                    trailing: Switch(
                      value: _invoiceNotifications,
                      onChanged: _notificationsEnabled
                          ? (value) {
                              HapticFeedback.lightImpact();
                              setState(() => _invoiceNotifications = value);
                              _showSettingUpdateToast(
                                  'Invoice notifications ${value ? 'enabled' : 'disabled'}');
                            }
                          : null,
                    ),
                  ),
                ],
              ),

              // App Settings Section
              SettingsSectionWidget(
                title: 'App Settings',
                items: [
                  SettingsItem(
                    title: 'Offline Sync',
                    subtitle: 'Automatic data synchronization',
                    icon: 'sync_outlined',
                    showDisclosure: false,
                    trailing: Switch(
                      value: _offlineSync,
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        setState(() => _offlineSync = value);
                        _showSettingUpdateToast(
                            'Offline sync ${value ? 'enabled' : 'disabled'}');
                      },
                    ),
                  ),
                  SettingsItem(
                    title: 'Photo Quality',
                    subtitle: _highQualityPhotos
                        ? 'High Quality'
                        : 'Standard Quality',
                    icon: 'photo_camera_outlined',
                    showDisclosure: false,
                    trailing: Switch(
                      value: _highQualityPhotos,
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        setState(() => _highQualityPhotos = value);
                        _showSettingUpdateToast(
                            'Photo quality set to ${value ? 'high' : 'standard'}');
                      },
                    ),
                  ),
                  SettingsItem(
                    title: 'Measurement Units',
                    subtitle:
                        _metricUnits ? 'Metric (m, kg)' : 'Imperial (ft, lbs)',
                    icon: 'straighten_outlined',
                    showDisclosure: false,
                    trailing: Switch(
                      value: _metricUnits,
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        setState(() => _metricUnits = value);
                        _showSettingUpdateToast(
                            'Units changed to ${value ? 'metric' : 'imperial'}');
                      },
                    ),
                  ),
                ],
              ),

              // Data Sync Status
              SyncStatusWidget(
                lastSyncTime: _lastSyncTime,
                isSyncing: _isSyncing,
                onManualSync: _performManualSync,
              ),

              // Support Section
              SettingsSectionWidget(
                title: 'Support & Information',
                items: [
                  SettingsItem(
                    title: 'Help & FAQ',
                    subtitle: 'Get help and find answers',
                    icon: 'help_outline',
                    onTap: _showHelpDialog,
                  ),
                  SettingsItem(
                    title: 'Contact Support',
                    subtitle: 'Get in touch with our team',
                    icon: 'support_agent_outlined',
                    onTap: _showContactSupportDialog,
                  ),
                  SettingsItem(
                    title: 'App Version',
                    subtitle: 'Version 2.1.0 (Build 2025082601)',
                    icon: 'info_outline',
                    onTap: _showAppInfoDialog,
                  ),
                ],
              ),

              // Logout Button
              LogoutButtonWidget(
                onLogout: _handleLogout,
              ),

              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomBar(
        currentIndex: 4, // Profile tab index
        variant: CustomBottomBarVariant.standard,
      ),
    );
  }

  void _handleAvatarUpdate() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4.w)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 1.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.w),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Update Profile Photo',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPhotoOption(
                  context,
                  'Camera',
                  'camera_alt',
                  () => _updateProfilePhoto('camera'),
                ),
                _buildPhotoOption(
                  context,
                  'Gallery',
                  'photo_library',
                  () => _updateProfilePhoto('gallery'),
                ),
                _buildPhotoOption(
                  context,
                  'Remove',
                  'delete_outline',
                  () => _updateProfilePhoto('remove'),
                ),
              ],
            ),
            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoOption(
      BuildContext context, String title, String icon, VoidCallback onTap) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(3.w),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: icon,
              size: 6.w,
              color: theme.colorScheme.primary,
            ),
            SizedBox(height: 1.h),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateProfilePhoto(String source) {
    String message = '';
    switch (source) {
      case 'camera':
        message = 'Photo captured and updated successfully';
        break;
      case 'gallery':
        message = 'Photo selected and updated successfully';
        break;
      case 'remove':
        message = 'Profile photo removed';
        break;
    }

    _showSettingUpdateToast(message);
  }

  void _showPersonalInfoDialog() {
    final theme = Theme.of(context);
    final nameController =
        TextEditingController(text: _userData["name"] as String);
    final roleController =
        TextEditingController(text: _userData["role"] as String);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.w)),
        title: Text(
          'Personal Information',
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: roleController,
              decoration: const InputDecoration(
                labelText: 'Job Title',
                prefixIcon: Icon(Icons.work_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSettingUpdateToast('Personal information updated');
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showContactInfoDialog() {
    final theme = Theme.of(context);
    final emailController =
        TextEditingController(text: _userData["email"] as String);
    final phoneController =
        TextEditingController(text: _userData["phone"] as String);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.w)),
        title: Text(
          'Contact Information',
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSettingUpdateToast('Contact information updated');
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showCompanyDialog() {
    final theme = Theme.of(context);
    final companyController =
        TextEditingController(text: _userData["company"] as String);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.w)),
        title: Text(
          'Company Details',
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: companyController,
          decoration: const InputDecoration(
            labelText: 'Company Name',
            prefixIcon: Icon(Icons.business_outlined),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSettingUpdateToast('Company details updated');
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showPasswordDialog() {
    final theme = Theme.of(context);
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.w)),
        title: Text(
          'Change Password',
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: 'New Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSettingUpdateToast('Password updated successfully');
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _performManualSync() {
    setState(() => _isSyncing = true);

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isSyncing = false;
          _lastSyncTime = DateTime.now();
        });
        _showSettingUpdateToast('Data synchronized successfully');
      }
    });
  }

  void _showHelpDialog() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.w)),
        title: Text(
          'Help & FAQ',
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Frequently Asked Questions:',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 2.h),
            _buildFAQItem('How do I sync my data?',
                'Use the manual sync button or enable automatic sync in settings.'),
            _buildFAQItem('How do I update my profile?',
                'Tap on your profile picture or use the account settings section.'),
            _buildFAQItem('How do I change notifications?',
                'Use the notification preferences section to customize alerts.'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 0.5.h),
          Text(
            answer,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactSupportDialog() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.w)),
        title: Text(
          'Contact Support',
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildContactOption('Email Support', 'support@propertyinspect.com',
                'email_outlined'),
            SizedBox(height: 2.h),
            _buildContactOption(
                'Phone Support', '+1 (800) 123-4567', 'phone_outlined'),
            SizedBox(height: 2.h),
            _buildContactOption(
                'Live Chat', 'Available 9 AM - 6 PM EST', 'chat_outlined'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption(String title, String subtitle, String icon) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: icon,
            size: 5.w,
            color: theme.colorScheme.primary,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAppInfoDialog() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.w)),
        title: Text(
          'App Information',
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'mobile_friendly',
              size: 15.w,
              color: theme.colorScheme.primary,
            ),
            SizedBox(height: 2.h),
            Text(
              'PropertyInspect Pro',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 1.h),
            Text(
              'Version 2.1.0 (Build 2025082601)',
              style: theme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            Text(
              'Professional property inspection management with offline capabilities and real-time synchronization.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSettingUpdateToast('Checking for updates...');
            },
            child: Text('Check for Updates'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    // Additional logout logic can be implemented here
    // Such as clearing local storage, canceling subscriptions, etc.
  }

  void _showSettingUpdateToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              size: 4.w,
              color: Colors.white,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.w),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
