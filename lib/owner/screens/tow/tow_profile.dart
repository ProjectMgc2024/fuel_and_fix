import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TowServicePerson {
  String name;
  String email;
  String phone;
  String role;
  String experience;
  String shiftTime;

  TowServicePerson({
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.experience,
    required this.shiftTime,
  });
}

class TowProfilePage extends StatefulWidget {
  @override
  _TowProfilePageState createState() => _TowProfilePageState();
}

class _TowProfilePageState extends State<TowProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late DocumentReference _towDoc;
  late CollectionReference _employeesCollection;

  late Map<String, dynamic> companyData;
  List<TowServicePerson> employees = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _cLicenseController = TextEditingController();

  dynamic _editingEmployee;
  bool _isManager = false;

  @override
  void initState() {
    super.initState();
    _towDoc = _firestore.collection('tow').doc(FirebaseAuth
        .instance.currentUser?.uid); // Document for specific Tow service
    _employeesCollection =
        _towDoc.collection('employees'); // Collection for employees
    _loadProfile();
  }

  // Load Tow service company and employees from Firestore
  Future<void> _loadProfile() async {
    try {
      final towSnapshot = await _towDoc.get();
      if (towSnapshot.exists) {
        setState(() {
          companyData = towSnapshot.data() as Map<String, dynamic>;
        });
      }

      final employeesSnapshot = await _employeesCollection.get();
      setState(() {
        employees = employeesSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return TowServicePerson(
            name: data['name'] ?? '',
            email: data['email'] ?? '',
            phone: data['phone'] ?? '',
            role: data['role'] ?? '',
            experience: data['experience'] ?? '',
            shiftTime: data['shiftTime'] ?? '',
          );
        }).toList();
      });
    } catch (e) {
      print("Error loading profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile data: $e')),
      );
    }
  }

  void _editProfile(dynamic person, {bool isManager = false}) {
    _editingEmployee = person;
    _isManager = isManager;

    _clearControllers();
    _populateControllers(isManager);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text(
            isManager ? 'Edit Tow Service Profile' : 'Edit Employee Profile',
            style: TextStyle(color: Colors.blueAccent),
          ),
          content: _buildDialogContent(isManager),
          actions: _buildDialogActions(),
        );
      },
    );
  }

  void _clearControllers() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _companyNameController.clear();
    _cLicenseController.clear();
  }

  void _populateControllers(bool isManager) {
    if (isManager) {
      _nameController.text = companyData['owner'] ?? '';
      _emailController.text = companyData['email'] ?? '';
      _phoneController.text = companyData['phoneNo'] ?? '';
      _companyNameController.text = companyData['companyName'] ?? '';
      _cLicenseController.text = companyData['clicense'] ?? '';
    } else {
      _nameController.text = _editingEmployee.name;
      _emailController.text = _editingEmployee.email;
      _phoneController.text = _editingEmployee.phone;
    }
  }

  Widget _buildDialogContent(bool isManager) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(_nameController, 'Name'),
          _buildTextField(_emailController, 'Email'),
          _buildTextField(_phoneController, 'Phone Number'),
          if (isManager) ...[
            _buildTextField(_companyNameController, 'Company Name'),
            _buildTextField(_cLicenseController, 'Company License'),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  List<Widget> _buildDialogActions() {
    return [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('Cancel', style: TextStyle(color: Colors.blue)),
      ),
      TextButton(
        onPressed: () async {
          setState(() {
            if (_isManager) {
              companyData['companyName'] = _companyNameController.text;
              companyData['email'] = _emailController.text;
              companyData['phoneNo'] = _phoneController.text;
              companyData['clicense'] = _cLicenseController.text;
              companyData['owner'] = _nameController.text;
              _towDoc.update(companyData);
            } else {
              _editingEmployee.name = _nameController.text;
              _editingEmployee.email = _emailController.text;
              _editingEmployee.phone = _phoneController.text;
              _employeesCollection.doc(_editingEmployee.email).update({
                'name': _editingEmployee.name,
                'email': _editingEmployee.email,
                'phone': _editingEmployee.phone,
              });
            }
          });
          Navigator.pop(context);
        },
        child: Text('Save', style: TextStyle(color: Colors.blue)),
      ),
    ];
  }

  void _deleteEmployee(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text('Delete Employee', style: TextStyle(color: Colors.red)),
          content: Text('Are you sure you want to delete this employee?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _employeesCollection
                      .doc(employees[index].email)
                      .delete();
                  setState(() {
                    employees.removeAt(index);
                  });
                } catch (e) {
                  print('Error deleting employee: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete employee: $e')),
                  );
                }
                Navigator.pop(context);
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
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
        title: Text('Tow Service Profile'),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Company Profile Section
            Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 5,
              child: ListTile(
                title: Text('Company Profile',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Text(
                  'Name: ${companyData['owner']}\nCompany Name: ${companyData['companyName']}\nEmail: ${companyData['email']}\nPhone: ${companyData['phoneNo']}\nLicense: ${companyData['clicense']}',
                  style: TextStyle(fontSize: 16),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editProfile(companyData, isManager: true),
                ),
              ),
            ),

            // Employee Section
            Text(
              'Employees',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 2, 52, 73)),
            ),
            for (int i = 0; i < employees.length; i++) ...[
              Card(
                margin: EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 5,
                child: ListTile(
                  title: Text(employees[i].name,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'Role: ${employees[i].role}\nEmail: ${employees[i].email}\nPhone: ${employees[i].phone}\nExperience: ${employees[i].experience}\nShift: ${employees[i].shiftTime}',
                    style: TextStyle(fontSize: 16),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editProfile(employees[i]),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteEmployee(i),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
