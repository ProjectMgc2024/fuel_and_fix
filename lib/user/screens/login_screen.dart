import 'package:flutter/material.dart';
import 'package:fuel_and_fix/admin/screens/admin_home.dart';
import 'package:fuel_and_fix/user/screens/register.dart';
import 'package:fuel_and_fix/user/screens/second.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Variable to manage password visibility
  bool isPasswordVisible = false;

  // Admin credentials (you can change these as needed)
  final String adminUsername = "admin";
  final String adminPassword = "admin123";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'asset/pic6.jpg',
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
                      'Log In',
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
                        controller: usernameController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Username',
                          labelStyle: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(
                            Icons.person,
                            color: Colors.black,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 1.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
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
                        obscureText: !isPasswordVisible, // Toggle visibility
                        decoration: InputDecoration(
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
                                    builder: (context) => const Register()));
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
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          String username = usernameController.text;
                          String password = passwordController.text;

                          // Check if the entered username and password match the admin credentials
                          if (username == "admin@example.com" &&
                              password == "admin123") {
                            // Navigate to the admin page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      AdminPage()), // Replace with your admin page widget
                            );
                          } else {
                            // Proceed to normal screen if not admin
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      VehicleRegistrationPage()),
                            );
                          }
                        }
                      },
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
