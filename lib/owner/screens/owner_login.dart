import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fuel_and_fix/owner/screens/managefuel.dart';
import 'package:fuel_and_fix/owner/screens/managerepair.dart';
import 'package:fuel_and_fix/owner/screens/managetow.dart';

class ServiceProviderRegisterPage extends StatefulWidget {
  @override
  _ServiceProviderRegisterPageState createState() =>
      _ServiceProviderRegisterPageState();
}

class _ServiceProviderRegisterPageState
    extends State<ServiceProviderRegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController =
      TextEditingController(); // New controller for confirming password
  final _formKey = GlobalKey<FormState>();

  // New variable to store the selected service
  String? _selectedService;

  void _registerServiceProvider() async {
    if (_formKey.currentState?.validate() ?? false) {
      print('email: ${_emailController.text}');
      print('Password: ${_passwordController.text}');
      print(
          'Selected Service: $_selectedService'); // Print the selected service

      // Check if passwords match
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Passwords do not match")),
        );
        return;
      }

      // Proceed with the registration logic
      await FirebaseFirestore.instance.collection('service_providers').add({
        'email': _emailController.text,
        'password':
            _passwordController.text, // Store password in a secure manner
        'service': _selectedService,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Navigate based on the selected service
      if (_selectedService == 'Fuel') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => FuelManagement()),
          (Route<dynamic> route) => false, // Removes all the previous routes
        );
      } else if (_selectedService == 'Repair') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => RepairManagementPage()),
          (Route<dynamic> route) => false,
        );
      } else if (_selectedService == 'Tow') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => TowManagementPage()),
          (Route<dynamic> route) => false,
        );
      } else {
        // Handle the case where no service is selected
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select a service")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('asset/pic4.jpg'),
            fit: BoxFit.cover,
            opacity: 0.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Service Provider Registration',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 60),
                Container(
                  width: 400,
                  child: TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      filled: true,
                      prefixIcon: Icon(Icons.mail),
                      fillColor: const Color.fromARGB(255, 181, 180, 180),
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 20),
                // Email TextField with reduced width
                Container(
                  width: 400, // You can change this width to your preference
                  child: TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      filled: true,
                      prefixIcon: Icon(Icons.password),
                      fillColor: const Color.fromARGB(255, 181, 180, 180),
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 20),
                // Confirm Password field
                Container(
                  width: 400,
                  child: TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.password_outlined),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 181, 180, 180),
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 30),

                // Custom Radio buttons for service selection
                Text(
                  'Choose Your Service',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                // Container for radio button options
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedService = 'Fuel';
                        });
                      },
                      child: Card(
                        elevation: 5,
                        color: _selectedService == 'Fuel'
                            ? Colors.green[200]
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.local_gas_station,
                                color: _selectedService == 'Fuel'
                                    ? Colors.white
                                    : Colors.black,
                                size: 40,
                              ),
                              Text(
                                'Fuel',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _selectedService == 'Fuel'
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedService = 'Repair';
                        });
                      },
                      child: Card(
                        elevation: 5,
                        color: _selectedService == 'Repair'
                            ? Colors.red[200]
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.build,
                                color: _selectedService == 'Repair'
                                    ? Colors.white
                                    : Colors.black,
                                size: 40,
                              ),
                              Text(
                                'Repair',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _selectedService == 'Repair'
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedService = 'Tow';
                        });
                      },
                      child: Card(
                        elevation: 5,
                        color: _selectedService == 'Tow'
                            ? Colors.blue[200]
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.directions_car,
                                color: _selectedService == 'Tow'
                                    ? Colors.white
                                    : Colors.black,
                                size: 40,
                              ),
                              Text(
                                'Tow',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _selectedService == 'Tow'
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),

                // Register Button
                ElevatedButton(
                  onPressed: _registerServiceProvider,
                  child: Text(
                    'Register',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 201, 202, 201)),
                  ),
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(100, 50),
                      backgroundColor: const Color.fromARGB(255, 59, 126, 133)),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    // Navigate to a Forgot Password page if implemented
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text("Forgot Password feature not implemented"),
                      ),
                    );
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 254, 0, 0),
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
