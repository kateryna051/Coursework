import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChangePasswordPage extends StatelessWidget {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // URL of the backend endpoint for password change
  final String _backendUrl = 'http://127.0.0.1:3000/api/reset';
  
  // Initialize Flutter Secure Storage to retrieve the JWT token
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Function to change the password
  // Function to change the password
Future<void> _changePassword(BuildContext context) async {
  final currentPassword = _currentPasswordController.text;
  final newPassword = _newPasswordController.text;
  final confirmPassword = _confirmPasswordController.text;

  if (newPassword != confirmPassword) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("New password and confirmation do not match")),
    );
    return;
  }

  // Retrieve JWT token from secure storage
  String? token = await _storage.read(key: 'jwt_token');

  if (token == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("You are not logged in!")),
    );
    return;
  }

  // Create the payload for the password change request
  final Map<String, String> payload = {
    'currentPassword': currentPassword,
    'password': newPassword,
    'confirmPassword': confirmPassword,
  };

  // Sending the request to the backend
  try {
    final response = await http.patch(
      Uri.parse(_backendUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Include the token here
      },
      body: json.encode(payload),
    );

    // Check if the response is in JSON format
    if (response.headers['content-type']?.contains('application/json') ?? false) {
      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        // Password changed successfully
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Password changed successfully!")),
        );
        Navigator.pop(context); // Close the page
      } else {
        // Handle errors (e.g., wrong current password, backend issues)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['error'] ?? "Something went wrong")),
        );
      }
    } else {
      // If not a JSON response, show an error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Received unexpected response format")),
      );
    }
  } catch (error) {
    // Handle network errors or any other issues
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $error")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Change Password"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _currentPasswordController,
              decoration: InputDecoration(labelText: "Current Password"),
              obscureText: true,
            ),
            TextField(
              controller: _newPasswordController,
              decoration: InputDecoration(labelText: "New Password"),
              obscureText: true,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: "Confirm New Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _changePassword(context),
              child: Text("Change Password"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, // Button color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
