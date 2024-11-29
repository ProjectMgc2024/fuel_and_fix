import 'package:flutter/material.dart';

class AboutHelp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About & Help'),
        backgroundColor: Color.fromARGB(255, 174, 177, 138),
      ),
      body: SingleChildScrollView(
        // Make the body scrollable
        child: Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.grey[200], // Light background color
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const SizedBox(height: 20),

              // About Section
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'About Us',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'We provide on-demand fuel delivery and emergency vehicle repair services. Whether you run out of fuel, need a battery jump-start, or have a flat tire, we are here to help you get back on the road quickly and safely.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Features Section
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Key Features',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '• Fuel Delivery: Petrol and diesel, delivered to your location.\n'
                        '• Emergency Repairs: Battery jump-start, flat tire replacement, and more.\n'
                        '• Towing Services: Reliable assistance for breakdowns.\n'
                        '• Real-Time Tracking: Track service providers easily.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Contact Section
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Contact Us',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '• Phone: +1 800-123-4567\n'
                        '• Email: support@fuelrepair.com\n'
                        '• Website: www.fuelrepair.com\n',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Our support team is available 24x7 to assist you.',
                        style: TextStyle(
                            fontSize: 16, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
