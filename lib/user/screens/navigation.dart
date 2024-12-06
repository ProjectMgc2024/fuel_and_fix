/*import 'package:flutter/material.dart';
import 'package:flutter_application_1/user/screens/about.dart';
import 'package:flutter_application_1/user/screens/history.dart';
import 'package:flutter_application_1/user/screens/home_screen.dart';
import 'package:flutter_application_1/user/screens/login_screen.dart';
import 'package:flutter_application_1/user/screens/profile.dart';
import 'package:flutter_application_1/user/screens/setting.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedPageIndex = 0;

  // List of pages to navigate
  final List<Widget> _pages = [
    HomeScreen(),
    ProfileScree(),
    Settings(),
    UserHistory(),
    AboutHelp(), // About Help screen added here
  ];

  // Function to navigate to a selected page
  void _onSelectPage(int index) {
    setState(() {
      _selectedPageIndex = index; // Simply update the selected page index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedPageIndex], // Displays selected page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedPageIndex,
        onTap: _onSelectPage,
        iconSize: 25,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help),
            label: 'About/Help',
          ),
        ],
        backgroundColor: Colors.white,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

// Profile Screen
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Screen'),
      ),
      body: const Center(
        child: Text(
          'Welcome to your Profile',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

// Settings Page
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings Screen'),
      ),
      body: const Center(
        child: Text(
          'Settings Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

// History Page
class UserHistoryPage extends StatelessWidget {
  const UserHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History Screen'),
      ),
      body: const Center(
        child: Text(
          'History Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

// About/Help Page
class AboutHelpPage extends StatelessWidget {
  const AboutHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About/Help Screen'),
      ),
      body: const Center(
        child: Text(
          'About / Help Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}*/
