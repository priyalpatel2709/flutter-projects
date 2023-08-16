class UserLonin {
  final String id;
  final String name;
  final String email;

  UserLonin({
    required this.id,
    required this.name,
    required this.email,
  });

  factory UserLonin.fromJson(Map<String, dynamic> json) {
    return UserLonin(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
    );
  }
}
