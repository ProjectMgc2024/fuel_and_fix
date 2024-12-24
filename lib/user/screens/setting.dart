import 'package:flutter/material.dart';
import 'package:fuel_and_fix/user/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<Settings> {
  bool _notificationsEnabled = true;
  bool _isAppUpdateAvailable = false;
  bool _isDarkModeEnabled = false; // New variable for dark mode toggle

  @override
  void initState() {
    super.initState();
    _loadDarkModeSetting(); // Load the dark mode setting when the screen is initialized
  }

  // Load the dark mode setting from SharedPreferences
  _loadDarkModeSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkModeEnabled =
          prefs.getBool('darkMode') ?? false; // Default to false if not set
    });
  }

  // Save the dark mode setting to SharedPreferences
  _saveDarkModeSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', value);
  }

  // Toggle settings helper function
  void _toggleSetting(bool value, String setting) {
    setState(() {
      if (setting == 'notifications') {
        _notificationsEnabled = value;
      } else if (setting == 'darkMode') {
        _isDarkModeEnabled = value; // Toggle dark mode
        _saveDarkModeSetting(value); // Save the updated setting
      }
    });
  }

  // Check for app updates
  void _checkForAppUpdates() {
    setState(() {
      _isAppUpdateAvailable = !_isAppUpdateAvailable;
    });
    if (_isAppUpdateAvailable) {
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
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // This removes the debug banner
      themeMode: _isDarkModeEnabled
          ? ThemeMode.dark
          : ThemeMode.light, // Switch theme based on _isDarkModeEnabled
      theme: ThemeData.light().copyWith(
        primaryColor: const Color(0xFF5F6368),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF5F6368),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: const Color(0xFF5F6368),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context); // Navigate back to the previous screen
            },
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSettingItem(
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: _notificationsEnabled ? 'Enabled' : 'Disabled',
              value: _notificationsEnabled,
              onToggle: (value) => _toggleSetting(value, 'notifications'),
            ),
            const Divider(),
            _buildListTile(
              icon: Icons.system_update_alt,
              title: 'Check for App Updates',
              subtitle:
                  _isAppUpdateAvailable ? 'Update Available' : 'No Updates',
              onTap: _checkForAppUpdates,
            ),
            const Divider(),
            // New Dark Mode toggle
            _buildSettingItem(
              icon: Icons.dark_mode,
              title: 'Dark Mode',
              subtitle: _isDarkModeEnabled ? 'Enabled' : 'Disabled',
              value: _isDarkModeEnabled,
              onToggle: (value) => _toggleSetting(value, 'darkMode'),
            ),
            const Divider(),
            _buildListTile(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // General setting item widget with a switch
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onToggle,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF5F6368)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
        trailing: Switch(
          value: value,
          onChanged: onToggle,
          activeColor: const Color(0xFF4CAF50),
        ),
      ),
    );
  }

  // Regular list tile widget (for app updates, logout)
  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF5F6368)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        onTap: onTap,
      ),
    );
  }
}

void main() {
  runApp(const Settings());
}
