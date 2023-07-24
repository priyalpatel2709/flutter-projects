class UserSingup {
  final String id;
  final String name;
  final String email;
  final int v;

  UserSingup({
    required this.id,
    required this.name,
    required this.email,
    required this.v,
  });

  factory UserSingup.fromJson(Map<String, dynamic> json) {
    return UserSingup(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      v: json['__v'],
    );
  }
}

class AuthData {
  final String auth;

  AuthData({required this.auth});

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      auth: json['auth'],
    );
  }
}
