import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuel_and_fix/admin/screens/admin_home.dart';
import 'package:fuel_and_fix/user/screens/home_screen.dart';
import 'package:fuel_and_fix/user/screens/register_1.dart';
import 'package:fuel_and_fix/user/services/firebase_user_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Variables to manage password visibility and loading state
  bool isPasswordVisible = false;
  bool _isLoading = false;
  void login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Start loading
      });

      String email = emailController.text.trim().toLowerCase();
      String password = passwordController.text.trim();
      bool isAdmin = false;

      try {
        QuerySnapshot? userSnapshot;

        // Check if the user is in the admin collection
        final adminQuery = await FirebaseFirestore.instance
            .collection('admin')
            .where('email', isEqualTo: email)
            .get();

        if (adminQuery.docs.isNotEmpty) {
          print('User found in admin collection: $email');
          isAdmin = true; // User is an admin
        } else {
          print(
              'User not found in admin collection. Checking user collection.');

          // Check if the user is in the user collection
          final userQuery = await FirebaseFirestore.instance
              .collection('user')
              .where('email', isEqualTo: email)
              .get();

          if (userQuery.docs.isNotEmpty) {
            print('User found in user collection: $email');
            userSnapshot = userQuery;
          } else {
            // User not found in both admin and user collections
            setState(() {
              _isLoading = false;
            });
            print('User not found in both admin and user collections.');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'User not found in the database . Please recheck or sign up.'),
              ),
            );
            return;
          }
        }

        // Authenticate user
        print('Authenticating user with Firebase Authentication...');
        final userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        if (userCredential.user == null) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Authentication failed. Please try again.')),
          );
          return;
        }

        print('Login successful. Redirecting user...');
        setState(() {
          _isLoading = false; // Stop loading
        });

        // Navigate based on the user role
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => isAdmin ? AdminPage() : HomeScreen(),
          ),
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
        });
        // Handle Firebase authentication errors
        print('FirebaseAuthException: ${e.code}');
        final errorMessage = e.code == 'user-not-found'
            ? 'User not found. Please recheck or sign up.'
            : e.message ?? 'An error occurred.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        // Handle other errors
        print('Error during login: ${e.toString()}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: ${e.toString()}')),
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

          // Login Form or Loading Indicator
          Center(
            child: _isLoading
                ? CircularProgressIndicator(
                    color: Colors.blueAccent,
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50.0,
                            backgroundColor:
                                const Color.fromARGB(255, 30, 39, 46),
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
                                fillColor:
                                    const Color.fromARGB(255, 146, 161, 222),
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
                              decoration: InputDecoration(
                                filled: true,
                                fillColor:
                                    const Color.fromARGB(255, 146, 161, 222),
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
                                          builder: (context) =>
                                              const VehicleRegistrationPage()));
                                },
                                child: Text(
                                  'Create an account',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        const Color.fromARGB(255, 215, 33, 5),
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
