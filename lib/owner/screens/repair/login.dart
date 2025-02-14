import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fuel_and_fix/owner/SERVICES/firebase_provider_auth.dart';
import 'package:fuel_and_fix/owner/screens/repair/managerepair.dart';
import 'package:fuel_and_fix/owner/screens/repair/repair_register.dart';

class RepairLoginScreen extends StatefulWidget {
  @override
  _RepairLoginScreenState createState() => _RepairLoginScreenState();
}

class _RepairLoginScreenState extends State<RepairLoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Variable to manage password visibility
  bool isPasswordVisible = false;

  void login() async {
    if (_formKey.currentState!.validate()) {
      String email = emailController.text.trim();
      String password = passwordController.text.trim();

      print("$email $password");

      bool loginSuccess = await OwnerAuthServices()
          .repairLogin(context: context, email: email, password: password);

      if (loginSuccess) {
        // Query Firestore for the repair shop document matching the email
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('repair')
            .where('email', isEqualTo: email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          Map<String, dynamic> repairData =
              querySnapshot.docs.first.data() as Map<String, dynamic>;
          bool status = repairData['status'] ?? false;
          if (!status) {
            // If the shop is disabled, show error and do not navigate
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    "Your repair shop is disabled. Please contact the administrator."),
                backgroundColor: Colors.red,
              ),
            );
            return;
          } else {
            // If enabled, navigate to the management page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RepairManagementPage(),
              ),
            );
          }
        } else {
          // No document found: show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("No repair shop record found for this account."),
              backgroundColor: Colors.red,
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
              'asset/pic6.jpg', // Background image remains the same
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50.0,
                      backgroundColor: const Color.fromARGB(255, 30, 39, 46),
                      child: Icon(
                        Icons.person,
                        size: 60.0,
                        color: const Color.fromARGB(255, 197, 207, 211),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      'Repair Log In',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    SizedBox(height: 40.0),
                    SizedBox(
                      width: 300,
                      child: TextFormField(
                        controller: emailController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color.fromARGB(255, 146, 161, 222),
                          labelText: 'Email',
                          labelStyle: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(
                            Icons.email,
                            color: Colors.black,
                          ),
                          enabledBorder: OutlineInputBorder(
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
                    SizedBox(height: 16.0),
                    SizedBox(
                      width: 300,
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: !isPasswordVisible,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color.fromARGB(255, 146, 161, 222),
                          labelText: 'Password',
                          labelStyle: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Colors.black,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 1.0),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
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
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 3, 35, 153),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RepairRegister(),
                              ),
                            );
                          },
                          child: Text(
                            'Create an account',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 215, 33, 5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        elevation: 8.0,
                        shadowColor: const Color.fromARGB(255, 4, 0, 255),
                      ),
                      child: Text('Sign in'),
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
