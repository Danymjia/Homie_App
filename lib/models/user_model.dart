class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final int? age;
  final String? location;
  final String? bio;
  final List<String> lifestyleTags;
  final String? photoUrl;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.age,
    this.location,
    this.bio,
    this.lifestyleTags = const [],
    this.photoUrl,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      age: json['age'] as int?,
      location: json['location'] as String?,
      bio: json['bio'] as String?,
      lifestyleTags: List<String>.from(json['lifestyle_tags'] as List? ?? []),
      photoUrl: json['photo_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'age': age,
      'location': location,
      'bio': bio,
      'lifestyle_tags': lifestyleTags,
      'photo_url': photoUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
