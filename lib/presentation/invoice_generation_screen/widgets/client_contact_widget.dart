import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ClientContactWidget extends StatefulWidget {
  final String clientEmail;
  final String paymentTerms;
  final Function(String) onEmailChanged;
  final Function(String) onPaymentTermsChanged;

  const ClientContactWidget({
    super.key,
    required this.clientEmail,
    required this.paymentTerms,
    required this.onEmailChanged,
    required this.onPaymentTermsChanged,
  });

  @override
  State<ClientContactWidget> createState() => _ClientContactWidgetState();
}

class _ClientContactWidgetState extends State<ClientContactWidget> {
  late TextEditingController _emailController;

  final List<String> _paymentTermsOptions = [
    'Net 15 days',
    'Net 30 days',
    'Net 45 days',
    'Net 60 days',
    'Due on receipt',
    'Due on completion',
  ];

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.clientEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'contact_mail',
                color: theme.colorScheme.primary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Client Contact & Terms',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Client Email',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.5.h),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'client@example.com',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'email',
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 5.w,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 3.w,
                    vertical: 1.5.h,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: widget.onEmailChanged,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment Terms',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.5.h),
              DropdownButtonFormField<String>(
                value: _paymentTermsOptions.contains(widget.paymentTerms)
                    ? widget.paymentTerms
                    : _paymentTermsOptions.first,
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'schedule',
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 5.w,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 3.w,
                    vertical: 1.5.h,
                  ),
                ),
                items: _paymentTermsOptions.map((String term) {
                  return DropdownMenuItem<String>(
                    value: term,
                    child: Text(
                      term,
                      style: theme.textTheme.bodyMedium,
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    widget.onPaymentTermsChanged(newValue);
                  }
                },
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _sendInvoiceEmail(context),
                  icon: CustomIconWidget(
                    iconName: 'send',
                    color: theme.colorScheme.primary,
                    size: 4.w,
                  ),
                  label: Text('Send Email'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _shareInvoice(context),
                  icon: CustomIconWidget(
                    iconName: 'share',
                    color: Colors.white,
                    size: 4.w,
                  ),
                  label: Text('Share'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _sendInvoiceEmail(BuildContext context) {
    final theme = Theme.of(context);

    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter client email address'),
          backgroundColor: theme.colorScheme.error,
        ),
      );
      return;
    }

    // Simulate email sending
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: Colors.white,
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Text('Invoice sent to ${_emailController.text}'),
          ],
        ),
        backgroundColor: AppTheme.successLight,
      ),
    );
  }

  void _shareInvoice(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share Invoice',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'email',
                color: theme.colorScheme.primary,
                size: 6.w,
              ),
              title: Text('Email'),
              onTap: () {
                Navigator.pop(context);
                _sendInvoiceEmail(context);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'message',
                color: theme.colorScheme.primary,
                size: 6.w,
              ),
              title: Text('Message'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening messaging app...')),
                );
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'file_copy',
                color: theme.colorScheme.primary,
                size: 6.w,
              ),
              title: Text('Copy Link'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Invoice link copied to clipboard')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
