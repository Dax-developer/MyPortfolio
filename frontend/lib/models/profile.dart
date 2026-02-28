class Profile {
  final String id;
  final String? name;
  final String? title;
  final String? bio;
  final String? photoUrl;
  final String? resumeUrl;
  final String? email;
  final String? phone;
  final String? location;
  final String? heroSkills;
  final List<String>? socialLinks;
  final String? footerBrandName;
  final String? footerTagline;
  final String? footerEmail;
  final String? footerLocation;
  final String? footerLinkedIn;
  final String? footerGitHub;
  final String? footerInstagram;
  final String? footerWhatsApp;
  final String? footerCopyright;
  final String? footerCredit;

  Profile({
    required this.id,
    this.name,
    this.title,
    this.bio,
    this.photoUrl,
    this.resumeUrl,
    this.email,
    this.phone,
    this.location,
    this.heroSkills,
    this.socialLinks,
    this.footerBrandName,
    this.footerTagline,
    this.footerEmail,
    this.footerLocation,
    this.footerLinkedIn,
    this.footerGitHub,
    this.footerInstagram,
    this.footerWhatsApp,
    this.footerCopyright,
    this.footerCredit,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    id: json['_id'] ?? json['id'] ?? '',
    name: json['name'],
    title: json['title'],
    bio: json['bio'],
    photoUrl: json['photoUrl'],
    resumeUrl: json['resumeUrl'],
    email: json['email'],
    phone: json['phone'],
    location: json['location'],
    heroSkills: json['heroSkills'],
    socialLinks: json['socialLinks'] != null ? List<String>.from(json['socialLinks']) : null,
    footerBrandName: json['footerBrandName'],
    footerTagline: json['footerTagline'],
    footerEmail: json['footerEmail'],
    footerLocation: json['footerLocation'],
    footerLinkedIn: json['footerLinkedIn'],
    footerGitHub: json['footerGitHub'],
    footerInstagram: json['footerInstagram'],
    footerWhatsApp: json['footerWhatsApp'],
    footerCopyright: json['footerCopyright'],
    footerCredit: json['footerCredit'],
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'title': title,
    'bio': bio,
    'photoUrl': photoUrl,
    'resumeUrl': resumeUrl,
    'email': email,
    'phone': phone,
    'location': location,
    'heroSkills': heroSkills,
    'socialLinks': socialLinks,
    'footerBrandName': footerBrandName,
    'footerTagline': footerTagline,
    'footerEmail': footerEmail,
    'footerLocation': footerLocation,
    'footerLinkedIn': footerLinkedIn,
    'footerGitHub': footerGitHub,
    'footerInstagram': footerInstagram,
    'footerWhatsApp': footerWhatsApp,
    'footerCopyright': footerCopyright,
    'footerCredit': footerCredit,
  };
}
