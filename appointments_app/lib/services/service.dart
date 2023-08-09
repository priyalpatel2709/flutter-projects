import 'dart:convert';
import 'package:http/http.dart' as http;

var baseUri = 'https://appointments-backend.vercel.app';

Future<Map<String, dynamic>?> addUser(name, description, maxSlots, dates) async {
  final apiUrl = "$baseUri/add-user";

  final Map<String, dynamic> data = {
    "name": name,
    "description": description,
    "MaxSlots": maxSlots,
    "date": [dates],
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
}
