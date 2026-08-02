/// Heroku Add-on model
class Addon {
  final String id;
  final String name;
  final String serviceName; // e.g., "heroku-postgresql"
  final String planName; // e.g., "heroku-postgresql:hobby-dev"
  final String state; // "provisioned", "provisioning", "deprovisioned"
  final String? webUrl; // Dashboard URL
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Addon({
    required this.id,
    required this.name,
    required this.serviceName,
    required this.planName,
    required this.state,
    this.webUrl,
    this.createdAt,
    this.updatedAt,
  });

  /// Create Addon from JSON
  factory Addon.fromJson(Map<String, dynamic> json) {
    return Addon(
      id: json['id'] as String,
      name: json['name'] as String,
      serviceName: json['addon_service']['name'] as String,
      planName: json['plan']['name'] as String,
      state: json['state'] as String,
      webUrl: json['web_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert Addon to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'addon_service': {'name': serviceName},
      'plan': {'name': planName},
      'state': state,
      'web_url': webUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Copy with method for updating fields
  Addon copyWith({
    String? id,
    String? name,
    String? serviceName,
    String? planName,
    String? state,
    String? webUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Addon(
      id: id ?? this.id,
      name: name ?? this.name,
      serviceName: serviceName ?? this.serviceName,
      planName: planName ?? this.planName,
      state: state ?? this.state,
      webUrl: webUrl ?? this.webUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Addon(id: $id, name: $name, service: $serviceName, plan: $planName, state: $state)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Addon && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
