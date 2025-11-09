/// Heroku Dyno model
class Dyno {
  final String id;
  final String name;
  final String type;
  final String state;
  final String? size;
  final String? command;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String appId;
  final String? appName;

  Dyno({
    required this.id,
    required this.name,
    required this.type,
    required this.state,
    this.size,
    this.command,
    this.createdAt,
    this.updatedAt,
    required this.appId,
    this.appName,
  });

  /// Create Dyno from JSON
  factory Dyno.fromJson(Map<String, dynamic> json) {
    return Dyno(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      state: json['state'] as String,
      size: json['size'] as String?,
      command: json['command'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      appId: json['app']?['id'] as String? ?? '',
      appName: json['app']?['name'] as String?,
    );
  }

  /// Convert Dyno to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'state': state,
      'size': size,
      'command': command,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'app': {'id': appId, 'name': appName},
    };
  }

  /// Check if dyno is running
  bool get isRunning => state.toLowerCase() == 'up';

  /// Check if dyno is idle
  bool get isIdle => state.toLowerCase() == 'idle';

  /// Check if dyno is down
  bool get isDown => state.toLowerCase() == 'down';

  /// Get status color based on state
  String get statusColor {
    switch (state.toLowerCase()) {
      case 'up':
        return 'green';
      case 'idle':
        return 'yellow';
      case 'down':
        return 'red';
      default:
        return 'gray';
    }
  }

  @override
  String toString() {
    return 'Dyno(id: $id, name: $name, type: $type, state: $state)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Dyno && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
