class UserProfileModel {
  final String id;
  final String email;
  final String? fullName;
  final int? age;
  final String? location;
  final String? bio;
  final String? photoUrl;
  final UserType? userType;
  final bool isVerified;
  final List<String> lifestyleTags;
  final CompatibilityScore? compatibilityScore;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserProfileModel({
    required this.id,
    required this.email,
    this.fullName,
    this.age,
    this.location,
    this.bio,
    this.photoUrl,
    this.userType,
    this.isVerified = false,
    this.lifestyleTags = const [],
    this.compatibilityScore,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      age: json['age'] as int?,
      location: json['location'] as String?,
      bio: json['bio'] as String?,
      photoUrl: json['photo_url'] as String?,
      userType: json['user_type'] != null
          ? UserType.fromString(json['user_type'] as String)
          : null,
      isVerified: json['is_verified'] as bool? ?? false,
      lifestyleTags: List<String>.from(json['lifestyle_tags'] as List? ?? []),
      compatibilityScore: json['compatibility_data'] != null
          ? CompatibilityScore.fromJson(json['compatibility_data'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
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
      'photo_url': photoUrl,
      'user_type': userType?.toString(),
      'is_verified': isVerified,
      'lifestyle_tags': lifestyleTags,
      'compatibility_data': compatibilityScore?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

enum UserType {
  student,
  worker,
  both;

  static UserType? fromString(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'student':
        return UserType.student;
      case 'worker':
        return UserType.worker;
      case 'both':
        return UserType.both;
      default:
        return null;
    }
  }

  @override
  String toString() {
    switch (this) {
      case UserType.student:
        return 'student';
      case UserType.worker:
        return 'worker';
      case UserType.both:
        return 'both';
    }
  }

  String get displayName {
    switch (this) {
      case UserType.student:
        return 'Estudiante';
      case UserType.worker:
        return 'Trabajador';
      case UserType.both:
        return 'Estudiante y Trabajador';
    }
  }
}

class CompatibilityScore {
  final Map<String, dynamic> habits;
  final double overallScore;

  CompatibilityScore({
    required this.habits,
    required this.overallScore,
  });

  factory CompatibilityScore.fromJson(Map<String, dynamic> json) {
    return CompatibilityScore(
      habits: json['habits'] as Map<String, dynamic>? ?? {},
      overallScore: (json['overall_score'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'habits': habits,
      'overall_score': overallScore,
    };
  }

  static double calculateMatchScore(
    Map<String, dynamic> user1Habits,
    Map<String, dynamic> user2Habits,
  ) {
    double score = 0.0;
    int totalQuestions = 0;

    // Comparar cada hábito
    user1Habits.forEach((key, value) {
      if (user2Habits.containsKey(key)) {
        totalQuestions++;
        if (value == user2Habits[key]) {
          score += 1.0; // Coincidencia perfecta
        } else if (_areCompatible(key, value, user2Habits[key])) {
          score += 0.5; // Compatible pero no igual
        }
      }
    });

    return totalQuestions > 0 ? (score / totalQuestions) * 100 : 0.0;
  }

  static bool _areCompatible(String key, dynamic value1, dynamic value2) {
    // Lógica para determinar si dos valores son compatibles
    // Por ejemplo, "flexible" es compatible con cualquier cosa
    if (value1 == 'flexible' || value2 == 'flexible') return true;
    
    // Para algunas preguntas, ciertos valores son compatibles
    switch (key) {
      case 'pets':
        return value1 == value2; // Debe ser exacto
      case 'smoking':
        return value1 == value2; // Debe ser exacto
      case 'schedule':
        // "flexible" es compatible con cualquier horario
        return value1 == 'flexible' || value2 == 'flexible' || value1 == value2;
      default:
        return value1 == value2;
    }
  }
}
