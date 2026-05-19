import 'package:flutter/material.dart';
import '../auth_service.dart';
import '../design.dart';
import 'main_page.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool isSignIn = true; // Determines if the user is signing in or registering
  bool _passwordVisible = false; // Controls password visibility
  bool _confirmPasswordVisible = false; // Controls confirm password visibility

  void _authenticate() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

 
    if (isSignIn) {
      // Login
      bool result = await _authService.login(email, password);
      if (email.isEmpty || password.isEmpty) {
    _showMessage('Please fill in all fields');
    return;
  }
      if (result) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage(email: email)),
        );
      } else {
        _showMessage('Invalid email or password!');
      }
    } else {
      // Register
      if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
    _showMessage('Please fill in all fields');
    return;
  }
      if (password != confirmPassword) {
        _showMessage('Passwords do not match!');
        return;
      }
      bool result = await _authService.register(email, password);
      if (result) {
        _showMessage('Registration successful! Please log in.');
        setState(() {
          isSignIn = true; // Switch to login mode
        });
      } else {
        _showMessage('Account with this email already exists or email is not valid!');
      }
    }
  }


  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Message'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             Container(
  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Add padding inside the box
  decoration: BoxDecoration(
    color: Colors.white, // Background color of the box
    border: Border.all(color: Design.primaryColor, width: 2), // Border around the box
    borderRadius: BorderRadius.circular(30), // Rounded corners
  ),
  child: Text(
    'Explore Lithuania!',
    style: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Design.primaryColor,
    ),
    textAlign: TextAlign.center, // Center-align the text
  ),
),
              SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: Design.inputDecoration('EMAIL'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: !_passwordVisible, // Toggle visibility
                decoration: Design.inputDecoration('PASSWORD').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
              ),
              if (!isSignIn) ...[
                SizedBox(height: 20),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: !_confirmPasswordVisible, // Toggle visibility
                  decoration: Design.inputDecoration('CONFIRM PASSWORD').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _confirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _confirmPasswordVisible = !_confirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
              ],
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _authenticate,
                style: Design.buttonStyle(),
                child: Text(
                  isSignIn ? 'Sign In' : 'Register',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () => setState(() => isSignIn = !isSignIn),
                child: Text(
                  isSignIn
                      ? 'Don\'t have an account? Register'
                      : 'Already have an account? Sign In',
                  style: TextStyle(color: Design.primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
