import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../SERVICES/firebase_provider_auth.dart';

class RepairRegister extends StatefulWidget {
  const RepairRegister({super.key});

  @override
  State<RepairRegister> createState() => _RepairRegisterState();
}

class _RepairRegisterState extends State<RepairRegister> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _companyLicenseController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController =
      TextEditingController();

  String? _currentLocation;
  double? _latitude;
  double? _longitude;
  String? _locationName;

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
        collection: 'repair',
        additionalData: {
          'latitude': _latitude,
          'longitude': _longitude,
          'location_name': _locationName,
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration Successful')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration Failed: $e')),
      );
    }
    Navigator.pop(context);
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        bool? userDecision = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Enable Location Services'),
            content: Text(
                'Location services are disabled. Please enable them to continue.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text('Enable'),
              ),
            ],
          ),
        );
        if (context.mounted) {
          if (userDecision == true) {
            await Geolocator.openLocationSettings();
          }
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location permissions are denied.')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Location permissions are permanently denied.')),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Fetch location name
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks.first;

      setState(() {
        _currentLocation = '${place.locality}, ${place.country}';
      });

      // Save location details
      _latitude = position.latitude;
      _longitude = position.longitude;
      _locationName = '${place.locality}, ${place.country}';
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location: $e')),
      );
    }
  }

  @override
  void dispose() {
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
          child: AppBar(
            title: const Text('Repair Register',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            centerTitle: true,
            backgroundColor: const Color.fromARGB(255, 178, 198, 143),
            elevation: 0,
            // Adding the back button in the app bar
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context); // Go back to the previous screen
              },
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 197, 174, 100),
              const Color.fromARGB(255, 184, 103, 76),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                SizedBox(height: 50),
                _buildTextField(_companyNameController, 'Company Name',
                    'Please enter company name', Icons.business),
                SizedBox(height: 20),
                _buildTextField(
                    _companyLicenseController,
                    'Company License No',
                    'Please enter company license number',
                    Icons.card_membership),
                SizedBox(height: 20),
                _buildTextField(_emailController, 'Email',
                    'Please enter a valid email', Icons.email,
                    email: true),
                SizedBox(height: 20),
                _buildTextField(_phoneController, 'Phone No',
                    'Please enter a valid phone number', Icons.phone,
                    phone: true),
                SizedBox(height: 20),
                _buildTextField(_ownerNameController, 'Owner Name',
                    'Please enter owner name', Icons.person),
                SizedBox(height: 30),
                _buildTextField(_passwordController, 'Password',
                    'Please enter password', Icons.lock,
                    password: true),
                SizedBox(height: 20),
                _buildTextField(_confirmpasswordController, 'Confirm Password',
                    'Please confirm your password', Icons.lock,
                    password: true, confirmPassword: true),
                _buildLocationField(),
                const SizedBox(height: 32),
                _buildRegisterButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      String validationMessage, IconData icon,
      {bool email = false,
      bool phone = false,
      bool password = false,
      bool confirmPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon,
              color: const Color.fromARGB(
                  255, 36, 29, 29)), // Icon color changed to grey
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          filled: true,
          fillColor: const Color.fromARGB(255, 220, 220, 140),
        ),
        obscureText: password || confirmPassword,
        keyboardType: phone
            ? TextInputType.phone
            : email
                ? TextInputType.emailAddress
                : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return validationMessage;
          }
          if (email && !RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
            return 'Please enter a valid email';
          }
          if (phone && !RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
            return 'Please enter a valid phone number';
          }
          if (confirmPassword && value != _passwordController.text) {
            return 'Passwords do not match';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildLocationField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            _currentLocation == null
                ? 'Location: Not Set'
                : 'Location: $_currentLocation',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color.fromARGB(255, 0, 0, 0)),
          ),
        ),
        IconButton(
          icon: Icon(Icons.location_on,
              color: const Color.fromARGB(
                  255, 6, 68, 175)), // Icon color changed to dark blue
          onPressed: _getCurrentLocation,
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 150,
        child: ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              registerHandling();
            }
          },
          child: const Text('Register', style: TextStyle(fontSize: 18)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          ),
        ),
      ),
    );
  }
}
