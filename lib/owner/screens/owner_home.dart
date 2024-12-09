/*import 'package:flutter/material.dart';
import 'package:fuel_and_fix/owner/screens/managefuel.dart';
import 'package:fuel_and_fix/owner/screens/managerepair.dart';
import 'package:fuel_and_fix/owner/screens/managetow.dart';
import 'package:fuel_and_fix/user/screens/introduction.dart';

class ServiceHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Service Dashboard',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(255, 160, 128, 39),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, size: 30),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Logged out!')),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => IntroductionPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 202, 113, 36),
              Color.fromARGB(255, 4, 163, 34)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildDashboardSection(
                  context,
                  'Fuel Poviders',
                  'Manage fuel services',
                  Icons.local_gas_station,
                  FuelManagement()),
              _buildDashboardSection(context, 'Emergency Repairs providers',
                  'Handle urgent repairs', Icons.build, RepairManagementPage()),
              _buildDashboardSection(context, 'Tow service providers',
                  'Handle urgent services', Icons.build, TowManagementPage()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardSection(BuildContext context, String title,
      String description, IconData icon, Widget page) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: Colors.deepPurple,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                  color: Colors.deepPurple,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/
