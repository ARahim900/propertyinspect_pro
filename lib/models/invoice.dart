class Invoice {
  final String id;
  final String userId;
  final String invoiceNumber;
  final String clientName;
  final String? clientEmail;
  final String? clientPhone;
  final String propertyLocation;
  final String? propertyType;
  final double? propertyArea;
  final DateTime issueDate;
  final DateTime dueDate;
  final DateTime? inspectionDate;
  final String? inspectionId;
  final double amount;
  final double tax;
  final double totalAmount;
  final String status;
  final String? description;
  final String? notes;
  final DateTime? paymentDate;
  final String? paymentMethod;
  final DateTime createdAt;
  final DateTime updatedAt;

  Invoice({
    required this.id,
    required this.userId,
    required this.invoiceNumber,
    required this.clientName,
    this.clientEmail,
    this.clientPhone,
    required this.propertyLocation,
    this.propertyType,
    this.propertyArea,
    required this.issueDate,
    required this.dueDate,
    this.inspectionDate,
    this.inspectionId,
    required this.amount,
    required this.tax,
    required this.totalAmount,
    required this.status,
    this.description,
    this.notes,
    this.paymentDate,
    this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      invoiceNumber: json['invoice_number'] ?? '',
      clientName: json['client_name'] ?? '',
      clientEmail: json['client_email'],
      clientPhone: json['client_phone'],
      propertyLocation: json['property_location'] ?? '',
      propertyType: json['property_type'],
      propertyArea: json['property_area']?.toDouble(),
      issueDate: DateTime.parse(
          json['issue_date'] ?? DateTime.now().toIso8601String()),
      dueDate:
          DateTime.parse(json['due_date'] ?? DateTime.now().toIso8601String()),
      inspectionDate: json['inspection_date'] != null
          ? DateTime.parse(json['inspection_date'])
          : null,
      inspectionId: json['inspection_id'],
      amount: (json['amount'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'draft',
      description: json['description'],
      notes: json['notes'],
      paymentDate: json['payment_date'] != null
          ? DateTime.parse(json['payment_date'])
          : null,
      paymentMethod: json['payment_method'],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'invoice_number': invoiceNumber,
      'client_name': clientName,
      'client_email': clientEmail,
      'client_phone': clientPhone,
      'property_location': propertyLocation,
      'property_type': propertyType,
      'property_area': propertyArea,
      'issue_date': issueDate.toIso8601String().split('T')[0],
      'due_date': dueDate.toIso8601String().split('T')[0],
      'inspection_date': inspectionDate?.toIso8601String().split('T')[0],
      'inspection_id': inspectionId,
      'amount': amount,
      'tax': tax,
      'total_amount': totalAmount,
      'status': status,
      'description': description,
      'notes': notes,
      'payment_date': paymentDate?.toIso8601String().split('T')[0],
      'payment_method': paymentMethod,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isDraft => status == 'draft';
  bool get isSent => status == 'sent';
  bool get isPaid => status == 'paid';
  bool get isOverdue => status == 'overdue';
}
