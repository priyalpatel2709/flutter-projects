import 'package:hive_flutter/adapters.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  String userId;

  @HiveField(1)
  String token;

  @HiveField(2)
  String name;

  @HiveField(3)
  String email;

  @HiveField(4)
  String? imageUrl; // Make the imageUrl field optional

  User({
    required this.userId,
    required this.token,
    required this.name,
    required this.email,
    this.imageUrl, // Make imageUrl optional with a default value of null
  });
}

class UserInfo {
  final _myBox = Hive.box('user_info');

  void addUserInfo(User user) {
    _myBox.put('user', user);
  }

  User getUserInfo() {
    return _myBox.get('user');
  }
}
