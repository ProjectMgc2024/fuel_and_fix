import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScree extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        centerTitle: true, // Center the AppBar title
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('user')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          // Show loading spinner while waiting for data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Handle any errors in fetching the data
          else if (snapshot.hasError) {
            return Center(child: Text("An error occurred: ${snapshot.error}"));
          }

          // Handle case when there's no data or the data is null
          else if (!snapshot.hasData || snapshot.data?.data() == null) {
            return Center(child: Text("No user data available"));
          }

          // If data exists, display the profile information
          else {
            final profileData = snapshot.data!.data() as Map<String, dynamic>;
            final userEmail = profileData['email'] ?? 'No email provided';
            final userPhoneNo =
                profileData['phoneno'] ?? 'No phone number provided';
            final userName = profileData['username'] ?? 'No username provided';

            // Center the profile info on the screen
            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Display username
                      Text(
                        'Username: $userName',
                        style: TextStyle(
                          fontSize: 20,

                          color: Colors
                              .black87, // Darker text color for readability
                        ),
                      ),
                      SizedBox(height: 22), // Space between username and email

                      // Display email
                      Text(
                        'Email: $userEmail',
                        style: TextStyle(
                          fontSize: 20,

                          // Slightly lighter weight than username
                          color: Colors.black54, // Lighter text color for email
                        ),
                      ),
                      SizedBox(
                          height: 10), // Space between email and phone number

                      // Display phone number
                      Text(
                        'Phone Number: $userPhoneNo',
                        style: TextStyle(
                          fontSize: 20,
                          // Similar weight to email
                          color: const Color.fromARGB(137, 0, 0,
                              0), // Light black color for phone number
                        ),
                      ),
                      SizedBox(height: 20), // Space before log out button

                      // Log out button
                      ElevatedButton(
                        onPressed: () async {
                          // Handle log out
                          await FirebaseAuth.instance.signOut();
                          // Optionally, navigate to a login screen after sign out
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: Text('Log Out'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
