/// Heroku log session model
class LogSession {
  final String id;
  final String logplexUrl;
  final DateTime createdAt;

  LogSession({
    required this.id,
    required this.logplexUrl,
    required this.createdAt,
  });

  /// Create LogSession from JSON
  factory LogSession.fromJson(Map<String, dynamic> json) {
    return LogSession(
      id: json['id'] as String,
      logplexUrl: json['logplex_url'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert LogSession to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'logplex_url': logplexUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'LogSession(id: $id, url: $logplexUrl, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LogSession && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
