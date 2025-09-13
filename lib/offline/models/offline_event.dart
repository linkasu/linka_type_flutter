class OfflineEvent {
  final String id;
  final String event;
  final Map<String, dynamic>? data;
  final String createdAt;
  final bool isSent;

  OfflineEvent({
    required this.id,
    required this.event,
    this.data,
    required this.createdAt,
    required this.isSent,
  });

  factory OfflineEvent.fromJson(Map<String, dynamic> json) {
    return OfflineEvent(
      id: json['id'] as String,
      event: json['event'] as String,
      data: json['data'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] as String,
      isSent: json['isSent'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event': event,
      'data': data,
      'createdAt': createdAt,
      'isSent': isSent,
    };
  }

  OfflineEvent copyWith({
    String? id,
    String? event,
    Map<String, dynamic>? data,
    String? createdAt,
    bool? isSent,
  }) {
    return OfflineEvent(
      id: id ?? this.id,
      event: event ?? this.event,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      isSent: isSent ?? this.isSent,
    );
  }

  @override
  String toString() {
    return 'OfflineEvent(id: $id, event: $event, data: $data, createdAt: $createdAt, isSent: $isSent)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OfflineEvent &&
        other.id == id &&
        other.event == event &&
        other.data == data &&
        other.createdAt == createdAt &&
        other.isSent == isSent;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        event.hashCode ^
        data.hashCode ^
        createdAt.hashCode ^
        isSent.hashCode;
  }
}
