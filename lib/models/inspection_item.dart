class InspectionItem {
  final String id;
  final String areaId;
  final String point;
  final List<String> photos;
  final String? status;
  final String category;
  final String? comments;
  final String? location;
  final DateTime createdAt;

  InspectionItem({
    required this.id,
    required this.areaId,
    required this.point,
    required this.photos,
    this.status,
    required this.category,
    this.comments,
    this.location,
    required this.createdAt,
  });

  factory InspectionItem.fromJson(Map<String, dynamic> json) {
    return InspectionItem(
      id: json['id'] ?? '',
      areaId: json['area_id'] ?? '',
      point: json['point'] ?? '',
      photos: List<String>.from(json['photos'] ?? []),
      status: json['status'],
      category: json['category'] ?? '',
      comments: json['comments'],
      location: json['location'],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'area_id': areaId,
      'point': point,
      'photos': photos,
      'status': status,
      'category': category,
      'comments': comments,
      'location': location,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isPassing => status?.toLowerCase() == 'pass';
  bool get isFailing => status?.toLowerCase() == 'fail';
  bool get isNotApplicable => status?.toLowerCase() == 'n/a';
}
