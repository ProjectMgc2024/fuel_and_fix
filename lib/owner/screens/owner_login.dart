import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fuel_and_fix/admin/screens/fuel.dart';
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
      } else if (_selectedService == 'Emergency') {
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
            opacity: 0.7,
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
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    filled: true,
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
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    filled: true,
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
                SizedBox(height: 20),
                // Confirm Password field
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
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
                SizedBox(height: 20),

                // Radio buttons for service selection
                Text(
                  'Choose Your Service',
                  style: TextStyle(fontSize: 18),
                ),
                RadioListTile<String>(
                  title: Text('Fuel'),
                  value: 'Fuel',
                  groupValue: _selectedService,
                  onChanged: (value) {
                    setState(() {
                      _selectedService = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: Text('Emergency'),
                  value: 'Emergency',
                  groupValue: _selectedService,
                  onChanged: (value) {
                    setState(() {
                      _selectedService = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: Text('Tow'),
                  value: 'Tow',
                  groupValue: _selectedService,
                  onChanged: (value) {
                    setState(() {
                      _selectedService = value;
                    });
                  },
                ),
                SizedBox(height: 20),

                // Register Button
                ElevatedButton(
                  onPressed: _registerServiceProvider,
                  child: Text('Register'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(150, 50),
                  ),
                ),
                SizedBox(height: 10),
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

class ServiceProviderDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Service Provider Dashboard'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          'Welcome to the Service Provider Dashboard!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
