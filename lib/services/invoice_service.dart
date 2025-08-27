import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/invoice.dart';
import './auth_service.dart';
import './supabase_service.dart';

class InvoiceService {
  static InvoiceService? _instance;
  static InvoiceService get instance => _instance ??= InvoiceService._();

  InvoiceService._();

  final SupabaseClient _client = SupabaseService.instance.client;

  // Get all invoices for current user
  Future<List<Invoice>> getInvoices() async {
    final user = AuthService.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final response = await _client
          .from('invoices')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return response.map((json) => Invoice.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to get invoices: $error');
    }
  }

  // Get invoice by ID
  Future<Invoice> getInvoiceById(String id) async {
    try {
      final response =
          await _client.from('invoices').select().eq('id', id).single();

      return Invoice.fromJson(response);
    } catch (error) {
      throw Exception('Failed to get invoice: $error');
    }
  }

  // Create new invoice
  Future<Invoice> createInvoice(Map<String, dynamic> data) async {
    final user = AuthService.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    data['user_id'] = user.id;

    // Generate invoice number if not provided
    if (!data.containsKey('invoice_number') || data['invoice_number'] == null) {
      data['invoice_number'] = await _generateInvoiceNumber();
    }

    try {
      final response =
          await _client.from('invoices').insert(data).select().single();

      return Invoice.fromJson(response);
    } catch (error) {
      throw Exception('Failed to create invoice: $error');
    }
  }

