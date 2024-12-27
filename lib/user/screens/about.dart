import 'package:flutter/material.dart';

class AboutHelp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About & Help'),
        backgroundColor: Colors.green[700], // Dark Green for a fresh look
        elevation: 4,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          color: Colors.grey[50], // Light background for better contrast
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // About Section
              const SizedBox(height: 20),
              _buildSectionCard(
                'About Us',
                'We provide on-demand fuel delivery and emergency vehicle repair services. Whether you run out of fuel, need a battery jump-start, or have a flat tire, we are here to help you get back on the road quickly and safely.',
                Icons.info_outline,
              ),
              const SizedBox(height: 20),

              // Key Features Section
              _buildSectionCard(
                'Key Features',
                '• Fuel Delivery: Petrol and diesel, delivered to your location.\n'
                    '• Emergency Repairs: Battery jump-start, flat tire replacement, and more.\n'
                    '• Towing Services: Reliable assistance for breakdowns.\n'
                    '• Real-Time Tracking: Track service providers easily.',
                Icons.featured_play_list,
              ),
              const SizedBox(height: 20),

              // Contact Section
              _buildSectionCard(
                'Contact Us',
                '• Phone: +1 800-123-4567\n'
                    '• Email: support@fuelrepair.com\n'
                    '• Website: www.fuelrepair.com\n'
                    'Our support team is available 24x7 to assist you.',
                Icons.contact_phone,
                isContact: true, // Special design for contact info
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build the section card
  Widget _buildSectionCard(String title, String description, IconData icon,
      {bool isContact = false}) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      shadowColor: Colors.black45,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 30, color: Colors.green[700]),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700]),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            if (isContact) ...[
              const SizedBox(height: 10),
              Text(
                'Our support team is available 24x7 to assist you.',
                style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700]),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
