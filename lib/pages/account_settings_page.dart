import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'change_password.dart';
import 'auth_page.dart';

class AccountSettingsPage extends StatelessWidget {
  final String email; // Add the email as a required parameter

  AccountSettingsPage({required this.email});

 void _logout(BuildContext context) async {
  try {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:3000/api/logout'), // Replace with your backend logout endpoint
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Successfully logged out
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logged out successfully.')),
      );

      // Navigate to the AuthPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthPage()),
      );

    } else {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to log out. Please try again.')),
      );
    }
  } catch (error) {
    // Handle network or other errors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $error')),
    );
  }
}


 Future<void> _deleteAccount(BuildContext context) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Delete Account"),
        content: Text(
          "Are you sure you want to delete your account? This action is irreversible.",
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                final response = await http.delete(
                  Uri.parse('http://127.0.0.1:3000/api/deleteMe?email=$email'),
                  headers: {'Content-Type': 'application/json'},
                );

                if (response.statusCode == 204) {
                  // Account successfully deleted
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Account deleted successfully.')),
                  );

              

                  // Navigate to the AuthPage(not working?)
                  Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthPage()),
      );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete account.')),
                  );
                }
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $error')),
                );
              }

              Navigator.of(context).pop(); // Close the confirmation dialog
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel"),
          ),
        ],
      );
    },
  );
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Account Settings"),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.lock, color: Colors.orange),
            title: Text("Change Password"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangePasswordPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.orange),
            title: Text("Logout"),
            onTap: () => _logout(context),
          ),
          ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text("Delete Account"),
            onTap: () => _deleteAccount(context),
          ),
        ],
      ),
    );
  }
}
