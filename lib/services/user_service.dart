import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geouser_gallery/models/user.dart';

class UserService {
  final String url = "https://reqres.in/api/users?page=2";

  Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return List<User>.from(data.map((user) => User.fromJson(user)));
    } else {
      throw Exception('Failed to load users');
    }
  }
}
