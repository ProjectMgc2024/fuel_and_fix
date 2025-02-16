import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../../../service/cloudinary.dart';

class FuelProfilePage extends StatefulWidget {
  const FuelProfilePage({super.key});

  @override
  FuelProfilePageState createState() => FuelProfilePageState();
}

class FuelProfilePageState extends State<FuelProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String documentId = FirebaseAuth.instance.currentUser!.uid;

  late TextEditingController ownerNameController;
  late TextEditingController emailController;
  late TextEditingController phoneNoController;
  late TextEditingController companyNameController;
  late TextEditingController companyLicenseController;

  @override
  void initState() {
    super.initState();
    ownerNameController = TextEditingController();
    emailController = TextEditingController();
    phoneNoController = TextEditingController();
    companyNameController = TextEditingController();
    companyLicenseController = TextEditingController();
  }

  @override
  void dispose() {
    ownerNameController.dispose();
    emailController.dispose();
    phoneNoController.dispose();
    companyNameController.dispose();
    companyLicenseController.dispose();
    super.dispose();
  }

  void _showAddFuelDialog() {
    final TextEditingController fuelTypeController = TextEditingController();
    // Remove the unused fuelPriceController; we will fetch the price automatically
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Fuel"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fuelTypeController,
                decoration: InputDecoration(labelText: 'Fuel Type'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _addFuel(fuelTypeController.text);
                Navigator.pop(context);
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  /// Adds a new fuel entry.
  /// The method now fetches the current global price for the given fuel type
  /// from the "price" collection (document "fuelPrices").
  void _addFuel(String type) async {
    double globalPrice = 0.0;
    DocumentSnapshot priceDoc =
        await _firestore.collection('price').doc('fuelPrices').get();
    if (priceDoc.exists) {
      Map<String, dynamic> priceData = priceDoc.data() as Map<String, dynamic>;
      // Use the lowercase fuel type to match the key in the price document
      globalPrice = priceData[type.toLowerCase()]?.toDouble() ?? 0.0;
    }

    final documentSnapshot =
        await _firestore.collection('fuel').doc(documentId).get();
    List fuels = documentSnapshot.data()?['fuels'] ?? [];
    fuels.add({
      'type': type,
      'price': globalPrice,
    });

    await _firestore.collection('fuel').doc(documentId).update({
      'fuels': fuels,
    });
    setState(() {});
  }

  void _updateFuel(int index, Map<String, dynamic> updatedFuel) async {
    final documentSnapshot =
        await _firestore.collection('fuel').doc(documentId).get();
    List fuels = documentSnapshot.data()?['fuels'] ?? [];
    fuels[index] = updatedFuel;

    await _firestore.collection('fuel').doc(documentId).update({
      'fuels': fuels,
    });
    setState(() {});
  }

  void _deleteFuel(int index) async {
    final documentSnapshot =
        await _firestore.collection('fuel').doc(documentId).get();
    List fuels = documentSnapshot.data()?['fuels'] ?? [];
    fuels.removeAt(index);

    await _firestore.collection('fuel').doc(documentId).update({
      'fuels': fuels,
    });
    setState(() {});
  }

  void _showEditManagerDialog(Map<String, dynamic> managerData) async {
    File? newLogoFile;
    ownerNameController.text = managerData['ownerName'];
    companyNameController.text = managerData['companyName'];
    companyLicenseController.text = managerData['CompanyLicense'] ?? '';
    phoneNoController.text = managerData['phoneNo'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Edit Manager Details"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (managerData['companyLogo'] != null && newLogoFile == null)
                    Image.network(
                      managerData['companyLogo'],
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.error),
                    ),
                  if (newLogoFile != null)
                    Image.file(
                      newLogoFile!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  TextButton(
                    onPressed: () async {
                      final pickedImage = await _pickImage();
                      if (pickedImage != null) {
                        setState(() {
                          newLogoFile = pickedImage;
                        });
                      }
                    },
                    child: Text(
                        newLogoFile == null ? "Change Logo" : "Replace Logo"),
                  ),
                  TextField(
                    controller: ownerNameController,
                    decoration: InputDecoration(labelText: 'Owner Name'),
                  ),
                  TextField(
                    controller: companyNameController,
                    decoration: InputDecoration(labelText: 'Company Name'),
                  ),
                  TextField(
                    controller: companyLicenseController,
                    decoration: InputDecoration(labelText: 'Company licence'),
                  ),
                  TextField(
                    controller: phoneNoController,
                    decoration: InputDecoration(labelText: 'Phone Number'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    String? newLogoUrl;
                    if (newLogoFile != null) {
                      newLogoUrl = await _uploadLogoToCloudinary(newLogoFile!);
                    }
                    _updateManagerDetails(newLogoUrl: newLogoUrl);
                    Navigator.pop(context);
                  },
                  child: Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<File?> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  Future<String?> _uploadLogoToCloudinary(File image) async {
    final cloudinaryService = CloudinaryService(uploadPreset: 'fuelservice');
    return await cloudinaryService.uploadImage(selectedImage: image);
  }

  void _updateManagerDetails({String? newLogoUrl}) async {
    final updateData = {
      'ownerName': ownerNameController.text,
      'phoneNo': phoneNoController.text,
      'companyName': companyNameController.text,
      'companyLicense': companyLicenseController.text,
    };

    if (newLogoUrl != null) {
      updateData['companyLogo'] = newLogoUrl;
    }

    await _firestore.collection('fuel').doc(documentId).update(updateData);
    setState(() {});
  }

  void _showAddEmployeeDialog() {
    final TextEditingController employeeNameController =
        TextEditingController();
    final TextEditingController employeeEmailController =
        TextEditingController();
    final TextEditingController employeePhoneNoController =
        TextEditingController();
    final TextEditingController employeeRoleController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Employee"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: employeeNameController,
                decoration: InputDecoration(labelText: 'Employee Name'),
              ),
              TextField(
                controller: employeeEmailController,
                decoration: InputDecoration(labelText: 'Employee Email'),
              ),
              TextField(
                controller: employeePhoneNoController,
                decoration: InputDecoration(labelText: 'Employee Phone No'),
              ),
              TextField(
                controller: employeeRoleController,
                decoration: InputDecoration(labelText: 'Employee Role'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _addEmployee(
                  employeeNameController.text,
                  employeeEmailController.text,
                  employeePhoneNoController.text,
                  employeeRoleController.text,
                );
                Navigator.pop(context);
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _addEmployee(
      String name, String email, String phoneNo, String role) async {
    final documentSnapshot =
        await _firestore.collection('fuel').doc(documentId).get();
    List employees = documentSnapshot.data()?['employees'] ?? [];
    employees.add({
      'employeeName': name,
      'employeeEmail': email,
      'employeePhoneNo': phoneNo,
      'employeeRole': role,
    });

    await _firestore.collection('fuel').doc(documentId).update({
      'employees': employees,
    });
    setState(() {});
  }

  void _showEditEmployeeDialog(int index, Map<String, dynamic> employeeData) {
    final TextEditingController employeeNameController =
        TextEditingController(text: employeeData['employeeName']);
    final TextEditingController employeeEmailController =
        TextEditingController(text: employeeData['employeeEmail']);
    final TextEditingController employeePhoneNoController =
        TextEditingController(text: employeeData['employeePhoneNo']);
    final TextEditingController employeeRoleController =
        TextEditingController(text: employeeData['employeeRole']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Employee"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: employeeNameController,
                decoration: InputDecoration(labelText: 'Employee Name'),
              ),
              TextField(
                controller: employeeEmailController,
                decoration: InputDecoration(labelText: 'Employee Email'),
              ),
              TextField(
                controller: employeePhoneNoController,
                decoration: InputDecoration(labelText: 'Employee Phone No'),
              ),
              TextField(
                controller: employeeRoleController,
                decoration: InputDecoration(labelText: 'Employee Role'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _updateEmployee(index, {
                  'employeeName': employeeNameController.text,
                  'employeeEmail': employeeEmailController.text,
                  'employeePhoneNo': employeePhoneNoController.text,
                  'employeeRole': employeeRoleController.text,
                });
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _updateEmployee(int index, Map<String, dynamic> updatedEmployee) async {
    final documentSnapshot =
        await _firestore.collection('fuel').doc(documentId).get();
    List employees = documentSnapshot.data()?['employees'] ?? [];
    employees[index] = updatedEmployee;

    await _firestore.collection('fuel').doc(documentId).update({
      'employees': employees,
    });
    setState(() {});
  }

  void _deleteEmployee(int index) async {
    final documentSnapshot =
        await _firestore.collection('fuel').doc(documentId).get();
    List employees = documentSnapshot.data()?['employees'] ?? [];
    employees.removeAt(index);

    await _firestore.collection('fuel').doc(documentId).update({
      'employees': employees,
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fuel Profile"),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 209, 147, 24),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('fuel').doc(documentId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text("No data available"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final managerDetails = {
            'ownerName': data['ownerName'],
            'email': data['email'],
            'phoneNo': data['phoneNo'],
            'companyName': data['companyName'],
            'CompanyLicense': data['companyLicense'],
            'companyLogo': data['companyLogo']
          };
          final employees =
              List<Map<String, dynamic>>.from(data['employees'] ?? []);
          final fuels = List<Map<String, dynamic>>.from(data['fuels'] ?? []);

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Manager Section
                _buildSectionHeader(
                    title: "Company Details",
                    icon: Icons.business,
                    color: Colors.deepPurple),
                Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 6.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ListTile(
                    leading: managerDetails['companyLogo'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              managerDetails['companyLogo'],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(Icons.business, size: 50, color: Colors.orange),
                    title: Text(
                      managerDetails['companyName'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Owner: ${managerDetails['ownerName']}'),
                        Text('License: ${managerDetails['CompanyLicense']}'),
                        Text('Email: ${managerDetails['email']}'),
                        Text('Phone: ${managerDetails['phoneNo']}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.edit, color: Colors.deepPurple),
                      onPressed: () => _showEditManagerDialog(managerDetails),
                    ),
                  ),
                ),
                // Fuels Section
                _buildSectionHeader(
                    title: "Fuels",
                    icon: Icons.local_gas_station,
                    color: Colors.orange),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 4.5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: fuels.length,
                  itemBuilder: (context, index) {
                    final fuel = fuels[index];
                    return _buildFuelCard(fuel, index);
                  },
                ),
                SizedBox(height: 8),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _showAddFuelDialog,
                    icon: Icon(Icons.add, size: 18),
                    label: Text("Add Fuel"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                // Employees Section
                _buildSectionHeader(
                    title: "Employees", icon: Icons.group, color: Colors.blue),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final employee = employees[index];
                    return _buildEmployeeCard(employee, index);
                  },
                ),
                SizedBox(height: 8),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _showAddEmployeeDialog,
                    icon: Icon(Icons.person_add, size: 18),
                    label: Text("Add Employee"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper Methods
  Widget _buildSectionHeader(
      {required String title, required IconData icon, required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFuelCard(Map<String, dynamic> fuel, int index) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 219, 160, 51),
              Color.fromARGB(255, 216, 197, 85)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fuel['type'],
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple),
                  ),
                  Text("Price: ${fuel['price']}"),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteFuel(index),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeCard(Map<String, dynamic> employee, int index) {
    return Card(
      margin: EdgeInsets.only(top: 8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 151, 176, 165),
              Color.fromARGB(222, 196, 196, 227)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: ListTile(
          title: Text('Name: ${employee['employeeName']}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email: ${employee['employeeEmail']}'),
              Text('Role: ${employee['employeeRole']}'),
              Text('Phone: ${employee['employeePhoneNo']}'),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.deepPurple),
                onPressed: () => _showEditEmployeeDialog(index, employee),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteEmployee(index),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
