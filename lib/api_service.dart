import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  //TODO move to properties file with gitignore
  static const String baseUrl = 'http://192.168.1.17:3000';
  // static const String baseUrl = 'http://127.0.0.1:3000';
// 'http://localhost:3000';
  Future<String> fetchGreeting() async {
    final response = await http.get(Uri.parse('$baseUrl/hello'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['message'];
    } else {
      throw Exception('Failed to load greeting');
    }
  }
}
