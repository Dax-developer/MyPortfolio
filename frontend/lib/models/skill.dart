class Skill {
  final String id;
  final String name;
  final String? level;

  Skill({required this.id, required this.name, this.level});

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
        id: json['_id'] ?? json['id'] ?? '',
        name: json['name'] ?? '',
        level: json['level'],
      );
}
