/// Heroku Formation model (dyno formation for scaling)
class Formation {
  final String id;
  final String type;
  final int quantity;
  final String size;
  final String? command;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String appId;
  final String? appName;

  Formation({
    required this.id,
    required this.type,
    required this.quantity,
    required this.size,
    this.command,
    this.createdAt,
    this.updatedAt,
    required this.appId,
    this.appName,
  });

  /// Create Formation from JSON
  factory Formation.fromJson(Map<String, dynamic> json) {
    return Formation(
      id: json['id'] as String,
      type: json['type'] as String,
      quantity: json['quantity'] as int,
      size: json['size'] as String,
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

  /// Convert Formation to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'quantity': quantity,
      'size': size,
      'command': command,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'app': {'id': appId, 'name': appName},
    };
  }

  /// Copy with method for updating fields
  Formation copyWith({
    String? id,
    String? type,
    int? quantity,
    String? size,
    String? command,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? appId,
    String? appName,
  }) {
    return Formation(
      id: id ?? this.id,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      size: size ?? this.size,
      command: command ?? this.command,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      appId: appId ?? this.appId,
      appName: appName ?? this.appName,
    );
  }

  /// Check if formation is scaled (quantity > 0)
  bool get isScaled => quantity > 0;

  /// Get human-readable description
  String get description => '$type: $quantity × $size';

  @override
  String toString() {
    return 'Formation(type: $type, quantity: $quantity, size: $size)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Formation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
