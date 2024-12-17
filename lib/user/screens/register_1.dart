import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import this package for FilteringTextInputFormatter
import 'package:fuel_and_fix/user/screens/register_2.dart';

import 'login_screen.dart';

class VehicleRegistrationPage extends StatefulWidget {
  const VehicleRegistrationPage({Key? key}) : super(key: key);

  @override
  _VehicleRegistrationPageState createState() =>
      _VehicleRegistrationPageState();
}

class _VehicleRegistrationPageState extends State<VehicleRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _vehicleTypeController = TextEditingController();
  final TextEditingController _registrationController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _licenceNumberController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('asset/pic7.jpg'), // Ensure the correct path
            fit: BoxFit.cover, // Ensures the image covers the entire screen
            opacity: 0.3, // Optional: makes the image slightly transparent
          ),
        ),
        child: Center(
          // Center the form on the screen
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize
                      .min, // Minimize space, center items vertically
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 20),

                    // Title placed just above the form fields
                    const Text(
                      'Please Register Your Vehicle',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Vehicle Type Input
                    SizedBox(
                      width: 400,
                      child: TextFormField(
                        controller: _vehicleTypeController,
                        decoration: const InputDecoration(
                          labelText: 'Vehicle Type',
                          border: OutlineInputBorder(),
                          prefixIcon:
                              Icon(Icons.directions_car), // Vehicle icon
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a vehicle type';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: 400,
                      // Registration Number Input (Alphanumeric allowed)
                      child: TextFormField(
                        controller: _registrationController,
                        decoration: const InputDecoration(
                          labelText: 'Registration Number',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(
                              Icons.confirmation_number), // Registration icon
                        ),
                        keyboardType: TextInputType
                            .text, // Allows both letters and numbers
                        inputFormatters: [
                          // Custom input formatter to allow alphanumeric characters
                          FilteringTextInputFormatter.allow(RegExp(
                              '[a-zA-Z0-9]*')), // Fixed regex to allow alphanumeric characters
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a registration number';
                          }
                          // Ensure it contains both letters and numbers
                          if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*[0-9])')
                              .hasMatch(value)) {
                            return 'Registration number must contain both letters and numbers';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    // License Number Input (Alphanumeric allowed)
                    SizedBox(
                      width: 400,
                      child: TextFormField(
                        controller: _licenceNumberController,
                        decoration: const InputDecoration(
                          labelText: 'License Number',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.credit_card), // License icon
                        ),
                        keyboardType: TextInputType
                            .text, // Allows both letters and numbers
                        inputFormatters: [
                          // Custom input formatter to allow alphanumeric characters
                          FilteringTextInputFormatter.allow(RegExp(
                              '[a-zA-Z0-9]*')), // Fixed regex to allow alphanumeric characters
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a license number';
                          }
                          // Ensure it contains both letters and numbers
                          if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*[0-9])')
                              .hasMatch(value)) {
                            return 'License number must contain both letters and numbers';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Location Input
                    SizedBox(
                      width: 400,
                      child: TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on), // Location icon
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a location';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Register Button with normal size
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          // If the form is valid, show a Snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Vehicle Registered!')),
                          );
                          // Navigate to the next screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Register(
                                      location: _locationController.text,
                                      license: _licenceNumberController.text,
                                      registration:
                                          _registrationController.text,
                                      vehicleType: _vehicleTypeController.text,
                                    )), // Replace `NextScreen` with the name of your next screen widget
                          );
                        }
                      },
                      child: const Text('Next'),
                      style: ElevatedButton.styleFrom(
                        elevation: 10, // Shadow depth
                        shadowColor: const Color.fromARGB(255, 0, 0, 0)
                            .withOpacity(0.9), // Shadow color and opacity
                        textStyle: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Add a TextButton to navigate to the login screen
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                        );
                      },
                      child: Text(
                        'Already have an account? Log in',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
