import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FuelProfilePage extends StatefulWidget {
  @override
  _FuelProfilePageState createState() => _FuelProfilePageState();
}

class _FuelProfilePageState extends State<FuelProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _employees = [];

  // Fetch user and employee details
  Future<void> _fetchEmployeeDetails() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('fuel').doc(user.uid).get();
      var userData = userDoc.data() as Map<String, dynamic>;
      setState(() {
        _employees =
            List<Map<String, dynamic>>.from(userData['employees'] ?? []);
      });
    }
  }

  // Show edit dialog for employee details
  void _showEditDialog(
      BuildContext context, int index, Map<String, dynamic> employeeDetails) {
    final _nameController =
        TextEditingController(text: employeeDetails['name']);
    final _phoneController =
        TextEditingController(text: employeeDetails['phoneNo']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Employee Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Employee Name')),
              TextField(
                  controller: _phoneController,
                  decoration:
                      InputDecoration(labelText: 'Employee Phone Number'),
                  keyboardType: TextInputType.phone),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                String name = _nameController.text.trim();
                String phoneNo = _phoneController.text.trim();
                if (name.isNotEmpty && phoneNo.isNotEmpty) {
                  try {
                    String userId = _auth.currentUser!.uid;
                    List<Map<String, dynamic>> updatedEmployees =
                        List.from(_employees);
                    updatedEmployees[index] = {
                      'name': name,
                      'phoneNo': phoneNo
                    };

                    await _firestore.collection('fuel').doc(userId).update({
                      'employees': updatedEmployees,
                    });
                    setState(() {
                      _employees[index] = {'name': name, 'phoneNo': phoneNo};
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Employee details updated")));
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error updating employee: $e")));
                  }
                }
              },
              child: Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  // Delete employee
  void _deleteEmployee(int index) async {
    try {
      String userId = _auth.currentUser!.uid;
      List<Map<String, dynamic>> updatedEmployees = List.from(_employees);
      updatedEmployees.removeAt(index);

      await _firestore.collection('fuel').doc(userId).update({
        'employees': updatedEmployees,
      });

      setState(() {
        _employees.removeAt(index);
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Employee deleted")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error deleting employee: $e")));
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchEmployeeDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fuel Service Profile"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<DocumentSnapshot>(
          future:
              _firestore.collection('fuel').doc(_auth.currentUser!.uid).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('No user data found.'));
            }

            var userData = snapshot.data!.data() as Map<String, dynamic>;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 4,
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildProfileRow("Owner", userData['owner'] ?? "N/A"),
                        _buildProfileRow("Phone", userData['phoneNo'] ?? "N/A"),
                        _buildProfileRow(
                            "License", userData['clicense'] ?? "N/A"),
                        _buildProfileRow(
                            "Company", userData['companyName'] ?? "N/A"),
                        _buildProfileRow("Email", userData['email'] ?? "N/A"),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text("Employees:",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.deepOrangeAccent)),
                SizedBox(height: 10),
                _employees.isEmpty
                    ? Center(child: Text('No employees found.'))
                    : Column(
                        children: List.generate(_employees.length, (index) {
                          var employee = _employees[index];
                          return Card(
                            elevation: 4,
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            color: Colors.teal[50],
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Text("${employee['name']}: ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Expanded(
                                      child: Text(
                                          "Phone: ${employee['phoneNo']}",
                                          style: TextStyle(fontSize: 16))),
                                  IconButton(
                                      icon: Icon(Icons.edit,
                                          color: Colors.orange),
                                      onPressed: () => _showEditDialog(
                                          context, index, employee)),
                                  IconButton(
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteEmployee(index)),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddEmployeePage(
                                userId: _auth.currentUser!.uid)));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrangeAccent),
                  child: Text("Add Employee", style: TextStyle(fontSize: 18)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Profile row widget
  Widget _buildProfileRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text("$title: ",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.deepOrangeAccent)),
          Expanded(child: Text(value, style: TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}

// Add Employee Page
class AddEmployeePage extends StatefulWidget {
  final String userId;

  AddEmployeePage({required this.userId});

  @override
  _AddEmployeePageState createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  Future<void> _addEmployee() async {
    String name = _nameController.text.trim();
    String phoneNo = _phoneController.text.trim();

    if (name.isNotEmpty && phoneNo.isNotEmpty) {
      try {
        DocumentReference userDocRef =
            FirebaseFirestore.instance.collection('fuel').doc(widget.userId);
        List<Map<String, dynamic>> updatedEmployees = List.from([]);

        updatedEmployees.add({'name': name, 'phoneNo': phoneNo});

        await userDocRef.update({
          'employees': updatedEmployees,
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Employee added")));
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error adding employee: $e")));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please fill out all fields")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Add Employee"),
          backgroundColor: Colors.deepOrangeAccent),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Employee Name')),
            TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Employee Phone Number'),
                keyboardType: TextInputType.phone),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: _addEmployee,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text("Add Employee")),
          ],
        ),
      ),
    );
  }
}
