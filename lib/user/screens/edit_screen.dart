import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfile extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<EditProfile> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // Key to manage form validation

  // Fetch the current user data
  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Fetch user data from Firestore
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('user')
            .doc(user.uid)
            .get();

        if (snapshot.exists) {
          Map<String, dynamic> profileData =
              snapshot.data() as Map<String, dynamic>;

          // Set the controllers with existing data
          setState(() {
            usernameController.text = profileData['username'] ?? '';
            phoneNumberController.text = profileData['phoneno'] ?? '';
            emailController.text = profileData['email'] ?? '';
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error fetching profile data: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  // Handle save button press
  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Get current user
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          // Show loading indicator while updating
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Updating profile...'),
            backgroundColor: Colors.blue,
          ));

          // Save data to Firestore
          await FirebaseFirestore.instance
              .collection('user')
              .doc(user.uid) // Use user's UID to update their specific document
              .set({
            'username': usernameController.text.trim(),
            'phoneno': phoneNumberController.text.trim(),
            'email': emailController.text.trim(),
          }, SetOptions(merge: true));

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ));
        } else {
          // If user is not authenticated
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('No user signed in. Please log in.'),
            backgroundColor: Colors.red,
          ));
        }
      } catch (e) {
        // If error occurs while saving to Firestore
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error saving profile: $e'),
          backgroundColor: Colors.red,
        ));
      }
    } else {
      // Show error message if form is invalid
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill in all the required fields.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  // Handle cancel button press
  void _handleCancel() {
    // Reset fields
    setState(() {
      usernameController.clear();
      phoneNumberController.clear();
      emailController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Changes canceled.'),
      backgroundColor: const Color.fromARGB(255, 234, 206, 206),
    ));
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data when the screen is loaded
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Go back to the previous screen when back arrow is tapped
            Navigator.pop(context);
          },
        ),
        title: Text('Edit Profile'),
        backgroundColor: const Color.fromARGB(255, 200, 190, 190),
      ),
      body: Center(
        // Center the content within the screen
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey, // Attach form key for validation
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center the form vertically
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Center the form horizontally
              children: [
                // Text above the profile icon
                Text(
                  'Your Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20), // Space between text and icon

                // Profile picture icon
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
                SizedBox(height: 40), // Space between icon and form fields

                Container(
                  width: 300,
                  // Username Field (Editable with validation)
                  child: TextFormField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a username';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: 300,
                  // Phone Number Field (Editable with validation)
                  child: TextFormField(
                    controller: phoneNumberController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a phone number';
                      }
                      // Regex for phone number validation (simple 10 digit validation)
                      String pattern = r'^[0-9]{10}$';
                      RegExp regex = RegExp(pattern);
                      if (!regex.hasMatch(value)) {
                        return 'Please enter a valid 10-digit phone number';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: 300,
                  // Email Field (Editable with validation)
                  child: TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      if (!RegExp(r'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 30),

                // Save and Cancel buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _handleSave,
                      child: Text('Save'),
                    ),
                    SizedBox(width: 20), // Space between buttons
                    OutlinedButton(
                      onPressed: _handleCancel,
                      child: Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
