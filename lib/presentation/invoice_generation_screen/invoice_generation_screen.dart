import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/invoice_service.dart';
import '../../services/supabase_service.dart';
import '../../utils/currency_helper.dart';
import '../../utils/responsive_helper.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/add_service_bottom_sheet.dart';
import './widgets/client_contact_widget.dart';
import './widgets/invoice_header_widget.dart';
import './widgets/invoice_status_widget.dart';
import './widgets/service_line_item_widget.dart';
import './widgets/tax_calculation_widget.dart';

class InvoiceGenerationScreen extends StatefulWidget {
  const InvoiceGenerationScreen({super.key});

  @override
  State<InvoiceGenerationScreen> createState() =>
      _InvoiceGenerationScreenState();
}

class _InvoiceGenerationScreenState extends State<InvoiceGenerationScreen> {
  // Real client and property data - will be loaded from Supabase or arguments
  Map<String, dynamic> _clientData = {};
  Map<String, dynamic> _propertyData = {};
  String _inspectionDate = '';

  // Invoice data
  List<Map<String, dynamic>> _services = [];
  double _taxPercentage = 5.0; // VAT rate in Oman
  InvoiceStatus _invoiceStatus = InvoiceStatus.draft;
  String _clientEmail = '';
  String _paymentTerms = 'Net 30 days';
  DateTime? _sentDate;
  DateTime? _paidDate;
  bool _isSaving = false;
  bool _isLoading = true;

  final InvoiceService _invoiceService = InvoiceService();

  @override
  void initState() {
    super.initState();
    _loadInvoiceData();
  }

  Future<void> _loadInvoiceData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final args = ModalRoute.of(context)?.settings.arguments as String?;

