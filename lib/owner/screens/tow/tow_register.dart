import 'package:flutter/material.dart';

import '../../SERVICES/firebase_provider_auth.dart';

class TowRegister extends StatefulWidget {
  const TowRegister({super.key});

  @override
  State<TowRegister> createState() => _TowRegisterState();
}

class _TowRegisterState extends State<TowRegister> {
  final _formKey = GlobalKey<FormState>(); // Key for form validation

  // TextEditingController for each input field
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _companyLicenseController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController =
      TextEditingController();

  Future<void> registerHandling() async {
    try {
      await OwnerAuthServices().register(
        context: context,
        email: _emailController.text,
        password: _passwordController.text,
        phNo: _phoneController.text,
        ownerName: _ownerNameController.text,
        cname: _companyNameController.text,
        clicense: _companyLicenseController.text,
        collection: 'tow',
      );
      // Show success message or navigate to another page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration Successful')),
      );
    } catch (e) {
      // Handle errors, show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration Failed: $e')),
      );
    }
    Navigator.pop(context);
  }

  @override
  void dispose() {
    // Dispose of controllers when the widget is disposed
    _companyNameController.dispose();
    _companyLicenseController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ownerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromARGB(
                    255, 129, 186, 85), // Start color (top left)
                const Color.fromARGB(
                    255, 74, 204, 119), // End color (bottom right)
              ],
            ),
          ),
          child: AppBar(
            title: const Text('Tow Register'),
            centerTitle: true,
            backgroundColor:
                Colors.transparent, // Make AppBar background transparent
            elevation: 0, // Remove AppBar's shadow
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 129, 186, 85), // Start color (top left)
              const Color.fromARGB(
                  255, 73, 124, 186), // End color (bottom right)
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Align(
                  alignment: Alignment
                      .center, // You can align it left, center, or right
                  child: SizedBox(
                    width: 400, // Adjust this value for the desired width
                    child: // Company Name Field
                        TextFormField(
                      controller: _companyNameController,
                      decoration: const InputDecoration(
                        labelText: 'Company Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter company name';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Align(
                  alignment: Alignment
                      .center, // You can align it left, center, or right
                  child: SizedBox(
                    width: 400, // Adjust this value for the desired width
                    child: // Company License Number Field
                        TextFormField(
                      controller: _companyLicenseController,
                      decoration: const InputDecoration(
                        labelText: 'Company License No',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter company license number';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Align(
                  alignment: Alignment
                      .center, // You can align it left, center, or right
                  child: SizedBox(
                    width: 400, // Adjust this value for the desired width
                    child: // Email Field
                        TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email';
                        }
                        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Align(
                  alignment: Alignment
                      .center, // You can align it left, center, or right
                  child: SizedBox(
                    width: 400, // Adjust this value for the desired width
                    child: // Phone Number Field
                        TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone No',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter phone number';
                        }
                        if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Align(
                  alignment: Alignment
                      .center, // You can align it left, center, or right
                  child: SizedBox(
                    width: 400, // Adjust this value for the desired width
                    child: // Owner Name Field
                        TextFormField(
                      controller: _ownerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Owner Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter owner name';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Align(
                  alignment: Alignment
                      .center, // You can align it left, center, or right
                  child: SizedBox(
                    width: 400, // Adjust this value for the desired width
                    child: // Password Field
                        TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Align(
                  alignment: Alignment
                      .center, // You can align it left, center, or right
                  child: SizedBox(
                    width: 400, // Adjust this value for the desired width
                    child: // Confirm Password Field
                        TextFormField(
                      controller: _confirmpasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Register Button
                // Reduced width for Register Button

                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 150, // Fixed width for the button
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          if (_passwordController.text ==
                              _confirmpasswordController.text) {
                            registerHandling();
                          } else {
                            // Show an alert or message if passwords don't match
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Passwords do not match')),
                            );
                          }
                        }
                      },
                      child: const Text('Register'),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 16),
                          backgroundColor:
                              const Color.fromARGB(255, 150, 188, 241)),
                    ),
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
