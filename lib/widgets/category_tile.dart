// lib/widgets/category_tile.dart
import 'package:flutter/material.dart';

class CategoryTile extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  CategoryTile({required this.title, required this.imagePath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.orange),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(imagePath, width: double.infinity, height: 150, fit: BoxFit.cover),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Jua',
                fontSize: 16,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
