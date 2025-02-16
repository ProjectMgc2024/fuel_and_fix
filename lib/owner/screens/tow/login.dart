import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fuel_and_fix/owner/SERVICES/firebase_provider_auth.dart';
import 'package:fuel_and_fix/owner/screens/tow/managetow.dart';
import 'package:fuel_and_fix/owner/screens/tow/tow_register.dart';

class TowLoginScreen extends StatefulWidget {
  @override
  _TowLoginScreenState createState() => _TowLoginScreenState();
}

class _TowLoginScreenState extends State<TowLoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Variable to manage password visibility
  bool isPasswordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() async {
    if (_formKey.currentState!.validate()) {
      String email = emailController.text.trim();
      String password = passwordController.text.trim();

      // Attempt to log in using the provided credentials
      bool loginSuccess = await OwnerAuthServices().towLogin(
        context: context,
        email: email,
        password: password,
      );

      if (loginSuccess) {
        // Query Firestore for the tow account based on email
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('tow')
            .where('email', isEqualTo: email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          var userData =
              querySnapshot.docs.first.data() as Map<String, dynamic>;
          bool isApproved = userData['isApproved'] ?? false;

          if (isApproved) {
            // If isApproved is true, do not proceed to the management page.
            // Show a SnackBar message to inform the user.
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Your tow shop is disabled. Please contact the administrator.'),
                backgroundColor: Colors.redAccent,
                duration: Duration(seconds: 2),
              ),
            );
            return;
          } else {
            // If isApproved is false, navigate to the TowManagementPage.
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TowManagementPage(),
              ),
            );
          }
        } else {
          // No account data found in Firestore.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Account data not found.'),
              backgroundColor: Colors.redAccent,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'asset/pic6.jpg', // Background image for Tow login
              fit: BoxFit.cover,
            ),
          ),
          // Dark Overlay Effect
          Positioned.fill(
            child: Container(
              color: const Color.fromARGB(255, 171, 185, 219)
                  .withOpacity(0.4), // Darken effect
            ),
          ),
          // Login Form
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50.0,
                      backgroundColor: const Color.fromARGB(255, 30, 39, 46),
                      child: Icon(
                        Icons.person, // Icon representing a tow operator
                        size: 60.0,
                        color: const Color.fromARGB(255, 197, 207, 211),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    const Text(
                      'Tow Log In',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 40.0),
                    SizedBox(
                      width: 300,
                      child: TextFormField(
                        controller: emailController,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color.fromARGB(255, 146, 161, 222),
                          labelText: 'Email',
                          labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(
                            Icons.email,
                            color: Colors.black,
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(width: 1.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: 300,
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: !isPasswordVisible,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color.fromARGB(255, 146, 161, 222),
                          labelText: 'Password',
                          labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Colors.black,
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(width: 1.0),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 3, 35, 153),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to the tow registration screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TowRegister(),
                              ),
                            );
                          },
                          child: const Text(
                            'Create an account',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 215, 33, 5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        elevation: 8.0,
                        shadowColor: const Color.fromARGB(255, 4, 0, 255),
                      ),
                      child: const Text('Sign in'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
