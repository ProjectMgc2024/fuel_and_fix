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

  // Manager Edit Dialog using Form and scrollable AlertDialog
  void _showEditManagerDialog(Map<String, dynamic> managerData) async {
    File? newLogoFile;
    ownerNameController.text = managerData['ownerName'] ?? '';
    companyNameController.text = managerData['companyName'] ?? '';
    companyLicenseController.text = managerData['companyLicense'] ?? '';
    phoneNoController.text = managerData['phoneNo'] ?? '';

    final GlobalKey<FormState> _managerFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            scrollable: true, // Makes the dialog scrollable to avoid overflow
            title: Text("Edit Manager Details"),
            content: Form(
              key: _managerFormKey,
              child: Column(
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
                        setState(() => newLogoFile = pickedImage);
                      }
                    },
                    child: Text(
                        newLogoFile == null ? "Change Logo" : "Replace Logo"),
                  ),
                  TextFormField(
                    controller: ownerNameController,
                    decoration: InputDecoration(labelText: 'Owner Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter owner name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: companyNameController,
                    decoration: InputDecoration(labelText: 'Company Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter company name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: companyLicenseController,
                    decoration: InputDecoration(labelText: 'Company ID'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter company ID';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: phoneNoController,
                    decoration: InputDecoration(labelText: 'Phone Number'),
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter phone number';
                      }
                      if (value.length != 10) {
                        return 'Phone number must be exactly 10 digits';
                      }
                      if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                        return 'Enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel")),
              TextButton(
                onPressed: () async {
                  if (_managerFormKey.currentState!.validate()) {
                    String? newLogoUrl;
                    if (newLogoFile != null) {
                      newLogoUrl = await _uploadLogoToCloudinary(newLogoFile!);
                    }
                    _updateManagerDetails(newLogoUrl: newLogoUrl);
                    Navigator.pop(context);
                  }
                },
                child: Text("Save"),
              ),
            ],
          );
        });
      },
    );
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
      'companyLicense': companyLicenseController.text,
    };
    if (newLogoUrl != null) updateData['companyLogo'] = newLogoUrl;
    await _firestore.collection('tow').doc(documentId).update(updateData);
    setState(() {});
  }

  // Employee Add Dialog using Form and validations for email and phone
  void _showAddEmployeeDialog() {
    final GlobalKey<FormState> _employeeFormKey = GlobalKey<FormState>();
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
          content: Form(
            key: _employeeFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: employeeNameController,
                  decoration: InputDecoration(labelText: 'Employee Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter employee name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: employeeEmailController,
                  decoration: InputDecoration(labelText: 'Employee Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter employee email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: employeePhoneNoController,
                  decoration: InputDecoration(labelText: 'Employee Phone No'),
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    if (value.length != 10) {
                      return 'Phone number must be exactly 10 digits';
                    }
                    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                      return 'Enter a valid phone number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: employeeRoleController,
                  decoration: InputDecoration(labelText: 'Employee Role'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter employee role';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            TextButton(
              onPressed: () {
                if (_employeeFormKey.currentState!.validate()) {
                  _addEmployee(
                    employeeNameController.text,
                    employeeEmailController.text,
                    employeePhoneNoController.text,
                    employeeRoleController.text,
                  );
                  Navigator.pop(context);
                }
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
      'employeeRole': role,
    });
    await _firestore
        .collection('tow')
        .doc(documentId)
        .update({'employees': employees});
    setState(() {});
  }

  // Employee Edit Dialog using Form with validations; email is preserved and not editable.
  void _showEditEmployeeDialog(int index, Map<String, dynamic> employeeData) {
    final GlobalKey<FormState> _editEmployeeFormKey = GlobalKey<FormState>();
    final TextEditingController employeeNameController =
        TextEditingController(text: employeeData['employeeName']);
    final TextEditingController employeePhoneNoController =
        TextEditingController(text: employeeData['employeePhoneNo']);
    final TextEditingController employeeRoleController =
        TextEditingController(text: employeeData['employeeRole']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Employee"),
          content: Form(
            key: _editEmployeeFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: employeeNameController,
                  decoration: InputDecoration(labelText: 'Employee Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter employee name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: employeePhoneNoController,
                  decoration: InputDecoration(labelText: 'Employee Phone No'),
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    if (value.length != 10) {
                      return 'Phone number must be exactly 10 digits';
                    }
                    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                      return 'Enter a valid phone number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: employeeRoleController,
                  decoration: InputDecoration(labelText: 'Employee Role'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter employee role';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            TextButton(
              onPressed: () {
                if (_editEmployeeFormKey.currentState!.validate()) {
                  _updateEmployee(index, {
                    'employeeName': employeeNameController.text,
                    'employeePhoneNo': employeePhoneNoController.text,
                    'employeeRole': employeeRoleController.text,
                    // Preserve the original email since it is not editable.
                    'employeeEmail': employeeData['employeeEmail'],
                  });
                  Navigator.pop(context);
                }
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Employee"),
          content: Text("Are you sure you want to delete this employee?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final documentSnapshot =
                    await _firestore.collection('tow').doc(documentId).get();
                List employees = documentSnapshot.data()?['employees'] ?? [];
                employees.removeAt(index);
                await _firestore
                    .collection('tow')
                    .doc(documentId)
                    .update({'employees': employees});
                setState(() {});
                Navigator.pop(context);
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
      appBar: AppBar(
        title: Text("Tow Profile",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 187, 210, 250),
        elevation: 8.0,
      ),
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
            'companyLicense': data['companyLicense'],
            'companyLogo': data['companyLogo']
          };
          final employees =
              List<Map<String, dynamic>>.from(data['employees'] ?? []);

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Manager Card
                Card(
                  margin: EdgeInsets.only(bottom: 16.0),
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color.fromARGB(255, 187, 210, 250),
                          const Color.fromARGB(255, 131, 115, 154)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: managerDetails['companyLogo'] != null
                          ? Image.network(managerDetails['companyLogo'],
                              width: 50, height: 50, fit: BoxFit.cover)
                          : Icon(Icons.business, size: 50, color: Colors.black),
                      title: Text('Company: ${managerDetails['companyName']}',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Owner: ${managerDetails['ownerName']}',
                              style: TextStyle(color: Colors.black87)),
                          Text('License: ${managerDetails['companyLicense']}',
                              style: TextStyle(color: Colors.black87)),
                          Text('Email: ${managerDetails['email']}',
                              style: TextStyle(color: Colors.black87)),
                          Text('Phone: ${managerDetails['phoneNo']}',
                              style: TextStyle(color: Colors.black87)),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.edit,
                            color: const Color.fromARGB(255, 8, 8, 129)),
                        onPressed: () => _showEditManagerDialog(managerDetails),
                      ),
                    ),
                  ),
                ),
                // Employees Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Employees",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 7, 59, 85))),
                    ElevatedButton(
                      onPressed: _showAddEmployeeDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 50, 78, 181),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.person_add, color: Colors.white),
                          SizedBox(width: 8),
                          Text("Add Employee",
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
                // Employee List
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final employee = employees[index];
                    return Card(
                      margin: EdgeInsets.only(top: 8.0),
                      elevation: 5.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text('Name: ${employee['employeeName']}',
                            style: TextStyle(fontWeight: FontWeight.bold)),
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
                              icon: Icon(Icons.edit, color: Colors.blueAccent),
                              onPressed: () =>
                                  _showEditEmployeeDialog(index, employee),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
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