  // Update invoice
  Future<Invoice> updateInvoice(String id, Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from('invoices')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return Invoice.fromJson(response);
    } catch (error) {
      throw Exception('Failed to update invoice: $error');
    }
  }

  // Delete invoice
  Future<void> deleteInvoice(String id) async {
    try {
      await _client.from('invoices').delete().eq('id', id);
    } catch (error) {
      throw Exception('Failed to delete invoice: $error');
    }
  }

  // Get invoice services
  Future<List<InvoiceServiceModel>> getInvoiceServices(String invoiceId) async {
    try {
      final response = await _client
          .from('invoice_services')
          .select()
          .eq('invoice_id', invoiceId)
          .order('created_at', ascending: true);

      return response
          .map((json) => InvoiceServiceModel.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to get invoice services: $error');
    }
  }

  // Add service to invoice
  Future<InvoiceServiceModel> addInvoiceService(
      Map<String, dynamic> data) async {
    try {
      // Calculate amount if not provided
      if (!data.containsKey('amount')) {
        final quantity = (data['quantity'] ?? 1).toDouble();
        final rate = (data['rate'] ?? 0).toDouble();
        data['amount'] = quantity * rate;
      }

      final response =
          await _client.from('invoice_services').insert(data).select().single();

      // Update invoice totals
      await _updateInvoiceTotals(data['invoice_id']);

      return InvoiceServiceModel.fromJson(response);
    } catch (error) {
      throw Exception('Failed to add invoice service: $error');
    }
  }

  // Update invoice service
  Future<InvoiceServiceModel> updateInvoiceService(
      String id, Map<String, dynamic> data) async {
    try {
      // Calculate amount if quantity or rate changed
      if (data.containsKey('quantity') || data.containsKey('rate')) {
        final service = await _getInvoiceServiceById(id);
        final quantity = (data['quantity'] ?? service.quantity).toDouble();
        final rate = (data['rate'] ?? service.rate).toDouble();
        data['amount'] = quantity * rate;
      }

      final response = await _client
          .from('invoice_services')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      final service = InvoiceServiceModel.fromJson(response);

      // Update invoice totals
      await _updateInvoiceTotals(service.invoiceId);

      return service;
    } catch (error) {
      throw Exception('Failed to update invoice service: $error');
    }
  }

  // Delete invoice service
  Future<void> deleteInvoiceService(String id) async {
    try {
      final service = await _getInvoiceServiceById(id);

      await _client.from('invoice_services').delete().eq('id', id);

      // Update invoice totals
      await _updateInvoiceTotals(service.invoiceId);
    } catch (error) {
      throw Exception('Failed to delete invoice service: $error');
    }
  }

  // Filter invoices by status
  Future<List<Invoice>> getInvoicesByStatus(String status) async {
    final user = AuthService.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final response = await _client
          .from('invoices')
          .select()
          .eq('user_id', user.id)
          .eq('status', status)
          .order('created_at', ascending: false);

      return response.map((json) => Invoice.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to get invoices by status: $error');
    }
  }

  // Mark invoice as sent
  Future<Invoice> markAsSent(String id) async {
    return await updateInvoice(id, {'status': 'sent'});
  }

  // Mark invoice as paid
  Future<Invoice> markAsPaid(String id,
      {String? paymentMethod, DateTime? paymentDate}) async {
    final data = {
      'status': 'paid',
      'payment_date':
          (paymentDate ?? DateTime.now()).toIso8601String().split('T')[0],
    };

    if (paymentMethod != null) {
      data['payment_method'] = paymentMethod;
    }

    return await updateInvoice(id, data);
  }

  // Get invoice statistics for dashboard
  Future<Map<String, dynamic>> getInvoiceStats() async {
    final user = AuthService.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final allInvoices = await getInvoices();

      double totalAmount = 0;
      double paidAmount = 0;
      double pendingAmount = 0;
      int draftCount = 0;
      int sentCount = 0;
      int paidCount = 0;
      int overdueCount = 0;

      for (final invoice in allInvoices) {
        totalAmount += invoice.totalAmount;

        switch (invoice.status) {
          case 'draft':
            draftCount++;
            break;
          case 'sent':
            sentCount++;
            pendingAmount += invoice.totalAmount;
            break;
          case 'paid':
            paidCount++;
            paidAmount += invoice.totalAmount;
            break;
          case 'overdue':
            overdueCount++;
            pendingAmount += invoice.totalAmount;
            break;
        }
      }

      return {
        'totalInvoices': allInvoices.length,
        'totalAmount': totalAmount,
        'paidAmount': paidAmount,
        'pendingAmount': pendingAmount,
        'draftCount': draftCount,
        'sentCount': sentCount,
        'paidCount': paidCount,
        'overdueCount': overdueCount,
      };
    } catch (error) {
      throw Exception('Failed to get invoice stats: $error');
    }
  }

  // Private methods
  Future<String> _generateInvoiceNumber() async {
    final user = AuthService.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');

    try {
      final count = await _client
          .from('invoices')
          .select()
          .eq('user_id', user.id)
          .count();

      final invoiceNumber =
          'INV-$year$month-${(count.count + 1).toString().padLeft(3, '0')}';
      return invoiceNumber;
    } catch (error) {
      final timestamp = now.millisecondsSinceEpoch.toString().substring(8);
      return 'INV-$year$month-$timestamp';
    }
  }

  Future<InvoiceServiceModel> _getInvoiceServiceById(String id) async {
    final response =
        await _client.from('invoice_services').select().eq('id', id).single();

    return InvoiceServiceModel.fromJson(response);
  }

  Future<void> _updateInvoiceTotals(String invoiceId) async {
    try {
      final services = await getInvoiceServices(invoiceId);
      final subtotal =
          services.fold<double>(0, (sum, service) => sum + service.amount);

      final invoice = await getInvoiceById(invoiceId);
      final taxRate = invoice.tax > 0
          ? invoice.tax / (invoice.amount > 0 ? invoice.amount : 1)
          : 0.0;
      final tax = subtotal * taxRate;
      final total = subtotal + tax;

      await updateInvoice(invoiceId, {
        'amount': subtotal,
        'tax': tax,
        'total_amount': total,
      });
    } catch (error) {
      // Ignore errors in total calculation
    }
  }
}

// Rename to avoid conflict
class InvoiceServiceModel {
  final String id;
  final String invoiceId;
  final String description;
  final double quantity;
  final double rate;
  final double amount;
  final DateTime createdAt;

  InvoiceServiceModel({
    required this.id,
    required this.invoiceId,
    required this.description,
    required this.quantity,
    required this.rate,
    required this.amount,
    required this.createdAt,
  });

  factory InvoiceServiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceServiceModel(
      id: json['id'] ?? '',
      invoiceId: json['invoice_id'] ?? '',
      description: json['description'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      rate: (json['rate'] ?? 0).toDouble(),
      amount: (json['amount'] ?? 0).toDouble(),
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'description': description,
      'quantity': quantity,
      'rate': rate,
      'amount': amount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
