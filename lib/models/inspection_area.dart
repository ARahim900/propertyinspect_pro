class InspectionArea {
  final String id;
  final String inspectionId;
  final String name;
  final DateTime createdAt;

  InspectionArea({
    required this.id,
    required this.inspectionId,
    required this.name,
    required this.createdAt,
  });

  factory InspectionArea.fromJson(Map<String, dynamic> json) {
    return InspectionArea(
      id: json['id'] ?? '',
      inspectionId: json['inspection_id'] ?? '',
      name: json['name'] ?? '',
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inspection_id': inspectionId,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
