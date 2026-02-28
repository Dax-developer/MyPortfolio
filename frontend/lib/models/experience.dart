class Experience {
  final String id;
  final String company;
  final String position;
  final String description;
  final List<String> technologies;
  final String startDate;
  final String? endDate;
  final bool isCurrently;

  Experience({
    required this.id,
    required this.company,
    required this.position,
    required this.description,
    required this.technologies,
    required this.startDate,
    this.endDate,
    required this.isCurrently,
  });

  factory Experience.fromJson(Map<String, dynamic> json) => Experience(
    id: json['_id'] ?? json['id'] ?? '',
    company: json['company'] ?? '',
    position: json['position'] ?? '',
    description: json['description'] ?? '',
    technologies: List<String>.from(json['technologies'] ?? []),
    startDate: json['startDate'] ?? '',
    endDate: json['endDate'],
    isCurrently: json['isCurrently'] ?? false,
  );
}
