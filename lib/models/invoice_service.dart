class InvoiceService {
  final String id;
  final String invoiceId;
  final String description;
  final double quantity;
  final double rate;
  final double amount;
  final DateTime createdAt;

  InvoiceService({
    required this.id,
    required this.invoiceId,
    required this.description,
    required this.quantity,
    required this.rate,
    required this.amount,
    required this.createdAt,
  });

  factory InvoiceService.fromJson(Map<String, dynamic> json) {
    return InvoiceService(
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
