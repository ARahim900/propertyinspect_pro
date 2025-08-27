import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app_export.dart';
import '../../../utils/responsive_helper.dart';

class PropertyHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> propertyData;

  const PropertyHeaderWidget({
    super.key,
    required this.propertyData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getSpacing(context, small: 16),
        vertical: ResponsiveHelper.getSpacing(context, small: 8),
      ),
      padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, small: 16)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property address and status row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      propertyData['address'] as String? ?? 'Property Address',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.ltr,
                    ),
                    SizedBox(
                        height: ResponsiveHelper.getSpacing(context, small: 4)),
                    Text(
                      '${propertyData['city'] as String? ?? 'City'}, ${propertyData['state'] as String? ?? 'State'} ${propertyData['zipCode'] as String? ?? '00000'}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                ),
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context, small: 12)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getSpacing(context, small: 12),
                  vertical: ResponsiveHelper.getSpacing(context, small: 6),
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                      propertyData['status'] as String? ?? 'pending', theme),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  (propertyData['status'] as String? ?? 'pending')
                      .toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textDirection: TextDirection.ltr,
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveHelper.getSpacing(context, small: 16)),

          // Client and scheduling info
          Container(
            padding:
                EdgeInsets.all(ResponsiveHelper.getSpacing(context, small: 12)),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                // Client info row
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(
                          ResponsiveHelper.getSpacing(context, small: 8)),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: CustomIconWidget(
                        iconName: 'person',
                        color: theme.colorScheme.primary,
                        size: ResponsiveHelper.getIconSize(context, small: 20),
                      ),
                    ),
                    SizedBox(
                        width: ResponsiveHelper.getSpacing(context, small: 12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Client',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                            textDirection: TextDirection.ltr,
                          ),
                          SizedBox(height: 2),
                          Text(
                            propertyData['clientName'] as String? ??
                                'Client Name',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textDirection: TextDirection.ltr,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _makePhoneCall(
                          propertyData['clientPhone'] as String? ?? ''),
                      child: Container(
                        padding: EdgeInsets.all(
                            ResponsiveHelper.getSpacing(context, small: 8)),
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName: 'phone',
                          color: theme.colorScheme.primary,
                          size:
                              ResponsiveHelper.getIconSize(context, small: 18),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(
                    height: ResponsiveHelper.getSpacing(context, small: 12)),

                // Scheduling info row
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(
                          ResponsiveHelper.getSpacing(context, small: 8)),
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: CustomIconWidget(
                        iconName: 'schedule',
                        color: theme.colorScheme.secondary,
                        size: ResponsiveHelper.getIconSize(context, small: 20),
                      ),
                    ),
                    SizedBox(
                        width: ResponsiveHelper.getSpacing(context, small: 12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scheduled',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                            textDirection: TextDirection.ltr,
                          ),
                          SizedBox(height: 2),
                          Text(
                            '${propertyData['scheduledDate'] as String? ?? 'Aug 26, 2025'} at ${propertyData['scheduledTime'] as String? ?? '10:00 AM'}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textDirection: TextDirection.ltr,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppTheme.successLight;
      case 'in_progress':
        return AppTheme.warningLight;
      case 'pending':
        return theme.colorScheme.secondary;
      default:
        return theme.colorScheme.primary;
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) return;

    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      // Handle error silently
    }
  }
}
