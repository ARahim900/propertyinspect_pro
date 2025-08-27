class Inspection {
  final String id;
  final String userId;
  final String? clientName;
  final String propertyType;
  final String inspectorName;
  final DateTime inspectionDate;
  final String propertyLocation;
  final DateTime createdAt;
  final DateTime updatedAt;

  Inspection({
    required this.id,
    required this.userId,
    this.clientName,
    required this.propertyType,
    required this.inspectorName,
    required this.inspectionDate,
    required this.propertyLocation,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Inspection.fromJson(Map<String, dynamic> json) {
    return Inspection(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      clientName: json['client_name'],
      propertyType: json['property_type'] ?? '',
      inspectorName: json['inspector_name'] ?? '',
      inspectionDate: DateTime.parse(
          json['inspection_date'] ?? DateTime.now().toIso8601String()),
      propertyLocation: json['property_location'] ?? '',
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
      'client_name': clientName,
      'property_type': propertyType,
      'inspector_name': inspectorName,
      'inspection_date': inspectionDate.toIso8601String().split('T')[0],
      'property_location': propertyLocation,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
