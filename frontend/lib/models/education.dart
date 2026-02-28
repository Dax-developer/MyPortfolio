class Education {
  final String id;
  final String institution;
  final String degree;
  final String year;
  final String? grade;
  final String? certificateUrl;

  Education({
    required this.id,
    required this.institution,
    required this.degree,
    required this.year,
    this.grade,
    this.certificateUrl,
  });

  factory Education.fromJson(Map<String, dynamic> json) => Education(
    id: json['_id'] ?? json['id'] ?? '',
    institution: json['institution'] ?? '',
    degree: json['degree'] ?? '',
    year: json['year'] ?? '',
    grade: json['grade'],
    certificateUrl: json['certificateUrl'],
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Education && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
