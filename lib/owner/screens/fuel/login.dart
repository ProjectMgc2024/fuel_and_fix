import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuel_and_fix/owner/SERVICES/firebase_provider_auth.dart';
import 'package:fuel_and_fix/owner/screens/fuel/fuel_register.dart';
import 'package:fuel_and_fix/owner/screens/fuel/managefuel.dart';

class FuelLoginScreen extends StatefulWidget {
  @override
  _FuelLoginScreenState createState() => _FuelLoginScreenState();
}

class _FuelLoginScreenState extends State<FuelLoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Variables to manage password visibility and loading state
  bool isPasswordVisible = false;
  bool isLoading = false;

  void login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      String email = emailController.text.trim();
      String password = passwordController.text.trim();

      bool loginSuccess = await OwnerAuthServices()
          .fuelLogin(context: context, email: email, password: password);

      if (loginSuccess) {
        // Get the current Firebase user
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Retrieve user document from Firestore (assuming collection 'fuelOwners')
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('fuel')
              .doc(user.uid)
              .get();

          bool disabled =
              (userDoc.data() as Map<String, dynamic>)['disabled'] ?? false;

          if (disabled) {
            // If account is disabled, sign out and show a message
            await FirebaseAuth.instance.signOut();
            setState(() {
              isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Your account has been disabled"),
                backgroundColor: Colors.redAccent,
                duration: Duration(seconds: 2),
              ),
            );
            return;
          } else {
            setState(() {
              isLoading = false;
            });
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => FuelManagement()),
            );
          }
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login failed. Please check your credentials."),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 2),
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
              color: const Color.fromARGB(255, 171, 185, 219).withOpacity(0.4),
            ),
          ),

          // Login Form
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
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
                        'Fuel Log In',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: Colors.black,
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
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
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
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color.fromARGB(255, 146, 161, 222),
                            labelText: 'Password',
                            labelStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
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
                                    builder: (context) => FuelRegister()),
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
                      isLoading
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: login,
                              style: ElevatedButton.styleFrom(
                                elevation: 8.0,
                                shadowColor:
                                    const Color.fromARGB(255, 4, 0, 255),
                                minimumSize: Size(150, 50),
                              ),
                              child: Text('Sign in'),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
