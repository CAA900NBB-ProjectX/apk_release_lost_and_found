class Profile {
  final int id;
  final String username;
  final String email;
  final bool enabled;
  final String? address1;
  final String? address2;
  final String? pobox;
  final String? city;
  final String? province;
  final String? country;
  final String? gender;
  final String? phoneno;

  Profile({
    required this.id,
    required this.username,
    required this.email,
    required this.enabled,
    this.address1,
    this.address2,
    this.pobox,
    this.city,
    this.province,
    this.country,
    this.gender,
    this.phoneno,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      enabled: json['enabled'],
      address1: json['address1'],
      address2: json['address2'],
      pobox: json['pobox'],
      city: json['city'],
      province: json['province'],
      country: json['country'],
      gender: json['gender'],
      phoneno: json['phoneno'],
    );
  }
}