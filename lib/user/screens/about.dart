import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import the url_launcher package

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AboutHelp(),
    );
  }
}

class AboutHelp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About & Help'),
        backgroundColor: Colors.teal[700], // Richer Teal for a modern look
        elevation: 6,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AboutSection(),
              const SizedBox(height: 20),
              KeyFeaturesSection(),
              const SizedBox(height: 20),
              ContactSection(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class AboutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildSectionCard(
      'About Us',
      'At Fuel and Fix, we are dedicated to providing on-demand fuel delivery and emergency vehicle repair services to ensure that your journey is never interrupted. Whether you’ve run out of fuel, need a jump-start for your battery, have a flat tire, or face any other roadside emergency, our team is ready to assist you. With our fleet of mobile service vehicles, we come directly to your location, providing you with convenience and peace of mind. Our services are available 24/7, ensuring that help is always just a call away, no matter where you are.',
      Icons.info_outline,
    );
  }

  Widget _buildSectionCard(String title, String description, IconData icon) {
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: Colors.teal.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 35, color: Colors.teal[700]),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[700],
                      fontFamily: 'Roboto'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style:
                  TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class KeyFeaturesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildSectionCard(
      'Key Features',
      '• Fuel Delivery: We provide fuel delivery services for both petrol and diesel. No matter where you are, we’ll come to your location, saving you time and effort. Whether you’re stranded at home, at work, or on the road, our fuel delivery service will get you back on track.\n\n'
          '• Emergency Repairs: If you experience a breakdown or other issues, we offer emergency repair services. From battery jump-starts to flat tire replacements, our trained professionals will arrive quickly and resolve the problem.\n\n'
          '• Towing Services: If your vehicle is unable to be repaired on-site, we offer towing services to safely transport your car to the nearest repair shop. Our towing trucks are equipped to handle all vehicle types, ensuring a smooth and secure tow.\n\n',
      Icons.featured_play_list,
    );
  }

  Widget _buildSectionCard(String title, String description, IconData icon) {
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: Colors.teal.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 35, color: Colors.teal[700]),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[700],
                      fontFamily: 'Roboto'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style:
                  TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildSectionCard(
      'Contact Us',
      'We are always available to assist you with your fuel and repair needs. If you need help, don’t hesitate to reach out to us through any of the following channels:\n\n'
          '• Email: ',
      Icons.contact_phone,
    );
  }

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
        scheme: 'mailto', path: 'projectmailmg@gmail.com', queryParameters: {});

    if (await canLaunch(emailLaunchUri.toString())) {
      await launch(emailLaunchUri.toString());
    } else {
      throw 'Could not launch email';
    }
  }

  // Method to launch the phone dialer
  Future<void> _launchPhone(String phoneNumber) async {
    final Uri phoneLaunchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    if (await canLaunch(phoneLaunchUri.toString())) {
      await launch(phoneLaunchUri.toString());
    } else {
      throw 'Could not launch phone number';
    }
  }

  Widget _buildSectionCard(String title, String description, IconData icon) {
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: Colors.teal.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon,
                    size: 35, color: const Color.fromARGB(255, 44, 77, 38)),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[700],
                      fontFamily: 'Roboto'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _launchPhone('7012697413'),
              child: Row(
                children: [
                  Icon(
                    Icons.phone, // Icon representing the phone symbol
                    color: const Color.fromARGB(255, 17, 124, 18),
                    size: 18,
                  ),
                  const SizedBox(width: 8), // Space between icon and text
                  Text(
                    '7012697413',
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style:
                  TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
            ),
            GestureDetector(
              onTap: () => _launchEmail(),
              child: Row(
                children: [
                  Icon(
                    Icons.email, // Icon representing the email symbol
                    color: const Color.fromARGB(255, 50, 57, 50),
                    size: 20,
                  ),
                  const SizedBox(width: 8), // Space between icon and text
                  Text(
                    'projectmailmg@gmail.com',
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
