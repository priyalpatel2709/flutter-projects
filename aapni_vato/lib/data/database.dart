import 'package:hive_flutter/adapters.dart';

// import '../model/alluserData.dart';

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
  String? imageUrl;
  
  @HiveField(5)
  String? deviceToken; 
 

  User({
    required this.userId,
    required this.token,
    required this.name,
    required this.email,
    this.imageUrl, 
    this.deviceToken
  });
}

class UserInfo {
  final _myBox = Hive.box('user_info');

  void addUserInfo(User user) {
    _myBox.put('user', user);
  }

  void clearBox() {
    _myBox.clear();
  }

  void addSearchedUser(data) {
    _myBox.put('user_data', data);
  }

  List<Map<String, dynamic>> getSearchedUser() {
  var data = _myBox.get('user_data');
  if (data == null) {
    // Handle the case where 'user_data' is not found in Hive
    return <Map<String, dynamic>>[]; // Return an empty list as a default value
  }
  if (data is List<Map<String, dynamic>>) {
    return data;
  } else {
    // Handle the case where 'user_data' has an unexpected type
    // You can choose to return an empty list or handle it differently based on your use case
    return <Map<String, dynamic>>[];
  }
}


  User getUserInfo() {
    return _myBox.get('user');
  }
}
