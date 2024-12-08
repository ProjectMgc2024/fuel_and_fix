import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:fuel_and_fix/user/screens/edit_screen.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text(
          "Profile",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),

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
            final userPhoneno =
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
                      CircleAvatar(
                        radius: 50, // Size of the circle avatar
                        backgroundColor:
                            Colors.grey, // Background color of the circle
                        child: Icon(
                          Icons.person, // The profile icon
                          size: 60, // Size of the icon
                          color: Colors.black, // Icon color
                        ),
                      ),
                      SizedBox(
                          height: 40), // Space between icon and form fields

                      // Display username
                      Text(
                        'Username: $userName',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 20), // Space between username and email

                      // Display email
                      Text(
                        'Email: $userEmail',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(
                          height: 20), // Space between email and phone number

                      // Display phone number
                      Text(
                        'Phone Number: $userPhoneno',
                        style: TextStyle(
                          fontSize: 20,
                          // Similar weight to email

                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 20), // Space before log out button
                      // Edit Profile button
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to the EditProfileScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfile(),
                            ),
                          );
                        },
                        child: Text('Edit Profile'),
                      )
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
