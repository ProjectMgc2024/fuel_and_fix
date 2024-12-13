import 'package:flutter/material.dart';
import 'package:fuel_and_fix/owner/SERVICES/firebase_provider_auth.dart';
import 'package:fuel_and_fix/owner/screens/fuel/fuel_register.dart';
import 'package:fuel_and_fix/owner/screens/fuel/managefuel.dart';

// Add your screen here

class FuelLoginScreen extends StatefulWidget {
  @override
  _FuelLoginScreenState createState() => _FuelLoginScreenState();
}

class _FuelLoginScreenState extends State<FuelLoginScreen> {
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
          .fuelLogin(context: context, email: email, password: password);

      if (loginSuccess) {
        // Navigate to the normal user page if login is successful
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FuelManagement(),
          ),
        );
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
                        obscureText: !isPasswordVisible, // Toggle visibility
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
                                    builder: (context) => FuelRegister()));
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
