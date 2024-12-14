import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Employee {
  String name;
  String email;
  String phone;
  String role;
  String experience;
  String shiftTime;
  List<String> skills;

  Employee({
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.experience,
    required this.shiftTime,
    required this.skills,
  });
}

class RepairProfilePage extends StatefulWidget {
  @override
  _RepairProfilePageState createState() => _RepairProfilePageState();
}

class _RepairProfilePageState extends State<RepairProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late DocumentReference _repairProfileDoc;
  late CollectionReference _employeeCollection;

  late Map<String, dynamic> managerData;
  List<Employee> employees = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _shiftController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _workshopNameController = TextEditingController();
  final TextEditingController _clicenseController = TextEditingController();

  dynamic _editingPerson;
  bool _isManager = false;

  @override
  void initState() {
    super.initState();
    _repairProfileDoc = _firestore
        .collection('repair')
        .doc(FirebaseAuth.instance.currentUser?.uid);
    _employeeCollection = _repairProfileDoc.collection('employees');
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      // Load Manager Data
      final managerSnapshot = await _repairProfileDoc.get();
      if (managerSnapshot.exists) {
        setState(() {
          managerData = managerSnapshot.data() as Map<String, dynamic>;
        });
      }

      // Load Employee Data
      final employeeSnapshot = await _employeeCollection.get();
      setState(() {
        employees = employeeSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Employee(
            name: data['name'] ?? '',
            email: data['email'] ?? '',
            phone: data['phone'] ?? '',
            role: data['role'] ?? '',
            experience: data['experience'] ?? '',
            shiftTime: data['shiftTime'] ?? '',
            skills: List<String>.from(data['skills'] ?? []),
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

  // Edit profile (manager or employee)
  void _editProfile(dynamic person, {bool isManager = false}) {
    _editingPerson = person;
    _isManager = isManager;

    _clearControllers();
    _populateControllers(isManager);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            isManager ? 'Edit Manager Profile' : 'Edit Employee Profile',
            style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
          ),
          content: _buildDialogContent(isManager),
          actions: _buildDialogActions(),
        );
      },
    );
  }

  // Clear the controllers
  void _clearControllers() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _roleController.clear();
    _experienceController.clear();
    _shiftController.clear();
    _skillsController.clear();
    _workshopNameController.clear();
    _clicenseController.clear();
  }

  // Populate the controllers with data from either manager or employee
  void _populateControllers(bool isManager) {
    if (isManager) {
      _nameController.text = managerData['owner'] ?? '';
      _emailController.text = managerData['email'] ?? '';
      _phoneController.text = managerData['phoneNo'] ?? '';
      _workshopNameController.text = managerData['companyName'] ?? '';
      _clicenseController.text = managerData['clicense'] ?? '';
    } else {
      _nameController.text = _editingPerson.name;
      _emailController.text = _editingPerson.email;
      _phoneController.text = _editingPerson.phone;
      _roleController.text = _editingPerson.role;
      _experienceController.text = _editingPerson.experience;
      _shiftController.text = _editingPerson.shiftTime;
      _skillsController.text = _editingPerson.skills.join(', ');
    }
  }

  // Build dialog content for editing
  Widget _buildDialogContent(bool isManager) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(_nameController, 'Name'),
          _buildTextField(_emailController, 'Email'),
          _buildTextField(_phoneController, 'Phone Number'),
          if (!isManager) ...[
            // Employee specific fields
            _buildTextField(_roleController, 'Role'),
            _buildTextField(_shiftController, 'Shift Time'),
            _buildTextField(_skillsController, 'Skills (comma separated)'),
          ],
          if (isManager) ...[
            // Manager specific fields
            _buildTextField(_workshopNameController, 'Workshop Name'),
            _buildTextField(_clicenseController, 'Licence Number'),
          ]
        ],
      ),
    );
  }

  // Build a text field
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

  // Build actions for saving or canceling the edit
  List<Widget> _buildDialogActions() {
    return [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('Cancel', style: TextStyle(color: Colors.blue)),
      ),
      TextButton(
        onPressed: () async {
          if (_isManager) {
            if (_validateManagerForm()) {
              try {
                // Save changes to Firestore
                await _repairProfileDoc.update({
                  'owner': _nameController.text,
                  'email': _emailController.text,
                  'phoneNo': _phoneController.text,
                  'companyName': _workshopNameController.text,
                  'clicense': _clicenseController.text,
                });

                // Directly update local state (managerData)
                setState(() {
                  managerData['owner'] = _nameController.text;
                  managerData['email'] = _emailController.text;
                  managerData['phoneNo'] = _phoneController.text;
                  managerData['companyName'] = _workshopNameController.text;
                  managerData['clicense'] = _clicenseController.text;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Manager profile updated successfully')),
                );
              } catch (e) {
                print("Error saving manager data: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to save manager data')),
                );
              }
            }
          } else {
            if (_validateEmployeeForm()) {
              try {
                // Save changes to Firestore
                await _employeeCollection.doc(_editingPerson.email).update({
                  'name': _nameController.text,
                  'email': _emailController.text,
                  'phone': _phoneController.text,
                  'role': _roleController.text,
                  'shiftTime': _shiftController.text,
                  'skills': _skillsController.text.split(', '),
                  'experience': _experienceController.text,
                });

                // Update the local employee list directly
                setState(() {
                  final index = employees
                      .indexWhere((e) => e.email == _editingPerson.email);
                  if (index != -1) {
                    employees[index] = Employee(
                      name: _nameController.text,
                      email: _emailController.text,
                      phone: _phoneController.text,
                      role: _roleController.text,
                      experience: _experienceController.text,
                      shiftTime: _shiftController.text,
                      skills: _skillsController.text.split(', '),
                    );
                  }
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Employee profile updated successfully')),
                );
              } catch (e) {
                print("Error saving employee data: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to save employee data')),
                );
              }
            }
          }
          Navigator.pop(context);
        },
        child: Text('Save', style: TextStyle(color: Colors.teal)),
      ),
    ];
  }

  // Form validation for manager
  bool _validateManagerForm() {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _workshopNameController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('All fields must be filled')));
      return false;
    }
    return true;
  }

  // Form validation for employee
  bool _validateEmployeeForm() {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _roleController.text.isEmpty ||
        _shiftController.text.isEmpty ||
        _skillsController.text.isEmpty ||
        _experienceController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('All fields must be filled')));
      return false;
    }
    return true;
  }

  // Delete employee
  void _deleteEmployee(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                  await _employeeCollection
                      .doc(employees[index].email)
                      .delete();
                  setState(() {
                    employees.removeAt(index);
                  });
                } catch (e) {
                  print('Error deleting employee: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete employee: $e')));
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
        title: Text('Repair Workshop Profile'),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildManagerProfileCard(),
            SizedBox(height: 20),
            _buildEmployeeSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildManagerProfileCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: ListTile(
        title: Text(
          'Manager Profile',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
        ),
        subtitle: Text(
          'Name: ${managerData['owner']}\nEmail: ${managerData['email']}\nPhone: ${managerData['phoneNo']}\nWorkshop: ${managerData['companyName']} \nlicense: ${managerData['clicense']}',
          style: TextStyle(fontSize: 16),
        ),
        trailing: IconButton(
          icon: Icon(Icons.edit, color: Colors.teal),
          onPressed: () => _editProfile(managerData, isManager: true),
        ),
      ),
    );
  }

  Widget _buildEmployeeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Employees',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
        ),
        SizedBox(height: 10),
        for (int i = 0; i < employees.length; i++) ...[
          // Loop through employees
          _buildEmployeeCard(employees[i], i),
        ],
      ],
    );
  }

  Widget _buildEmployeeCard(Employee employee, int index) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: ListTile(
        title: Text(employee.name,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(
          'Role: ${employee.role}\nExperience: ${employee.experience}\nShift: ${employee.shiftTime}\nSkills: ${employee.skills.join(', ')}',
          style: TextStyle(fontSize: 16),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.teal),
              onPressed: () => _editProfile(employee),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteEmployee(index),
            ),
          ],
        ),
      ),
    );
  }
}
