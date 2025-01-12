import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fuel_and_fix/user/screens/intro.dart';
import 'package:fuel_and_fix/user/screens/login_screen.dart';

import '../services/firebase_user_auth.dart';

class Register extends StatefulWidget {
  final String license;
  final String vehicleType;
  final String registration;
  const Register({
    super.key,
    required this.license,
    required this.vehicleType,
    required this.registration,
  });

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  // Text Editing Controllers
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  // Show/hide password toggle
  bool showPassword = true;
  bool showConfirmPassword = true;

  // Create a GlobalKey for the Form
  final _formKey = GlobalKey<FormState>();

  // Validation logic for the input fields
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    // Basic email format validation
    final emailRegExp =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Enter a valid email address';
    }

    return null; // Return null if validation is successful
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    } else if (value.length != 10) {
      return 'Phone number must be 10 digits';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm your password';
    } else if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  bool loading = false;

  // Form submit function
  void submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        loading = true;
      });
      print('Username: ${usernameController.text}');
      print('Password: ${passwordController.text}');
      print('Phone Number: ${phoneController.text}');

      await UserAuthServices().register(
        context: context,
        username: usernameController.text,
        phoneno: phoneController.text,
        email: emailController.text,
        password: passwordController.text,
        license: widget.license,
        registrationNo: widget.registration,
        vehicleType: widget.vehicleType,
      );

      setState(() {
        loading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Introscreen()),
      );
    } else {
      print('Form is not valid');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        // Make the screen scrollable
        child: Container(
          // Set the background image
          height:
              MediaQuery.of(context).size.height, // Ensure full screen height
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('asset/pic7.jpg'),
              opacity: 0.6, // Set your background image here
              fit: BoxFit
                  .cover, // This will make the image cover the entire screen
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    'Fuel & Fix assist system',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 0, 0, 0)),
                  ),
                  SizedBox(height: 20),
                  // Image (Centered below the text)
                  CircleAvatar(
                    backgroundImage: AssetImage('asset/car1.jpg'),
                    radius: 70, // Adjust the size of the image as needed
                  ),
                  SizedBox(height: 50), // Space between image and form

                  // Create an Account Title
                  Text(
                    'Create an Account',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  SizedBox(height: 20), // Space between title and form

                  // Form fields
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize
                          .min, // Adjust layout for centered content
                      children: [
                        SizedBox(height: 20),
                        // Username Field with fixed width
                        SizedBox(
                          width: 300, // Set the desired width here
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 244, 208, 147),
                                  Color.fromARGB(255, 131, 153, 214),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextFormField(
                              controller: usernameController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.transparent,
                                labelText: 'Username',
                                hintText: 'Enter username',
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1.0),
                                ),
                                border: OutlineInputBorder(),
                              ),
                              validator: validateUsername,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Phone Number Field with fixed width
                        SizedBox(
                          width: 300,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 244, 208, 147),
                                  Color.fromARGB(255, 131, 153, 214),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextFormField(
                              controller: phoneController,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.transparent,
                                labelText: 'Phone Number',
                                hintText: 'Enter phone number',
                                prefixIcon: Icon(
                                  Icons.phone,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1.0),
                                ),
                                border: OutlineInputBorder(),
                              ),
                              validator: validatePhoneNumber,
                              maxLength: 10,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: 300, // Set the desired width here
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 244, 208, 147),
                                  Color.fromARGB(255, 131, 153, 214),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.transparent,
                                labelText: 'Email',
                                hintText: 'Enter email',
                                prefixIcon: Icon(
                                  Icons.email,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1.0),
                                ),
                                border: OutlineInputBorder(),
                              ),
                              validator:
                                  validateEmail, // Attach the email validator
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
// Password Field with gradient background
                        SizedBox(
                          width: 300,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 244, 208, 147),
                                  Color.fromARGB(255, 131, 153, 214),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextFormField(
                              controller: passwordController,
                              obscureText: showPassword,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.transparent,
                                labelText: 'Password',
                                hintText: 'Enter password',
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    showPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      showPassword = !showPassword;
                                    });
                                  },
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1.0),
                                ),
                                border: OutlineInputBorder(),
                              ),
                              validator: validatePassword,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Confirm Password Field
                        SizedBox(
                          width: 300,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 244, 208, 147),
                                  Color.fromARGB(255, 131, 153, 214),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextFormField(
                              controller: confirmPasswordController,
                              obscureText: showConfirmPassword,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.transparent,
                                labelText: 'Confirm Password',
                                hintText: 'Re-enter password',
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    showConfirmPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      showConfirmPassword =
                                          !showConfirmPassword;
                                    });
                                  },
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1.0),
                                ),
                                border: OutlineInputBorder(),
                              ),
                              validator: validateConfirmPassword,
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        // Submit Button
                        SizedBox(
                          width: 200,
                          child: ElevatedButton(
                            onPressed: loading ? null : submitForm,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: Colors.blue,
                            ),
                            child: loading
                                ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    'Register',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Already have an account
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Already have an account? Login',
                            style: TextStyle(
                              color: Colors.black,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
