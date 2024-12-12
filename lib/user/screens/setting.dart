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
  bool _notificationsEnabled = true; // Default notifications state
  bool _isAppUpdateAvailable = false; // Simulate app update availability

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

  // Method to toggle notifications
  void _toggleNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
    });
  }

  // Method to simulate checking for app updates
  void _checkForAppUpdates() {
    setState(() {
      // Simulating the update check with a mock condition
      _isAppUpdateAvailable = !_isAppUpdateAvailable;
    });

    if (_isAppUpdateAvailable) {
      // Show a dialog if there's an update
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Update Available'),
            content: const Text(
                'A new version of the app is available. Please update to the latest version.'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
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
          ),
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

          // Notifications Toggle
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.black),
            title: const Text('Notifications'),
            subtitle: Text(_notificationsEnabled
                ? 'Notifications Enabled'
                : 'Notifications Disabled'),
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: _toggleNotifications,
            ),
          ),
          const Divider(),

          // App Updates
          ListTile(
            leading: const Icon(Icons.system_update_alt, color: Colors.black),
            title: const Text('Check for App Updates'),
            subtitle:
                Text(_isAppUpdateAvailable ? 'Update Available' : 'No Updates'),
            onTap: _checkForAppUpdates,
          ),
          const Divider(),

          // Logout
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
