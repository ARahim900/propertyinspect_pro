class Schedule {
  final String id;
  final String userId;
  final String title;
  final String clientName;
  final String? clientEmail;
  final String? clientPhone;
  final DateTime date;
  final String time;
  final int duration;
  final String priority;
  final String status;
  final String? propertyType;
  final String? propertyLocation;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Schedule({
    required this.id,
    required this.userId,
    required this.title,
    required this.clientName,
    this.clientEmail,
    this.clientPhone,
    required this.date,
    required this.time,
    required this.duration,
    required this.priority,
    required this.status,
    this.propertyType,
    this.propertyLocation,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      title: json['title'] ?? '',
      clientName: json['client_name'] ?? '',
      clientEmail: json['client_email'],
      clientPhone: json['client_phone'],
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      time: json['time'] ?? '09:00',
      duration: json['duration'] ?? 60,
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'scheduled',
      propertyType: json['property_type'],
      propertyLocation: json['property_location'],
      notes: json['notes'],
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
      'title': title,
      'client_name': clientName,
      'client_email': clientEmail,
      'client_phone': clientPhone,
      'date': date.toIso8601String().split('T')[0],
      'time': time,
      'duration': duration,
      'priority': priority,
      'status': status,
      'property_type': propertyType,
      'property_location': propertyLocation,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isScheduled => status == 'scheduled';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isHighPriority => priority == 'high';
  bool get isMediumPriority => priority == 'medium';
  bool get isLowPriority => priority == 'low';
}
