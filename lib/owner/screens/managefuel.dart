import 'package:flutter/material.dart';
import 'package:fuel_and_fix/owner/screens/fuel_request.dart';
import 'package:fuel_and_fix/owner/screens/f_payment.dart';
import 'package:fuel_and_fix/owner/screens/owner_login.dart';
import 'package:fuel_and_fix/owner/screens/provider_profile.dart';

class FuelManagement extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fuel Management',
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
                MaterialPageRoute(
                    builder: (context) => ServiceProviderRegisterPage()),
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
              Color.fromARGB(255, 4, 163, 34),
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
                  'Profile',
                  'Update your provider details',
                  Icons.person,
                  ServiceProviderProfilePage()),
              _buildDashboardSection(
                  context,
                  'Fuel Requests',
                  'Manage incoming fuel service requests',
                  Icons.local_gas_station,
                  FuelFillingRequest()),
              _buildDashboardSection(
                  context,
                  'Payments & Earnings',
                  'Track your fuel service payments',
                  Icons.account_balance_wallet,
                  PaymentsAndEarningsPage()),
              _buildDashboardSection(
                  context,
                  'Pending Tasks',
                  'View and manage your pending fuel requests',
                  Icons.hourglass_empty,
                  PendingFuelTasksPage()), // New section for pending tasks
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
        child: Center(
          child: Container(
            width:
                MediaQuery.of(context).size.width * 0.4, // Adjust width to 80%

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
      ),
    );
  }
}

// New page for Pending Fuel Tasks
class PendingFuelTasksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Fuel Requests'),
        backgroundColor: Color.fromARGB(255, 160, 128, 39),
      ),
      body: Center(
        child: Text(
          'This page will list all pending fuel service tasks.',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
