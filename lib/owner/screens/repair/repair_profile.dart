import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Employee {
  String id;
  String name;
  String email;
  String phone;
  String role;
  String experience;
  String shiftTime;
  List<String> skills;

  Employee({
    required this.id,
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

  // Add controllers for new employee data
  final TextEditingController _newNameController = TextEditingController();
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _newPhoneController = TextEditingController();
  final TextEditingController _newRoleController = TextEditingController();
  final TextEditingController _newExperienceController =
      TextEditingController();
  final TextEditingController _newShiftController = TextEditingController();
  final TextEditingController _newSkillsController = TextEditingController();

  dynamic managerData;
  List<Employee> employees = [];

  @override
  void initState() {
    super.initState();
    _repairProfileDoc = _firestore
        .collection('repair')
        .doc(FirebaseAuth.instance.currentUser?.uid);
    _employeeCollection = _repairProfileDoc.collection('employees');
    _loadProfile();
    _loadEmployees();
  }

  // Load Manager Data
  Future<void> _loadProfile() async {
    try {
      final managerSnapshot = await _repairProfileDoc.get();
      if (managerSnapshot.exists) {
        setState(() {
          managerData = managerSnapshot.data() as Map<String, dynamic>;
        });
      }
    } catch (e) {
      print("Error loading profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile data: $e')),
      );
    }
  }

  // Load Employees from Firestore
  Future<void> _loadEmployees() async {
    try {
      QuerySnapshot snapshot = await _employeeCollection.get();
      setState(() {
        employees = snapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return Employee(
            id: doc.id,
            name: data['name'],
            email: data['email'],
            phone: data['phone'],
            role: data['role'],
            experience: data['experience'],
            shiftTime: data['shiftTime'],
            skills: List<String>.from(data['skills']),
          );
        }).toList();
      });
    } catch (e) {
      print("Error loading employees: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load employees: $e')),
      );
    }
  }

  // Show the dialog for adding a new employee
  void _showAddEmployeeDialog() {
    _clearNewEmployeeControllers();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            'Add New Employee',
            style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
          ),
          content: _buildAddEmployeeDialogContent(),
          actions: _buildAddEmployeeDialogActions(),
        );
      },
    );
  }

  // Clear new employee form fields
  void _clearNewEmployeeControllers() {
    _newNameController.clear();
    _newEmailController.clear();
    _newPhoneController.clear();
    _newRoleController.clear();
    _newExperienceController.clear();
    _newShiftController.clear();
    _newSkillsController.clear();
  }

  // Build the dialog content for adding a new employee
  Widget _buildAddEmployeeDialogContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(_newNameController, 'Name'),
          _buildTextField(_newEmailController, 'Email'),
          _buildTextField(_newPhoneController, 'Phone Number'),
          _buildTextField(_newRoleController, 'Role'),
          _buildTextField(_newExperienceController, 'Experience'),
          _buildTextField(_newShiftController, 'Shift Time'),
          _buildTextField(_newSkillsController, 'Skills (comma separated)'),
        ],
      ),
    );
  }

  // Build the dialog actions for saving or canceling
  List<Widget> _buildAddEmployeeDialogActions() {
    return [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('Cancel', style: TextStyle(color: Colors.blue)),
      ),
      TextButton(
        onPressed: () async {
          if (_validateNewEmployeeForm()) {
            try {
              // Save new employee to Firestore
              await _employeeCollection.add({
                'name': _newNameController.text,
                'email': _newEmailController.text,
                'phone': _newPhoneController.text,
                'role': _newRoleController.text,
                'experience': _newExperienceController.text,
                'shiftTime': _newShiftController.text,
                'skills': _newSkillsController.text.split(', '),
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Employee added successfully')),
              );

              // Reload the employee data after saving
              _loadEmployees();
            } catch (e) {
              print("Error adding employee: $e");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to add employee')),
              );
            }
            Navigator.pop(context);
          }
        },
        child: Text('Save', style: TextStyle(color: Colors.teal)),
      ),
    ];
  }

  // Form validation for new employee
  bool _validateNewEmployeeForm() {
    if (_newNameController.text.isEmpty ||
        _newEmailController.text.isEmpty ||
        _newPhoneController.text.isEmpty ||
        _newRoleController.text.isEmpty ||
        _newExperienceController.text.isEmpty ||
        _newShiftController.text.isEmpty ||
        _newSkillsController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('All fields must be filled')));
      return false;
    }
    return true;
  }

  // Build the text field widget
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

  // Add "Add Employee" button in the UI
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
        ElevatedButton(
          onPressed: _showAddEmployeeDialog, // Show the Add Employee dialog
          child: Text('Add Employee'),
          style: ElevatedButton.styleFrom(),
        ),
        SizedBox(height: 20),
        // Display the list of employees with edit and delete icons
        ...employees.map((employee) {
          return ListTile(
            title: Text(employee.name),
            subtitle: Text(employee.role),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.teal),
                  onPressed: () => _showEditEmployeeDialog(employee),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteEmployee(employee.id),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  // Show the dialog for editing an existing employee
  void _showEditEmployeeDialog(Employee employee) {
    _newNameController.text = employee.name;
    _newEmailController.text = employee.email;
    _newPhoneController.text = employee.phone;
    _newRoleController.text = employee.role;
    _newExperienceController.text = employee.experience;
    _newShiftController.text = employee.shiftTime;
    _newSkillsController.text = employee.skills.join(', ');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            'Edit Employee',
            style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
          ),
          content: _buildAddEmployeeDialogContent(),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () async {
                if (_validateNewEmployeeForm()) {
                  try {
                    // Update the employee document in Firestore
                    await _employeeCollection.doc(employee.id).update({
                      'name': _newNameController.text,
                      'email': _newEmailController.text,
                      'phone': _newPhoneController.text,
                      'role': _newRoleController.text,
                      'experience': _newExperienceController.text,
                      'shiftTime': _newShiftController.text,
                      'skills': _newSkillsController.text.split(', '),
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Employee updated successfully')),
                    );

                    // Reload the employee data after updating
                    _loadEmployees();
                  } catch (e) {
                    print("Error updating employee: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update employee')),
                    );
                  }
                  Navigator.pop(context);
                }
              },
              child: Text('Save', style: TextStyle(color: Colors.teal)),
            ),
          ],
        );
      },
    );
  }

  // Delete an employee from Firestore with confirmation
  void _deleteEmployee(String employeeId) async {
    // Show confirmation dialog before deleting
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            'Confirm Deletion',
            style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
          ),
          content: Text('Are you sure you want to delete this employee?'),
          actions: [
            TextButton(
              onPressed: () {
                // Cancel the deletion and close the dialog
                Navigator.pop(context);
              },
              child: Text('Cancel', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () async {
                // Proceed with the deletion
                try {
                  await _employeeCollection.doc(employeeId).delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Employee deleted successfully')),
                  );

                  // Reload the employee data after deleting
                  _loadEmployees();
                } catch (e) {
                  print("Error deleting employee: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete employee')),
                  );
                }
                // Close the dialog
                Navigator.pop(context);
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Manager Profile Card
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

  // Edit Profile Logic
  void _editProfile(dynamic data, {bool isManager = false}) {
    // Implement your edit profile logic here
    // Similar to the add/edit employee process.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Repair Profile"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildManagerProfileCard(),
            _buildEmployeeSection(),
          ],
        ),
      ),
    );
  }
}
