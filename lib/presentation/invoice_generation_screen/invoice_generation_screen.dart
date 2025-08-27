import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
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
  // Mock data for client and property information
  final Map<String, dynamic> _clientData = {
    'name': 'Sarah Johnson',
    'email': 'sarah.johnson@email.com',
    'phone': '+1 (555) 123-4567',
    'company': 'Johnson Properties LLC',
  };

  final Map<String, dynamic> _propertyData = {
    'address': '1234 Oak Street, Springfield, IL 62701',
    'type': 'Single Family Home',
    'size': '2,400 sq ft',
    'bedrooms': 4,
    'bathrooms': 3,
  };

  final String _inspectionDate = '08/25/2025';

  // Invoice data
  List<Map<String, dynamic>> _services = [];
  double _taxPercentage = 8.25;
  InvoiceStatus _invoiceStatus = InvoiceStatus.draft;
  String _clientEmail = 'sarah.johnson@email.com';
  String _paymentTerms = 'Net 30 days';
  DateTime? _sentDate;
  DateTime? _paidDate;

  @override
  void initState() {
    super.initState();
    _initializeDefaultServices();
  }

  void _initializeDefaultServices() {
    _services = [
      {
        'id': 1,
        'description':
            'Comprehensive property inspection including structural, electrical, and plumbing assessment',
        'quantity': 1.0,
        'rate': 150.0,
        'subtotal': 150.0,
      },
    ];
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
          Text('Due Date: ${_paymentTerms}'),
          SizedBox(height: 2.h),
          Text(
            'Bill To:',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(_clientData['name'] as String),
          Text(_clientData['company'] as String),
          Text(_clientEmail),
          SizedBox(height: 1.h),
          Text(
            'Property:',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(_propertyData['address'] as String),
          Text('Inspection Date: $_inspectionDate'),
        ],
      ),
    );
  }

  Widget _buildPreviewServices(ThemeData theme) {
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
            'Services',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 1.h),
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
                            '\$${(service['rate'] as double).toStringAsFixed(2)}',
                            style: theme.textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '\$${(service['subtotal'] as double).toStringAsFixed(2)}',
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
      padding: EdgeInsets.all(3.w),
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
              Text('\$${_subtotal.toStringAsFixed(2)}',
                  style: theme.textTheme.bodyMedium),
            ],
          ),
          SizedBox(height: 0.5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tax (${_taxPercentage.toStringAsFixed(2)}%):',
                  style: theme.textTheme.bodyMedium),
              Text('\$${_taxAmount.toStringAsFixed(2)}',
                  style: theme.textTheme.bodyMedium),
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
                '\$${_totalAmount.toStringAsFixed(2)}',
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

  void _saveDraft() {
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'save',
              color: Colors.white,
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Text('Invoice draft saved successfully'),
          ],
        ),
        backgroundColor: AppTheme.successLight,
      ),
    );
  }

  void _createAnotherInvoice() {
    setState(() {
      _services.clear();
      _initializeDefaultServices();
      _taxPercentage = 8.25;
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Generate Invoice',
        variant: CustomAppBarVariant.withActions,
        actions: [
          IconButton(
            onPressed: _saveDraft,
            icon: CustomIconWidget(
              iconName: 'save',
              color: theme.colorScheme.onSurface,
              size: 6.w,
            ),
            tooltip: 'Save Draft',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InvoiceHeaderWidget(
                    clientData: _clientData,
                    propertyData: _propertyData,
                    inspectionDate: _inspectionDate,
                  ),
                  SizedBox(height: 3.h),
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
                          size: 4.w,
                        ),
                        label: Text('Add Service'),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  if (_services.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          CustomIconWidget(
                            iconName: 'receipt_long',
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.4),
                            size: 12.w,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'No services added yet',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Tap "Add Service" to get started',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
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
                  SizedBox(height: 3.h),
                  TaxCalculationWidget(
                    subtotal: _subtotal,
                    taxPercentage: _taxPercentage,
                    onTaxPercentageChanged: _updateTaxPercentage,
                  ),
                  SizedBox(height: 3.h),
                  InvoiceStatusWidget(
                    currentStatus: _invoiceStatus,
                    onStatusChanged: _updateInvoiceStatus,
                    sentDate: _sentDate,
                    paidDate: _paidDate,
                  ),
                  SizedBox(height: 3.h),
                  ClientContactWidget(
                    clientEmail: _clientEmail,
                    paymentTerms: _paymentTerms,
                    onEmailChanged: _updateClientEmail,
                    onPaymentTermsChanged: _updatePaymentTerms,
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _createAnotherInvoice,
                          child: Text('New Invoice'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _previewInvoice,
                          child: Text('Preview'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                ],
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
          size: 5.w,
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
}
