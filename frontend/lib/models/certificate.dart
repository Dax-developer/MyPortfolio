class Certificate {
  final String id;
  final String name;
  final String? description;
  final String fileUrl;
  final DateTime createdAt;

  Certificate({
    required this.id,
    required this.name,
    this.description,
    required this.fileUrl,
    required this.createdAt,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      fileUrl: json['fileUrl'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
