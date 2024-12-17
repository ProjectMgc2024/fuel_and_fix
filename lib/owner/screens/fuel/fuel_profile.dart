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
    companyNameController = TextEditingController(); // Initialize
    companyLicenseController = TextEditingController(); // Initialize
  }

  @override
  void dispose() {
    ownerNameController.dispose();
    emailController.dispose();
    phoneNoController.dispose();
    companyNameController.dispose(); // Dispose
    companyLicenseController.dispose(); // Dispose
    super.dispose();
  }

  void _showAddFuelDialog() {
    final TextEditingController fuelTypeController = TextEditingController();
    final TextEditingController fuelPriceController = TextEditingController();

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
              TextField(
                controller: fuelPriceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
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
                _addFuel(fuelTypeController.text, fuelPriceController.text);
                Navigator.pop(context);
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _addFuel(String type, String price) async {
    final documentSnapshot =
        await _firestore.collection('fuel').doc(documentId).get();
    List fuels = documentSnapshot.data()?['fuels'] ?? [];
    fuels.add({'type': type, 'price': double.parse(price)});

    await _firestore.collection('fuel').doc(documentId).update({
      'fuels': fuels,
    });
    setState(() {});
  }

  void _showEditFuelDialog(int index, Map<String, dynamic> fuelData) {
    final TextEditingController fuelTypeController =
        TextEditingController(text: fuelData['type']);
    final TextEditingController fuelPriceController =
        TextEditingController(text: fuelData['price'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Fuel"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fuelTypeController,
                decoration: InputDecoration(labelText: 'Fuel Type'),
              ),
              TextField(
                controller: fuelPriceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
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
                _updateFuel(index, {
                  'type': fuelTypeController.text,
                  'price': double.parse(fuelPriceController.text),
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
                    decoration: InputDecoration(labelText: 'Company ID'),
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
      'CompanyLicense': companyLicenseController.text,
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
            'CompanyLicense': data['CompanyLicense'],
            'companyLogo': data['companyLogo']
          };
          final employees =
              List<Map<String, dynamic>>.from(data['employees'] ?? []);

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  margin: EdgeInsets.only(bottom: 16.0),
                  child: ListTile(
                    leading: managerDetails['companyLogo'] != null
                        ? Image.network(
                            managerDetails['companyLogo'],
                            width: 50, // Adjust width as needed
                            height: 50, // Adjust height as needed
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.error),
                          )
                        : Icon(Icons.business,
                            size: 50), // Placeholder if no logo is available
                    title:
                        Text('Company Name ${managerDetails['companyName']}'),
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
                      icon: Icon(Icons.edit),
                      onPressed: () => _showEditManagerDialog(managerDetails),
                    ),
                  ),
                ),
                // Fuel Section
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Fuels",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton.icon(
                            onPressed: _showAddFuelDialog,
                            icon: Icon(Icons.local_gas_station),
                            label: Text("Add Fuel"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: data['fuels']?.length ?? 0,
                        itemBuilder: (context, index) {
                          final fuel = data['fuels'][index];
                          return Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        fuel['type'],
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text("Price: ${fuel['price']}"),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit,
                                            color: Colors.blue),
                                        onPressed: () =>
                                            _showEditFuelDialog(index, fuel),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () => _deleteFuel(index),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween, // Adjust alignment as needed
                  children: [
                    Text(
                      "Employees",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: _showAddEmployeeDialog,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color.fromARGB(194, 105, 47, 47),
                        backgroundColor: Colors.blue, // Text color
                        padding: EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12), // Padding
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(8), // Rounded corners
                        ),
                        elevation: 4, // Shadow effect
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize
                            .min, // Ensures button size fits its content
                        children: [
                          Icon(
                            Icons.person_add, // Icon to display
                            size: 18, // Icon size
                            color: Colors.white, // Icon color
                          ),
                          SizedBox(width: 8), // Space between icon and text
                          Text(
                            "Add Employee",
                            style: TextStyle(
                              fontSize: 16, // Font size
                              fontWeight: FontWeight.bold, // Font weight
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final employee = employees[index];
                    return Card(
                      margin: EdgeInsets.only(top: 8.0),
                      child: ListTile(
                        title: Text('Name : ${employee['employeeName']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email : ${employee['employeeEmail']}'),
                            Text('Role: ${employee['employeeRole']}'),
                            Text('Phone: ${employee['employeePhoneNo']}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () =>
                                  _showEditEmployeeDialog(index, employee),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: const Color.fromARGB(255, 198, 30, 18),
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text("Delete Employee"),
                                      content: Text(
                                          "Are you sure you want to delete this employee?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            _deleteEmployee(index);
                                            Navigator.pop(context);
                                          },
                                          child: Text("Delete"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
