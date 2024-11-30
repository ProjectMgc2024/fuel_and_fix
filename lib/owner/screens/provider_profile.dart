import 'package:flutter/material.dart';

class ServiceProviderProfilePage extends StatelessWidget {
  // Get the current logged-in user

  // Function to check if the user is an admin or service provider
  bool isAuthorized(String userRole) {
    return userRole == 'service_provider' || userRole == 'admin';
  }

  @override
  Widget build(BuildContext context) {
    String userRole =
        'service_provider'; // This should be fetched from the database (e.g., Firebase or your backend)

    // Check if the user is authorized
    if (!isAuthorized(userRole)) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Access Denied'),
        ),
        body:
            Center(child: Text('You do not have permission to view this page')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Service Provider Profile'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Profile Picture Section
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    NetworkImage('https://example.com/profile_picture_url'),
              ),
            ),
            SizedBox(height: 16),

            // Service Provider Information
            _buildInfoRow('Name:', 'John Doe'),
            _buildInfoRow('Phone Number:', '+123 456 7890'),
            _buildInfoRow('Email:', 'johndoe@example.com'),
            _buildInfoRow('Service Area:', 'Downtown, City'),
            _buildInfoRow('Experience:', '7 years'),
            _buildInfoRow(
                'Certifications:', 'Certified Mechanic, Fuel Technician'),
            _buildInfoRow(
                'Services Offered:', 'Fuel Delivery, Emergency Repairs'),

            // Availability Status
            SizedBox(height: 16),
            _buildInfoRow('Availability:', 'Available for tasks'),

            // Edit Profile Button (Only visible for the service provider or admin)
            if (userRole == 'service_provider' || userRole == 'admin')
              ElevatedButton(
                onPressed: () {
                  // Navigate to profile edit page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditProfilePage()),
                  );
                },
                child: Text('Edit Profile'),
              ),

            // Logout Button (only available for service providers)
            if (userRole == 'service_provider')
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text('Logout'),
              ),
          ],
        ),
      ),
    );
  }

  // Helper function to build info row
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// Profile Editing Page for Service Providers
class EditProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Text(
            'Edit Profile Page: Add form fields to edit the profile details'),
      ),
    );
  }
}

// Example Login Page (redirects to Profile page if logged in)
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Login logic here (Firebase auth or custom logic)
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ServiceProviderProfilePage()),
            );
          },
          child: Text('Login'),
        ),
      ),
    );
  }
}
