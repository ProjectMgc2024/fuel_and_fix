import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../../../service/cloudinary.dart';

class TowProfilePage extends StatefulWidget {
  const TowProfilePage({super.key});

  @override
  _TowProfilePageState createState() => _TowProfilePageState();
}

class _TowProfilePageState extends State<TowProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String documentId = FirebaseAuth.instance.currentUser!.uid;
  late TextEditingController ownerNameController,
      companyNameController,
      companyLicenseController,
      phoneNoController;

  @override
  void initState() {
    super.initState();
    ownerNameController = TextEditingController();
    companyNameController = TextEditingController();
    companyLicenseController = TextEditingController();
    phoneNoController = TextEditingController();
  }

  @override
  void dispose() {
    ownerNameController.dispose();
    companyNameController.dispose();
    companyLicenseController.dispose();
    phoneNoController.dispose();
    super.dispose();
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
                    Image.network(managerData['companyLogo'],
                        height: 100, width: 100, fit: BoxFit.cover),
                  if (newLogoFile != null)
                    Image.file(newLogoFile!,
                        height: 100, width: 100, fit: BoxFit.cover),
                  TextButton(
                    onPressed: () async {
                      final pickedImage = await _pickImage();
                      if (pickedImage != null) {
                        setState(() => newLogoFile = pickedImage);
                      }
                    },
                    child: Text(
                        newLogoFile == null ? "Change Logo" : "Replace Logo"),
                  ),
                  ..._buildTextFields(),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel")),
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

  List<Widget> _buildTextFields() {
    return [
      _buildTextField(ownerNameController, 'Owner Name'),
      _buildTextField(companyNameController, 'Company Name'),
      _buildTextField(companyLicenseController, 'Company ID'),
      _buildTextField(phoneNoController, 'Phone Number'),
    ];
  }

  TextField _buildTextField(TextEditingController controller, String label) {
    return TextField(
        controller: controller, decoration: InputDecoration(labelText: label));
  }

  Future<File?> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  Future<String?> _uploadLogoToCloudinary(File image) async {
    final cloudinaryService = CloudinaryService(uploadPreset: 'towService');
    return await cloudinaryService.uploadImage(selectedImage: image);
  }

  void _updateManagerDetails({String? newLogoUrl}) async {
    final updateData = {
      'ownerName': ownerNameController.text,
      'phoneNo': phoneNoController.text,
      'companyName': companyNameController.text,
      'CompanyLicense': companyLicenseController.text,
    };
    if (newLogoUrl != null) updateData['companyLogo'] = newLogoUrl;
    await _firestore.collection('tow').doc(documentId).update(updateData);
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
              _buildTextField(employeeNameController, 'Employee Name'),
              _buildTextField(employeeEmailController, 'Employee Email'),
              _buildTextField(employeePhoneNoController, 'Employee Phone No'),
              _buildTextField(employeeRoleController, 'Employee Role'),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            TextButton(
              onPressed: () {
                _addEmployee(
                    employeeNameController.text,
                    employeeEmailController.text,
                    employeePhoneNoController.text,
                    employeeRoleController.text);
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
        await _firestore.collection('tow').doc(documentId).get();
    List employees = documentSnapshot.data()?['employees'] ?? [];
    employees.add({
      'employeeName': name,
      'employeeEmail': email,
      'employeePhoneNo': phoneNo,
      'employeeRole': role
    });
    await _firestore
        .collection('tow')
        .doc(documentId)
        .update({'employees': employees});
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
              _buildTextField(employeeNameController, 'Employee Name'),
              _buildTextField(employeeEmailController, 'Employee Email'),
              _buildTextField(employeePhoneNoController, 'Employee Phone No'),
              _buildTextField(employeeRoleController, 'Employee Role'),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text("Cancel")),
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
        await _firestore.collection('tow').doc(documentId).get();
    List employees = documentSnapshot.data()?['employees'] ?? [];
    employees[index] = updatedEmployee;
    await _firestore
        .collection('tow')
        .doc(documentId)
        .update({'employees': employees});
    setState(() {});
  }

  void _deleteEmployee(int index) async {
    // Show a confirmation dialog before deleting the employee
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Employee"),
          content: Text("Are you sure you want to delete this employee?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close the dialog
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                // Proceed with deleting the employee
                final documentSnapshot =
                    await _firestore.collection('tow').doc(documentId).get();
                List employees = documentSnapshot.data()?['employees'] ?? [];
                employees.removeAt(index);
                await _firestore
                    .collection('tow')
                    .doc(documentId)
                    .update({'employees': employees});
                setState(() {}); // Refresh the UI
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tow Profile")),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('tow').doc(documentId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data == null)
            return Center(child: Text("No data available"));

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
                        ? Image.network(managerDetails['companyLogo'],
                            width: 50, height: 50, fit: BoxFit.cover)
                        : Icon(Icons.business, size: 50),
                    title: Text('Company: ${managerDetails['companyName']}'),
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
                        onPressed: () =>
                            _showEditManagerDialog(managerDetails)),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Employees",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    ElevatedButton(
                      onPressed: _showAddEmployeeDialog,
                      child: Row(
                        children: [
                          Icon(Icons.person_add),
                          SizedBox(width: 8),
                          Text("Add Employee")
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
                                icon: Icon(Icons.edit),
                                onPressed: () =>
                                    _showEditEmployeeDialog(index, employee)),
                            IconButton(
                              icon: Icon(Icons.delete),
                              color: const Color.fromARGB(255, 198, 30, 18),
                              onPressed: () => _deleteEmployee(index),
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