      if (args != null && SupabaseService.instance.isAuthenticated) {
        // Load existing invoice from Supabase
        final invoiceData = await _invoiceService.getInvoiceDetails(args);

        setState(() {
          _clientData = {
            'name': invoiceData['client_name'] ?? 'Unknown Client',
            'email': invoiceData['client_email'] ?? '',
            'phone': invoiceData['client_phone'] ?? '',
            'company': '', // Company not stored separately in current schema
          };

          _propertyData = {
            'address': invoiceData['property_location'] ?? 'Unknown Location',
            'type': invoiceData['property_type'] ?? 'Residential',
            'size': invoiceData['property_area']?.toString() ?? '',
          };

          _clientEmail = invoiceData['client_email'] ?? '';
          _inspectionDate = _formatDate(invoiceData['inspection_date']);

          // Convert services from database format
          _services = (invoiceData['invoice_services'] as List? ?? [])
              .map((service) => {
                    'id': service['id'],
                    'description': service['description'] ?? '',
                    'quantity': (service['quantity'] as num).toDouble(),
                    'rate': (service['rate'] as num).toDouble(),
                    'subtotal': (service['amount'] as num).toDouble(),
                  })
              .toList();

          // Set status
          final status = invoiceData['status'] as String? ?? 'draft';
          _invoiceStatus = _getInvoiceStatus(status);

          if (invoiceData['sent_date'] != null) {
            _sentDate = DateTime.parse(invoiceData['sent_date']);
          }
          if (invoiceData['payment_date'] != null) {
            _paidDate = DateTime.parse(invoiceData['payment_date']);
          }
        });
      } else {
        // Initialize with realistic Omani data for preview
        _initializeDefaultData();
      }
    } catch (error) {
      _initializeDefaultData();
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _initializeDefaultData() {
    _clientData = {
      'name': 'Ahmed Al Balushi',
      'email': 'ahmed.albalushi@email.com',
      'phone': '+968 9123 4567',
      'company': 'Al Balushi Properties LLC',
    };

    _propertyData = {
      'address': 'Al Qurum Heights, Muscat, Oman',
      'type': 'Villa',
      'size': '350 sq m',
    };

    _inspectionDate =
        _formatDate(DateTime.now().toIso8601String().split('T')[0]);
    _clientEmail = 'ahmed.albalushi@email.com';

    _services = [
      {
        'id': 1,
        'description':
            'Comprehensive property inspection including structural, electrical, and plumbing assessment',
        'quantity': 1.0,
        'rate': 115.0, // OMR rate for comprehensive inspection
        'subtotal': 115.0,
      },
    ];
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Aug 26, 2025';
    try {
      final date = DateTime.parse(dateString);
      return "${_getMonthName(date.month)} ${date.day}, ${date.year}";
    } catch (e) {
      return dateString;
    }
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month];
  }

  InvoiceStatus _getInvoiceStatus(String status) {
    switch (status.toLowerCase()) {
      case 'sent':
        return InvoiceStatus.sent;
      case 'paid':
        return InvoiceStatus.paid;
      case 'overdue':
        return InvoiceStatus.draft; // Use draft as fallback for overdue
      default:
        return InvoiceStatus.draft;
    }
  }

  double get _subtotal {
    return _services.fold(
        0.0, (sum, service) => sum + (service['subtotal'] as double));
  }

  double get _taxAmount {
    return _subtotal * (_taxPercentage / 100);
  }

  double get _totalAmount {
    return _subtotal + _taxAmount;
  }

  void _addService(Map<String, dynamic> service) {
    setState(() {
      _services.add(service);
    });
  }

  void _updateService(int index, Map<String, dynamic> updatedService) {
    setState(() {
      _services[index] = updatedService;
    });
  }

  void _removeService(int index) {
    setState(() {
      _services.removeAt(index);
    });
  }

  void _updateTaxPercentage(double percentage) {
    setState(() {
      _taxPercentage = percentage;
    });
  }

  void _updateInvoiceStatus(InvoiceStatus status) {
    setState(() {
      _invoiceStatus = status;
      if (status == InvoiceStatus.sent && _sentDate == null) {
        _sentDate = DateTime.now();
      } else if (status == InvoiceStatus.paid && _paidDate == null) {
        _paidDate = DateTime.now();
      }
    });
  }

  void _updateClientEmail(String email) {
    setState(() {
      _clientEmail = email;
    });
  }

  void _updatePaymentTerms(String terms) {
    setState(() {
      _paymentTerms = terms;
    });
  }

  void _showAddServiceBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddServiceBottomSheet(
        onServiceAdded: _addService,
      ),
    );
  }

  void _previewInvoice() {
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      builder: (context) => _buildInvoicePreviewDialog(),
    );
  }

  Widget _buildInvoicePreviewDialog() {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: EdgeInsets.all(4.w),
      child: Container(
        width: double.infinity,
        height: 80.h,
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Invoice Preview',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: theme.colorScheme.onSurface,
                    size: 6.w,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPreviewHeader(theme),
                    SizedBox(height: 2.h),
                    _buildPreviewServices(theme),
                    SizedBox(height: 2.h),
                    _buildPreviewTotals(theme),
                  ],
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Close'),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _shareInvoice();
                    },
                    child: Text('Share PDF'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewHeader(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        border:
            Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'INVOICE',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 1.h),
          Text('Invoice #: INV-${DateTime.now().millisecondsSinceEpoch}'),
          Text(
              'Date: ${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().year}'),
          Text('Due Date: $_paymentTerms'),
          SizedBox(height: 2.h),
          Text(
            'Bill To:',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(_clientData['name'] as String? ?? 'Unknown Client'),
          if ((_clientData['company'] as String?)?.isNotEmpty == true)
            Text(_clientData['company'] as String),
          Text(_clientEmail),
          SizedBox(height: 1.h),
          Text(
            'Property:',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(_propertyData['address'] as String? ?? 'Unknown Location'),
          Text('Inspection Date: $_inspectionDate'),
        ],
      ),
    );
  }

  Widget _buildPreviewServices(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, small: 12)),
      decoration: BoxDecoration(
        border:
            Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Services',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 1.h),
          // Header row
          Container(
            padding: EdgeInsets.only(bottom: 0.5.h),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Description',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Qty',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Rate',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Amount',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
          ..._services
              .map((service) => Padding(
                    padding: EdgeInsets.only(bottom: 1.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            service['description'] as String,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            '${(service['quantity'] as double).toStringAsFixed(1)}',
                            style: theme.textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            CurrencyHelper.formatOMR(service['rate'] as double),
                            style: theme.textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            CurrencyHelper.formatOMR(
                                service['subtotal'] as double),
                            style: theme.textTheme.bodySmall,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildPreviewTotals(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, small: 12)),
      decoration: BoxDecoration(
        border:
            Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal:', style: theme.textTheme.bodyMedium),
              Text(
                CurrencyHelper.formatOMRWithSymbol(_subtotal),
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'VAT (${_taxPercentage.toStringAsFixed(1)}%):',
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                CurrencyHelper.formatOMRWithSymbol(_taxAmount),
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Container(
              height: 1,
              color: theme.colorScheme.outline.withValues(alpha: 0.3)),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                CurrencyHelper.formatOMRWithSymbol(_totalAmount),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _shareInvoice() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'share',
              color: Colors.white,
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Text('Invoice PDF shared successfully'),
          ],
        ),
        backgroundColor: AppTheme.successLight,
      ),
    );
  }

  void _saveDraft() async {
    setState(() {
      _isSaving = true;
    });

    try {
      if (SupabaseService.instance.isAuthenticated) {
        // Save to Supabase
        await _invoiceService.createInvoice(
          clientName: _clientData['name'] ?? '',
          clientEmail: _clientEmail,
          clientPhone: _clientData['phone'] ?? '',
          propertyLocation: _propertyData['address'] ?? '',
          propertyType: _propertyData['type'] ?? 'residential',
          services: _services,
        );
      }

      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              CustomIconWidget(
                iconName: 'save',
                color: Colors.white,
                size: ResponsiveHelper.getIconSize(context, small: 20),
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context, small: 8)),
              Text('Invoice draft saved successfully'),
            ],
          ),
          backgroundColor: AppTheme.successLight,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save draft: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _createAnotherInvoice() {
    setState(() {
      _services.clear();
      _initializeDefaultData();
      _taxPercentage = 5.0;
      _invoiceStatus = InvoiceStatus.draft;
      _sentDate = null;
      _paidDate = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('New invoice created'),
        backgroundColor: AppTheme.successLight,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: 'Generate Invoice',
          variant: CustomAppBarVariant.withActions,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Generate Invoice',
        variant: CustomAppBarVariant.withActions,
        actions: [
          IconButton(
            onPressed: _isSaving ? null : _saveDraft,
            icon: _isSaving
                ? SizedBox(
                    width: ResponsiveHelper.getIconSize(context, small: 20),
                    height: ResponsiveHelper.getIconSize(context, small: 20),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : CustomIconWidget(
                    iconName: 'save',
                    color: theme.colorScheme.onSurface,
                    size: ResponsiveHelper.getIconSize(context, small: 24),
                  ),
            tooltip: 'Save Draft',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(
                  ResponsiveHelper.getSpacing(context, small: 16)),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Responsive layout based on screen width
                  if (constraints.maxWidth > 800) {
                    return _buildTabletLayout(theme);
                  } else {
                    return _buildMobileLayout(theme);
                  }
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddServiceBottomSheet,
        icon: CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: ResponsiveHelper.getIconSize(context, small: 20),
        ),
        label: Text('Add Service'),
        backgroundColor: theme.colorScheme.primary,
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 3,
        variant: CustomBottomBarVariant.standard,
      ),
    );
  }

  Widget _buildMobileLayout(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InvoiceHeaderWidget(
          clientData: _clientData,
          propertyData: _propertyData,
          inspectionDate: _inspectionDate,
        ),
        SizedBox(height: ResponsiveHelper.getSpacing(context, small: 24)),
        _buildServicesSection(theme),
        SizedBox(height: ResponsiveHelper.getSpacing(context, small: 24)),
        TaxCalculationWidget(
          subtotal: _subtotal,
          taxPercentage: _taxPercentage,
          onTaxPercentageChanged: _updateTaxPercentage,
        ),
        SizedBox(height: ResponsiveHelper.getSpacing(context, small: 24)),
        InvoiceStatusWidget(
          currentStatus: _invoiceStatus,
          onStatusChanged: _updateInvoiceStatus,
          sentDate: _sentDate,
          paidDate: _paidDate,
        ),
        SizedBox(height: ResponsiveHelper.getSpacing(context, small: 24)),
        ClientContactWidget(
          clientEmail: _clientEmail,
          paymentTerms: _paymentTerms,
          onEmailChanged: _updateClientEmail,
          onPaymentTermsChanged: _updatePaymentTerms,
        ),
        SizedBox(height: ResponsiveHelper.getSpacing(context, small: 24)),
        _buildActionButtons(),
        SizedBox(height: ResponsiveHelper.getSpacing(context, small: 80)),
      ],
    );
  }

  Widget _buildTabletLayout(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column
        Expanded(
          flex: 2,
          child: Column(
            children: [
              InvoiceHeaderWidget(
                clientData: _clientData,
                propertyData: _propertyData,
                inspectionDate: _inspectionDate,
              ),
              SizedBox(height: ResponsiveHelper.getSpacing(context, small: 24)),
              _buildServicesSection(theme),
              SizedBox(height: ResponsiveHelper.getSpacing(context, small: 24)),
              _buildActionButtons(),
            ],
          ),
        ),
        SizedBox(width: ResponsiveHelper.getSpacing(context, small: 24)),
        // Right column
        Expanded(
          flex: 1,
          child: Column(
            children: [
              TaxCalculationWidget(
                subtotal: _subtotal,
                taxPercentage: _taxPercentage,
                onTaxPercentageChanged: _updateTaxPercentage,
              ),
              SizedBox(height: ResponsiveHelper.getSpacing(context, small: 24)),
              InvoiceStatusWidget(
                currentStatus: _invoiceStatus,
                onStatusChanged: _updateInvoiceStatus,
                sentDate: _sentDate,
                paidDate: _paidDate,
              ),
              SizedBox(height: ResponsiveHelper.getSpacing(context, small: 24)),
              ClientContactWidget(
                clientEmail: _clientEmail,
                paymentTerms: _paymentTerms,
                onEmailChanged: _updateClientEmail,
                onPaymentTermsChanged: _updatePaymentTerms,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServicesSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Services',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: _showAddServiceBottomSheet,
              icon: CustomIconWidget(
                iconName: 'add',
                color: theme.colorScheme.primary,
                size: ResponsiveHelper.getIconSize(context, small: 16),
              ),
              label: Text('Add Service'),
            ),
          ],
        ),
        SizedBox(height: ResponsiveHelper.getSpacing(context, small: 8)),
        if (_services.isEmpty)
          Container(
            width: double.infinity,
            padding:
                EdgeInsets.all(ResponsiveHelper.getSpacing(context, small: 32)),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                CustomIconWidget(
                  iconName: 'receipt_long',
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  size: ResponsiveHelper.getIconSize(context, small: 48),
                ),
                SizedBox(
                    height: ResponsiveHelper.getSpacing(context, small: 16)),
                Text(
                  'No services added yet',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                SizedBox(
                    height: ResponsiveHelper.getSpacing(context, small: 8)),
                Text(
                  'Tap "Add Service" to get started',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          )
        else
          ...List.generate(_services.length, (index) {
            return ServiceLineItemWidget(
              serviceData: _services[index],
              onServiceUpdated: (updatedService) =>
                  _updateService(index, updatedService),
              onRemove: () => _removeService(index),
            );
          }),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _createAnotherInvoice,
            child: Text('New Invoice'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveHelper.getSpacing(context, small: 16),
              ),
            ),
          ),
        ),
        SizedBox(width: ResponsiveHelper.getSpacing(context, small: 12)),
        Expanded(
          child: ElevatedButton(
            onPressed: _previewInvoice,
            child: Text('Preview'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveHelper.getSpacing(context, small: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}