import '../utils/currency_helper.dart';
import './supabase_service.dart';

class InvoiceService {
  final SupabaseService _supabase = SupabaseService.instance;

  // Get invoices for current user
  Future<List<Map<String, dynamic>>> getUserInvoices({
    int? limit,
    String? status,
  }) async {
    try {
      var query = _supabase.client
          .from('invoices')
          .select('*, invoice_services(*)')
          .eq('user_id', _supabase.currentUserId!);

      if (status != null) {
        query = query.eq('status', status);
      }

      var orderedQuery = query.order('created_at', ascending: false);

      if (limit != null) {
        return await orderedQuery.limit(limit);
      }

      return await orderedQuery;
    } catch (error) {
      throw Exception('Failed to load invoices: $error');
    }
  }

  // Get single invoice with services
  Future<Map<String, dynamic>> getInvoiceDetails(String invoiceId) async {
    try {
      final response = await _supabase.client
          .from('invoices')
          .select('*, invoice_services(*)')
          .eq('id', invoiceId)
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to load invoice details: $error');
    }
  }

  // Create new invoice
  Future<Map<String, dynamic>> createInvoice({
    required String clientName,
    required String clientEmail,
    String? clientPhone,
    required String propertyLocation,
    String? propertyType,
    String? inspectionId,
    DateTime? inspectionDate,
    List<Map<String, dynamic>>? services,
  }) async {
    try {
      // Generate unique invoice number
      final invoiceNumber = 'INV-${DateTime.now().millisecondsSinceEpoch}';

      final invoiceData = {
        'user_id': _supabase.currentUserId,
        'invoice_number': invoiceNumber,
        'client_name': clientName,
        'client_email': clientEmail,
        'client_phone': clientPhone,
        'property_location': propertyLocation,
        'property_type': propertyType ?? 'residential',
        'inspection_id': inspectionId,
        'inspection_date': inspectionDate?.toIso8601String().split('T')[0],
        'issue_date': DateTime.now().toIso8601String().split('T')[0],
        'due_date': DateTime.now()
            .add(Duration(days: 30))
            .toIso8601String()
            .split('T')[0],
        'status': 'draft',
        'amount': 0.0,
        'tax': 0.0,
        'total_amount': 0.0,
      };

      final invoice = await _supabase.client
          .from('invoices')
          .insert(invoiceData)
          .select()
          .single();

      // Add services if provided
      if (services != null && services.isNotEmpty) {
        await addInvoiceServices(invoice['id'], services);
      }

      return invoice;
    } catch (error) {
      throw Exception('Failed to create invoice: $error');
    }
  }

  // Add services to invoice
  Future<void> addInvoiceServices(
      String invoiceId, List<Map<String, dynamic>> services) async {
    try {
      final serviceData = services
          .map((service) => {
                'invoice_id': invoiceId,
                'description': service['description'],
                'quantity': service['quantity'] ?? 1.0,
                'rate': service['rate'] ?? 0.0,
                'amount':
                    (service['quantity'] ?? 1.0) * (service['rate'] ?? 0.0),
              })
          .toList();

      await _supabase.client.from('invoice_services').insert(serviceData);

      // Update invoice totals
      await _updateInvoiceTotals(invoiceId);
    } catch (error) {
      throw Exception('Failed to add invoice services: $error');
    }
  }

  // Update invoice service
  Future<void> updateInvoiceService(
    String serviceId, {
    String? description,
    double? quantity,
    double? rate,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (description != null) updateData['description'] = description;
      if (quantity != null) updateData['quantity'] = quantity;
      if (rate != null) updateData['rate'] = rate;

      // Calculate amount if quantity or rate changed
      if (quantity != null || rate != null) {
        final service = await _supabase.client
            .from('invoice_services')
            .select('quantity, rate')
            .eq('id', serviceId)
            .single();

        final newQuantity = quantity ?? service['quantity'];
        final newRate = rate ?? service['rate'];
        updateData['amount'] = newQuantity * newRate;
      }

      await _supabase.client
          .from('invoice_services')
          .update(updateData)
          .eq('id', serviceId);

      // Update invoice totals
      final service = await _supabase.client
          .from('invoice_services')
          .select('invoice_id')
          .eq('id', serviceId)
          .single();

      await _updateInvoiceTotals(service['invoice_id']);
    } catch (error) {
      throw Exception('Failed to update invoice service: $error');
    }
  }

  // Delete invoice service
  Future<void> deleteInvoiceService(String serviceId) async {
    try {
      final service = await _supabase.client
          .from('invoice_services')
          .select('invoice_id')
          .eq('id', serviceId)
          .single();

      await _supabase.client
          .from('invoice_services')
          .delete()
          .eq('id', serviceId);

      // Update invoice totals
      await _updateInvoiceTotals(service['invoice_id']);
    } catch (error) {
      throw Exception('Failed to delete invoice service: $error');
    }
  }

  // Update invoice totals based on services
  Future<void> _updateInvoiceTotals(String invoiceId) async {
    try {
      final services = await _supabase.client
          .from('invoice_services')
          .select('amount')
          .eq('invoice_id', invoiceId);

      final subtotal = services.fold<double>(
          0.0, (sum, service) => sum + (service['amount'] as num).toDouble());

      // Calculate tax (using 5% VAT for Oman)
      const taxRate = 0.05;
      final tax = subtotal * taxRate;
      final total = subtotal + tax;

      await _supabase.client.from('invoices').update({
        'amount': subtotal,
        'tax': tax,
        'total_amount': total,
      }).eq('id', invoiceId);
    } catch (error) {
      throw Exception('Failed to update invoice totals: $error');
    }
  }

  // Update invoice status
  Future<void> updateInvoiceStatus(String invoiceId, String status) async {
    try {
      final updateData = {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (status == 'sent') {
        updateData['sent_date'] =
            DateTime.now().toIso8601String().split('T')[0];
      } else if (status == 'paid') {
        updateData['payment_date'] =
            DateTime.now().toIso8601String().split('T')[0];
      }

      await _supabase.client
          .from('invoices')
          .update(updateData)
          .eq('id', invoiceId);
    } catch (error) {
      throw Exception('Failed to update invoice status: $error');
    }
  }

  // Generate invoice from inspection
  Future<Map<String, dynamic>> generateInvoiceFromInspection(
      String inspectionId) async {
    try {
      final inspection = await _supabase.client
          .from('inspections')
          .select('*')
          .eq('id', inspectionId)
          .single();

      // Create invoice with inspection data
      final invoice = await createInvoice(
        clientName: inspection['client_name'] ?? 'Unknown Client',
        clientEmail: '', // Will need to be filled by user
        propertyLocation: inspection['property_location'],
        propertyType: inspection['property_type'],
        inspectionId: inspectionId,
        inspectionDate: DateTime.parse(inspection['inspection_date']),
        services: [
          {
            'description':
                'Property Inspection - ${inspection['property_type']}',
            'quantity': 1.0,
            'rate': 58.0, // Default rate in OMR (converted from $150)
          }
        ],
      );

      return invoice;
    } catch (error) {
      throw Exception('Failed to generate invoice from inspection: $error');
    }
  }

  // Format currency for display
  String formatCurrency(double amount) {
    return CurrencyHelper.formatOMRWithSymbol(amount);
  }

  // Convert USD to OMR
  double convertToOMR(double usdAmount) {
    return CurrencyHelper.convertUSDToOMR(usdAmount);
  }
}