import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuel_and_fix/user/screens/edit_screen.dart';
import 'package:fuel_and_fix/user/screens/introduction.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 16, 122, 127),
        actions: [
          // Log out Icon Button in the AppBar
          IconButton(
            icon: const Icon(
              Icons.logout, // Log out icon
              color: Color.fromARGB(255, 98, 10, 10), // Icon color
            ),
            onPressed: () {
              // Navigate to Introduction Page and clear the navigation stack
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => IntroductionPage()),
                (route) => false, // Remove all routes
              );
            },
          ),
        ],
        elevation: 0,
        title: Text(
          "Profile",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        // Ensure the container fills the entire screen height
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.teal[100]!,
              Colors.blue[100]!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('user')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text("An error occurred: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data?.data() == null) {
              return Center(child: Text("No user data available"));
            } else {
              final profileData = snapshot.data!.data() as Map<String, dynamic>;
              final userEmail = profileData['email'] ?? 'noemail@gmail.com';
              final userPhoneno = profileData['phoneno'] ?? '999999999';
              final userName = profileData['username'] ?? 'Unknown';
              final licenseNo = profileData['license'] ?? 'KL000000';
              final registrationNo =
                  profileData['registrationNo'] ?? 'KL1399999';
              final vehicleType = profileData['vehicleType'];
              final userImage = profileData['userImage'] ??
                  'https://res.cloudinary.com/dnywnuawz/image/upload/v1734431780/public/fuel/imgcnbbfrovh3qjuqc7w.jpg';

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Profile Image with Shadow Effect
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfile(),
                              ),
                            );
                          },
                          child: Hero(
                            tag: 'profileImage',
                            child: ClipOval(
                              child: Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.teal,
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.network(
                                    userImage,
                                    width: 160,
                                    height: 160,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // User Name
                      Text(
                        userName,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),

                      // Profile Information Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileInfoRow(Icons.email, 'Email', userEmail),
                          Divider(thickness: 1, color: Colors.teal),
                          _buildProfileInfoRow(
                              Icons.phone, 'Phone', userPhoneno),
                          Divider(thickness: 1, color: Colors.teal),
                          _buildProfileInfoRow(Icons.card_travel,
                              'Registration No', registrationNo),
                          Divider(thickness: 1, color: Colors.teal),
                          _buildProfileInfoRow(
                              Icons.credit_card, 'License No', licenseNo),
                          Divider(thickness: 1, color: Colors.teal),
                          _buildProfileInfoRow(
                              Icons.card_travel, 'Vehicle Type', vehicleType),
                          Divider(thickness: 1, color: Colors.teal),
                        ],
                      ),

                      SizedBox(height: 40),

                      // Edit Profile Button with Gradient Background
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfile(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 10),
                          shadowColor: const Color.fromARGB(255, 255, 0, 0),
                          elevation: 8,
                          textStyle: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        icon: Icon(
                          Icons.edit,
                          size: 24,
                          color: const Color.fromARGB(255, 30, 0, 112),
                        ),
                        label: Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 20,
                            color: const Color.fromARGB(255, 0, 55, 143),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  // Helper method to build profile info rows with icons
  Widget _buildProfileInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.teal,
            size: 24,
          ),
          SizedBox(width: 10),
          Text(
            '$title: ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
