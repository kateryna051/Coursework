import 'package:flutter/material.dart';

class Design {
  static const Color primaryColor = Colors.orange;

  static InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: primaryColor),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor, width: 2.0),
        borderRadius: BorderRadius.circular(25.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor, width: 2.0),
        borderRadius: BorderRadius.circular(25.0),
      ),
    );
  }

  static ButtonStyle buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
    );
  }
}
