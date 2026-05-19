import 'package:flutter/material.dart';
import 'home_page.dart';
import 'categories_page.dart';
import 'profile_page.dart';

class MainPage extends StatefulWidget {
  final String email;

  MainPage({required this.email});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0; // Default to Categories

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      CategoriesPage(email: widget.email),
      HomePage(email: widget.email),
      ProfilePage(email: widget.email), 
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "",
          ),
        ],
      ),
    );
  }
}


