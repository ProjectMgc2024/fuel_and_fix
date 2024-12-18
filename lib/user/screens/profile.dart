import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuel_and_fix/user/screens/edit_screen.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(208, 131, 128, 154),
        elevation: 0,
        title: Text(
          "Profile",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: const Color.fromARGB(255, 0, 0, 0),
            fontFamily: 'Roboto', // Use custom font
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 233, 220, 200),
              const Color.fromARGB(234, 2, 189, 235)
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
              final location = profileData['location'] ?? 'unknown';
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Profile Image
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
                                  color: const Color.fromARGB(255, 0, 5, 10),
                                  border: Border.all(
                                    color:
                                        const Color.fromARGB(255, 47, 237, 4),
                                    width: 3,
                                  ),
                                ),
                                child: ColorFiltered(
                                  colorFilter: ColorFilter.mode(
                                    const Color.fromARGB(255, 84, 56, 56)
                                        .withOpacity(0.5),
                                    BlendMode.darken,
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
                      ),
                      SizedBox(height: 30),

                      // User Information Cards inside a Column for vertical alignment
                      Column(
                        children: [
                          _buildInfoCard(Icons.person, 'Username', userName),
                          _buildInfoCard(Icons.email, 'Email', userEmail),
                          _buildInfoCard(
                              Icons.phone, 'Phone Number', userPhoneno),
                          _buildInfoCard(
                              Icons.location_on, 'Location', location),
                          _buildInfoCard(
                              Icons.numbers, 'Registration No', registrationNo),
                          _buildInfoCard(
                              Icons.credit_card, 'License No', licenseNo),
                          _buildInfoCard(Icons.directions_car, 'Vehicle Type',
                              vehicleType),
                        ],
                      ),

                      // Edit Profile Button at the Bottom
                      SizedBox(height: 40),
                      ElevatedButton(
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
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 50),
                          shadowColor: const Color.fromARGB(255, 84, 119, 176),
                          elevation: 8,
                          textStyle: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        child: Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 25,
                            color: const Color.fromARGB(255, 239, 3, 3),
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

  // Helper method to build profile info cards
  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Container(
      width: 500, // Adjust the width to fit the design
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 6,
        color: const Color.fromARGB(255, 67, 119, 152),
        child: ListTile(
          leading: Icon(
            icon,
            color: const Color.fromARGB(255, 2, 9, 22),
            size: 30,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 179, 184, 193),
            ),
          ),
          subtitle: Text(
            value,
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
      ),
    );
  }
}
