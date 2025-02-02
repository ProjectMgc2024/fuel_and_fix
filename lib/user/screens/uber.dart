import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UberSection extends StatelessWidget {
  // Method to launch the Uber app using its deep link or fallback to the website
  Future<void> _launchUber() async {
    const uberUrl = 'uber://'; // Uber app deep link URL
    const websiteUrl = 'https://www.uber.com'; // Uber's official website URL

    if (await canLaunch(uberUrl)) {
      // Attempt to open the Uber app directly
      await launch(uberUrl);
    } else {
      // If Uber app is not installed, attempt to open the website
      if (await canLaunch(websiteUrl)) {
        await launch(websiteUrl);
      } else {
        throw 'Could not launch Uber app or website';
      }
    }
  }

  // Method to show the popup dialog
  void _showUberDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Open Uber'),
          content: Text('Do you want to open the Uber app?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                    context); // Close the popup without doing anything
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the popup
                _launchUber(); // Launch Uber after confirmation
              },
              child: Text('Go to Uber'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () =>
              _showUberDialog(context), // Show the popup dialog when pressed
          child: Text('Go to Uber'),
        ),
      ),
    );
  }
}
