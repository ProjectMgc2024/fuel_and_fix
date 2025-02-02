import 'package:flutter/material.dart';
import 'package:fuel_and_fix/owner/screens/feedbackview.dart';
import 'package:fuel_and_fix/owner/screens/fuel/fuel_request.dart';
import 'package:fuel_and_fix/owner/screens/fuel/f_payment.dart';
import 'package:fuel_and_fix/owner/screens/fuel/fuel_profile.dart';
import 'package:fuel_and_fix/user/screens/introduction.dart';

class FuelManagement extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Custom back button icon
          onPressed: () {
            // Pop the current screen when the button is pressed
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          'Fuel Management',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 137, 152, 108),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, size: 30),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Logged out!')),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) =>IntroductionPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 176, 179, 163),
              const Color.fromARGB(255, 96, 85, 62),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: ListView(
            children: [
              _buildDashboardSection(
                  context,
                  'Profile',
                  'Update your provider details',
                  Icons.person,
                  FuelProfilePage()),
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
                  'Feedback',
                  'View and manage customer feedback',
                  Icons.feedback,
                  FeedbackScreen()), // Feedback card
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
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            // Add a gradient color to the card
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 106, 107, 69), // Dark gradient color
                Color.fromRGBO(85, 63, 52, 1), // Light gradient color
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
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
                  size: 50,
                  color: const Color.fromARGB(255, 255, 255, 255),
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
                          color: const Color.fromARGB(255, 253, 245, 255),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(
                            color: const Color.fromARGB(224, 255, 248, 248)),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
