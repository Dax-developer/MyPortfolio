class Project {
  final String id;
  final String title;
  final String description;
  final String? url;
  final String? githubUrl;
  final String? role;
  final List<String> tech;

  Project({
    required this.id,
    required this.title,
    required this.description,
    this.url,
    this.githubUrl,
    this.role,
    required this.tech,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['_id'] ?? json['id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        url: json['url'],
        githubUrl: json['githubUrl'],
        role: json['role'],
        tech: List<String>.from(json['tech'] ?? []),
      );
}
