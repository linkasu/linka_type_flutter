class Event {
  final String id;
  final String userId;
  final String event;
  final String? data;
  final String createdAt;

  Event({
    required this.id,
    required this.userId,
    required this.event,
    this.data,
    required this.createdAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      userId: json['userId'] as String,
      event: json['event'] as String,
      data: json['data'] as String?,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'event': event,
      'data': data,
      'createdAt': createdAt,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'event': event,
      'data': data,
    };
  }

  @override
  String toString() {
    return 'Event(id: $id, userId: $userId, event: $event, data: $data, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Event &&
        other.id == id &&
        other.userId == userId &&
        other.event == event &&
        other.data == data &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        event.hashCode ^
        data.hashCode ^
        createdAt.hashCode;
  }
}
