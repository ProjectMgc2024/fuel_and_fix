import 'package:flutter/material.dart';
import 'package:fuel_and_fix/owner/screens/feedbackview.dart';
import 'package:fuel_and_fix/owner/screens/repair/r_payment.dart';
import 'package:fuel_and_fix/owner/screens/repair/repair_profile.dart';
import 'package:fuel_and_fix/owner/screens/repair/repair_request.dart'; // Import the repair request page
import 'package:fuel_and_fix/user/screens/introduction.dart'; // Import the introduction page

class RepairManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Repair Management',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 86, 101, 102),
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              size: 30,
              color: const Color.fromARGB(255, 72, 6, 6),
            ),
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
              const Color.fromARGB(255, 181, 160, 130),
              const Color.fromARGB(255, 140, 146, 177),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildVerticalCard(
                  context,
                  'Profile',
                  'Update your provider details',
                  Icons.person,
                  RepairProfilePage()),
              _buildVerticalCard(
                  context,
                  'Repair Requests',
                  'Manage incoming repair service requests',
                  Icons.build,
                  EmergencyRepairRequest()),
              _buildVerticalCard(
                  context,
                  'Payments & Earnings',
                  'Track your repair service payments',
                  Icons.account_balance_wallet,
                  RPaymentsAndEarningsPage()),
              _buildVerticalCard(
                  context,
                  'Feedback',
                  'View and manage customer feedback',
                  Icons.feedback,
                  FeedbackScreen()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalCard(BuildContext context, String title,
      String description, IconData icon, Widget page) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width *
              0.6, // Reduce the width to 60% of the screen width
          child: Card(
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            margin: EdgeInsets.symmetric(vertical: 8.0),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(255, 83, 83, 95), // Gradient color 1
                    const Color.fromARGB(
                        255, 102, 102, 101), // Gradient color 2
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      icon,
                      size: 50,
                      color: const Color.fromARGB(255, 255, 255,
                          255), // Icon color for visibility on gradient background
                    ),
                    SizedBox(height: 16),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Text color for better contrast
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                          color: Colors
                              .white70), // Slightly transparent white text
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
