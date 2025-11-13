/// Model for Heroku Release (deploy history)
class Release {
  final String id;
  final int version;
  final String? description;
  final String? status;
  final DateTime? createdAt;
  final String? slug;
  final Map<String, dynamic>? user;
  final String? outputStreamUrl;

  Release({
    required this.id,
    required this.version,
    this.description,
    this.status,
    this.createdAt,
    this.slug,
    this.user,
    this.outputStreamUrl,
  });

  factory Release.fromJson(Map<String, dynamic> json) {
    return Release(
      id: json['id'] as String,
      version: json['version'] as int,
      description: json['description'] as String?,
      status: json['status'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      slug: json['slug']?['id'] as String?,
      user: json['user'] as Map<String, dynamic>?,
      outputStreamUrl: json['output_stream_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version': version,
      'description': description,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'slug': slug,
      'user': user,
      'output_stream_url': outputStreamUrl,
    };
  }

  Release copyWith({
    String? id,
    int? version,
    String? description,
    String? status,
    DateTime? createdAt,
    String? slug,
    Map<String, dynamic>? user,
    String? outputStreamUrl,
  }) {
    return Release(
      id: id ?? this.id,
      version: version ?? this.version,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      slug: slug ?? this.slug,
      user: user ?? this.user,
      outputStreamUrl: outputStreamUrl ?? this.outputStreamUrl,
    );
  }

  /// Get user email from user object
  String? get userEmail => user?['email'] as String?;

  /// Get user name from user object
  String? get userName => user?['name'] as String?;

  /// Check if release is current (latest)
  bool get isCurrent => status == 'succeeded';
}
