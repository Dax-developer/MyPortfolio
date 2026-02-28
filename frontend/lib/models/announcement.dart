class Announcement {
  final String id;
  final String text;
  final DateTime createdAt;

  Announcement({
    required this.id,
    required this.text,
    required this.createdAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['_id'],
      text: json['text'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
