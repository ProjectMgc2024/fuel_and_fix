import 'package:flutter/material.dart';
import 'package:fuel_and_fix/owner/screens/feedbackview.dart';
import 'package:fuel_and_fix/owner/screens/tow/t_payment.dart';
import 'package:fuel_and_fix/owner/screens/tow/tow_profile.dart';
import 'package:fuel_and_fix/owner/screens/tow/tow_request.dart';
import 'package:fuel_and_fix/user/screens/introduction.dart'; // Import the introduction page

class TowManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tow Management',
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
              _buildVerticalCard(
                  context,
                  'Profile',
                  'Update your provider details',
                  Icons.person,
                  TowProfilePage()),
              _buildVerticalCard(
                  context,
                  'Towing Requests',
                  'Manage incoming towing service requests',
                  Icons.directions_car,
                  TowRequest()),
              _buildVerticalCard(
                  context,
                  'Payments & Earnings',
                  'Track your towing service payments',
                  Icons.account_balance_wallet,
                  TPaymentsAndEarningsPage()),
              _buildVerticalCard(
                  context,
                  'Feedback',
                  'View feedback from your customers',
                  Icons.feedback,
                  FeedbackScreen()), // New feedback card
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
        // Center the card in the layout
        child: Container(
          width: MediaQuery.of(context).size.width *
              0.6, // Reduce the width to 80% of the screen width
          child: Card(
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            color: Colors.white,
            margin: EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    icon,
                    size: 50,
                    color: Colors.deepPurple,
                  ),
                  SizedBox(height: 16),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(color: Colors.black54),
                    textAlign: TextAlign.center,
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
