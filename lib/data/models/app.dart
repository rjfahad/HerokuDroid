/// Heroku App model
class App {
  final String id;
  final String name;
  final String? region;
  final String? stack;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? webUrl;
  final String? gitUrl;
  final bool? maintenance;
  final String? buildpackProvidedDescription;
  final Map<String, dynamic>? owner;

  // Dyno formation summary (optional, loaded separately)
  final int? totalDynos;
  final int? runningDynos;

  App({
    required this.id,
    required this.name,
    this.region,
    this.stack,
    this.createdAt,
    this.updatedAt,
    this.webUrl,
    this.gitUrl,
    this.maintenance,
    this.buildpackProvidedDescription,
    this.owner,
    this.totalDynos,
    this.runningDynos,
  });

  /// Create App from JSON
  factory App.fromJson(Map<String, dynamic> json) {
    return App(
      id: json['id'] as String,
      name: json['name'] as String,
      region: json['region']?['name'] as String?,
      stack: json['stack']?['name'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      webUrl: json['web_url'] as String?,
      gitUrl: json['git_url'] as String?,
      maintenance: json['maintenance'] as bool?,
      buildpackProvidedDescription:
          json['buildpack_provided_description'] as String?,
      owner: json['owner'] as Map<String, dynamic>?,
    );
  }

  /// Convert App to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'region': region != null ? {'name': region} : null,
      'stack': stack != null ? {'name': stack} : null,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'web_url': webUrl,
      'git_url': gitUrl,
      'maintenance': maintenance,
      'buildpack_provided_description': buildpackProvidedDescription,
      'owner': owner,
    };
  }

  /// Copy with method for updating fields
  App copyWith({
    String? id,
    String? name,
    String? region,
    String? stack,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? webUrl,
    String? gitUrl,
    bool? maintenance,
    String? buildpackProvidedDescription,
    Map<String, dynamic>? owner,
    int? totalDynos,
    int? runningDynos,
  }) {
    return App(
      id: id ?? this.id,
      name: name ?? this.name,
      region: region ?? this.region,
      stack: stack ?? this.stack,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      webUrl: webUrl ?? this.webUrl,
      gitUrl: gitUrl ?? this.gitUrl,
      maintenance: maintenance ?? this.maintenance,
      buildpackProvidedDescription:
          buildpackProvidedDescription ?? this.buildpackProvidedDescription,
      owner: owner ?? this.owner,
      totalDynos: totalDynos ?? this.totalDynos,
      runningDynos: runningDynos ?? this.runningDynos,
    );
  }

  @override
  String toString() {
    return 'App(id: $id, name: $name, region: $region, maintenance: $maintenance)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is App && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
