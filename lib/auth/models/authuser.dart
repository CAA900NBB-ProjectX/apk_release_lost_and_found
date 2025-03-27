class AuthUser {
  final int id;
  final String username;
  final String email;
  final bool enabled;

  AuthUser({
    required this.id,
    required this.username,
    required this.email,
    required this.enabled,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      enabled: json['enabled'],
    );
  }
}