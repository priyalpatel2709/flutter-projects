import 'dart:convert';
import 'package:http/http.dart' as http;

var baseUri = 'https://appointments-backend.vercel.app';


var postUserInfo = ({name, description, maxSlots,date}) async {
  final response = await http.post(
    Uri.parse('$baseUri/add-user'),
    body: jsonEncode({
      "name": name,
      "description": description,
      "MaxSlots": maxSlots,
      "date": date
    }),
  );

  if (response.statusCode == 200) {
    print('User info added successfully');
    return response;
  } else {
    print('Failed to add user info');
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
  }
};
