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

