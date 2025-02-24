import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // For picking images
import 'package:cloudinary_public/cloudinary_public.dart'; // Cloudinary upload service

class CloudinaryService {
  final CloudinaryPublic cloudinary;
  CloudinaryService(
      {String cloudName = 'dnywnuawz', required String uploadPreset})
      : cloudinary = CloudinaryPublic(cloudName, uploadPreset, cache: false);

  Future<String?> uploadImage({required File? selectedImage}) async {
    if (selectedImage == null) {
      return null;
    }
    try {
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          selectedImage.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl; // Return the URL of the uploaded image
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}

class EditProfile extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<EditProfile> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController registrationController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final CloudinaryService cloudinaryService =
      CloudinaryService(uploadPreset: 'userimages'); // Pass your preset name

  File? _selectedImage; // For storing the selected image
  String? _imageUrl; // Store the image URL from Cloudinary
  String? selectedVehicleType; // Store the selected vehicle type

  // Fetch user data including the profile image URL
  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('user')
            .doc(user.uid)
            .get();

        if (snapshot.exists) {
          Map<String, dynamic> profileData =
              snapshot.data() as Map<String, dynamic>;

          setState(() {
            usernameController.text = profileData['username'] ?? '';
            phoneNumberController.text = profileData['phoneno'] ?? '';
            emailController.text = profileData['email'] ?? '';
            registrationController.text = profileData['registrationNo'] ?? '';
            licenseController.text = profileData['license'] ?? '';
            selectedVehicleType =
                profileData['vehicleType'] ?? ''; // Fetch the vehicleType
            _imageUrl = profileData['userImage']; // Load image URL
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error fetching profile data: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  // Custom phone number validator
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a Phone Number';
    }

    if (value.length != 10) {
      return 'Phone number must be exactly 10 digits';
    }
    // Regex allows an optional '+' and 10 to 15 digits.
    final RegExp phoneExp = RegExp(r'^\+?\d{10,15}$');
    if (!phoneExp.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  // Handle save button press
  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          // Upload image if selected
          String? imageUrl;
          if (_selectedImage != null) {
            imageUrl = await cloudinaryService.uploadImage(
                selectedImage: _selectedImage);
          }

          // Save data to Firestore
          await FirebaseFirestore.instance
              .collection('user')
              .doc(user.uid)
              .set({
            'username': usernameController.text.trim(),
            'phoneno': phoneNumberController.text.trim(),
            'email': emailController.text.trim(),
            'license': licenseController.text.trim(),
            'registrationNo': registrationController.text.trim(),
            'vehicleType':
                selectedVehicleType ?? '', // Save the selected vehicle type
            'userImage': imageUrl ?? _imageUrl, // Save image URL (new or old)
          }, SetOptions(merge: true));

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ));

          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('No user signed in. Please log in.'),
            backgroundColor: Colors.red,
          ));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error saving profile: $e'),
          backgroundColor: Colors.red,
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill in all the required fields.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Edit Profile'),
        backgroundColor: const Color.fromARGB(255, 71, 175, 207),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 233, 220, 200),
              const Color.fromARGB(234, 2, 189, 235),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      'Edit Your Profile',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    // Profile picture icon or selected image
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : (_imageUrl != null
                                ? NetworkImage(_imageUrl!)
                                : null),
                        backgroundColor: Colors.grey,
                        child: _selectedImage == null && _imageUrl == null
                            ? Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.black,
                              )
                            : null,
                      ),
                    ),
                    SizedBox(height: 20),
                    // Form fields (Username, Phone, etc.)
                    _buildTextFormField(
                        usernameController, 'Username', Icons.person),
                    _buildTextFormField(
                        phoneNumberController, 'Phone Number', Icons.phone,
                        validator: _validatePhoneNumber),
                    _buildTextFormField(
                        licenseController, 'License', Icons.card_membership),
                    _buildTextFormField(registrationController,
                        'Registration Number', Icons.details),
                    // Vehicle Type Dropdown
                    SizedBox(
                      width: 300,
                      child: DropdownButtonFormField<String>(
                        value: selectedVehicleType,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedVehicleType = newValue;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Vehicle Type',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.directions_car),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a vehicle type';
                          }
                          return null;
                        },
                        items: <String>['Car', 'Truck', 'Bike', 'Bus']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Save and Cancel buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _handleSave,
                          child: Text('Save'),
                        ),
                        SizedBox(width: 20),
                        OutlinedButton(
                          onPressed: _handleCancel,
                          child: Text('Cancel'),
                        ),
                      ],
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

  // Updated text field builder accepting an optional validator
  Widget _buildTextFormField(
      TextEditingController controller, String label, IconData icon,
      {String? Function(String?)? validator}) {
    return Container(
      width: 300,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          prefixIcon: Icon(icon),
        ),
        validator: validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a $label';
              }
              return null;
            },
      ),
    );
  }

  void _handleCancel() {
    setState(() {
      usernameController.clear();
      phoneNumberController.clear();
      emailController.clear();
      registrationController.clear();
      licenseController.clear();
      _selectedImage = null;
      selectedVehicleType = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Changes canceled.'),
      backgroundColor: Colors.red,
    ));
  }
}
