// File: ../auth/models/user.dart

class User {
  final String id;
  final String username;
  final String email;
  final bool enabled;
  final String? name;
  final String? profilePicture;
  final bool emailVerified;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.enabled = true,
    this.name,
    this.profilePicture,
    this.emailVerified = false,
  });

  // Factory constructor to create a User from a map (JSON)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      enabled: json['enabled'] ?? true,
      name: json['name'] ?? json['fullName'],
      profilePicture: json['profilePicture'] ?? json['avatar'],
      emailVerified: json['emailVerified'] ?? false,
    );
  }

  // Convert User to a map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'enabled': enabled,
      'name': name,
      'profilePicture': profilePicture,
      'emailVerified': emailVerified,
    };
  }

  // Create a copy of User with some changes
  User copyWith({
    String? id,
    String? username,
    String? email,
    bool? enabled,
    String? name,
    String? profilePicture,
    bool? emailVerified,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      enabled: enabled ?? this.enabled,
      name: name ?? this.name,
      profilePicture: profilePicture ?? this.profilePicture,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }
}