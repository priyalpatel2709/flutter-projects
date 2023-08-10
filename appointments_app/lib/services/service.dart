import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/usermodel.dart';

var baseUri = 'https://appointments-backend.vercel.app';

Future<Map<String, dynamic>?> addUser(
    name, description, maxSlots, dates) async {
  final apiUrl = "$baseUri/add-user";

  try {
    final Map<String, dynamic> data = {
      "name": name,
      "description": description,
      "MaxSlots": maxSlots,
      "date": dates,
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      // print("User added successfully");
      return jsonData; // Return the jsonData
    } else {
      print("Failed to add user. Error: ${response.body}");
      return null; // Return null in case of failure
    }
  } catch (err) {
    print(err);
  }
}

Future<List<UserModel>> getUserInfo() async {
  final apiUrl = "$baseUri/get-user";
  try {
    final responce = await http.get(Uri.parse(apiUrl));
    var data = jsonDecode(responce.body.toString());

    if (responce.statusCode == 200) {
      List<UserModel> userinfolist = [];
      for (var i in data) {
        userinfolist.add(UserModel.fromJson(i));
      }
      return userinfolist;
    } else {
      return [];
    }
  } catch (err) {
    print(err);
    return [];
  }
}

Future<dynamic> deleteuser(id) async {
  try {
    final apiUrl = "$baseUri/delete-user/$id";

    final response = await http.delete(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      return json.decode(response.body); // Use json.decode to parse JSON
    } else {
      print('Delete request failed with status code ${response.statusCode}');
      return 'Delete operation failed';
    }
  } catch (error) {
    print('Error during delete request: $error');
    return 'An error occurred';
  }
}

Future<String> updateUser(
    String id, String name, String slot, String description) async {
  try {
    final apiUrl = "$baseUri/update-user/$id";
    print(apiUrl);
    final response = await http.put(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'MaxSlots': slot,
        'description': description,
      }),
    );
    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      var data = jsonDecode(response.body);
      print('data $data');
      if (data['modifiedCount'] == 1) {
        return 'update successfully';
      } else if (data['matchedCount'] != 1) {
        return 'User not found';
      } else if (data['modifiedCount'] == 0) {
        return 'make any changes';
      } else {
        return "can't able to update";
      }
    } else {
      print('Error during update request: ${response.body}');
      return 'Error during update request: ${response.body}';
    }
  } catch (err) {
    print('Error during update request: $err');
    return 'Error during update request: $err';
  }
}

Future<Map<String, dynamic>> addSubscriptions(Subscription) async {
  final apiUrl = "$baseUri/subscriptions";
  
  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(Subscription),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      // Do any additional processing if needed
      return jsonData; // Return the jsonData
    } else {
      print("Failed to add subscription. Error: ${response.body}");
      throw Exception("Failed to add subscription"); 
    }
  } catch (error) {
    print("Error during subscription request: $error");
    throw Exception("Error during subscription request"); 
  }
}


Future <dynamic> fetchUserAppointments(date,name) async {
   final apiUrl = "$base64Url/booked-time-slots";
   try{
     
   }catch(err){
    print("Error during subscription request: $err");
    throw Exception("Error during subscription request");
   }
}