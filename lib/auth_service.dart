import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String _baseUrl = 'http://127.0.0.1:3000/api'; // Correct URL for the backend
final FlutterSecureStorage _storage = FlutterSecureStorage();
  // Register method
Future<bool> register(String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    print('Request sent to: $_baseUrl/register');
    print('Request body: {"email": "$email", "password": "$password"}');
    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 201) {
      return true;
    } else if (response.statusCode == 409) {
      // Handle the conflict error (email already exists)
      throw 'Account with this email already exists!';
    }else {
      print('Error: ${response.body}');
      return false;
    }
  } catch (e) {
    print('Error during registration: $e');
    return false;
  }
}



  // Login method
  Future<bool> login(String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final String token = responseData['token'];  // Get token from the response

      // Save token to secure storage
      await _storage.write(key: 'jwt_token', value: token);
      print('Token: $token');

      return true; // Login successful
    } else {
      return false; // Handle login failure
    }
  } catch (e) {
    print('Error during login: $e');
    return false;
  }
}

}
