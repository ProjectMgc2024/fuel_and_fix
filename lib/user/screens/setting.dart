import 'package:flutter/material.dart';
import 'package:fuel_and_fix/user/screens/login_screen.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<Settings> {
  bool _isDarkMode = false; // Initially set to light mode
  double _fontSize = 16.0; // Default font size
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Method to toggle theme
  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
  }

  // Method to change font size
  void _changeFontSize(double value) {
    setState(() {
      _fontSize = value;
    });
  }

  // Method to show password change dialog
  void _showPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Current Password'),
              ),
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
              ),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Confirm New Password'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Implement password change logic here
                Navigator.pop(context);
              },
              child: const Text('Change Password'),
            ),
          ],
        );
      },
    );
  }

  // Method to show service coverage areas
  void _showServiceCoverage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Service Coverage Areas'),
          content: const Text('We currently serve the following areas:\n\n'
              '1. New York\n'
              '2. Los Angeles\n'
              '3. Chicago\n'
              '4. Miami\n'
              '5. Houston\n'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
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
        title: const Text('Settings'),
        backgroundColor: Color.fromARGB(255, 174, 177, 138),
      ),
      body: ListView(
        children: [
          // Theme Toggle
          ListTile(
            leading: const Icon(Icons.brightness_6, color: Colors.black),
            title: const Text('Theme'),
            subtitle: Text(_isDarkMode ? 'Dark Mode' : 'Light Mode'),
            trailing: Switch(
              value: _isDarkMode,
              onChanged: _toggleTheme,
            ),
          ),
          const Divider(),

          // Font Size Adjustment
          ListTile(
            leading: const Icon(Icons.text_fields, color: Colors.black),
            title: const Text('Font Size'),
            subtitle: Text('Current size: ${_fontSize.toStringAsFixed(1)}'),
            trailing: DropdownButton<double>(
              value: _fontSize,
              items: [14.0, 16.0, 18.0, 20.0, 22.0].map((double size) {
                return DropdownMenuItem<double>(
                  value: size,
                  child: Text(size.toString()),
                );
              }).toList(),
              onChanged: (double? newSize) {
                if (newSize != null) {
                  _changeFontSize(newSize);
                }
              },
            ),
          ),
          const Divider(),

          // Password Change
          ListTile(
            leading: const Icon(Icons.lock, color: Colors.black),
            title: const Text('Change Password'),
            onTap: _showPasswordDialog,
          ),
          const Divider(),

          // Service Coverage
          ListTile(
            leading: const Icon(Icons.location_on, color: Colors.black),
            title: const Text('Service Coverage'),
            subtitle: const Text('View available service areas'),
            onTap: _showServiceCoverage,
          ),
          const Divider(),

          //logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.black),
            title: const Text('Logout'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  // Method to toggle theme
  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light().copyWith(
        primaryColor: const Color.fromARGB(
            206, 180, 123, 59), // Custom color for light theme
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: const Color.fromARGB(
            206, 180, 123, 59), // Custom color for dark theme
      ),
      home: const Settings(), // Directly load SettingsPage here for simplicity
    );
  }
}
