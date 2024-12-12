import 'package:flutter/material.dart';

class Employee {
  String name;
  String email;
  String phone;
  String role;
  String experience;
  String shiftTime;

  Employee({
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.experience,
    required this.shiftTime,
  });
}

class FuelProfilePage extends StatefulWidget {
  @override
  _FuelProfilePageState createState() => _FuelProfilePageState();
}

class _FuelProfilePageState extends State<FuelProfilePage> {
  final Map<String, String> manager = {
    'name': 'Jane Smith',
    'email': 'jane.smith@example.com',
    'phone': '123-456-7890',
    'stationName': 'SuperFuel Station',
  };

  List<Employee> employees = [
    Employee(
      name: 'Employee 1',
      email: 'employee1@example.com',
      phone: '987-654-3210',
      role: 'Fuel Attendant',
      experience: '2 years in fuel station',
      shiftTime: '6:00 AM - 2:00 PM',
    ),
    Employee(
      name: 'Employee 2',
      email: 'employee2@example.com',
      phone: '555-123-4567',
      role: 'Cashier',
      experience: '1 year in cashier role',
      shiftTime: '2:00 PM - 10:00 PM',
    ),
  ];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _shiftController = TextEditingController();
  final TextEditingController _stationNameController = TextEditingController();

  dynamic _editingPerson;
  bool _isManager = false;

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

  void _clearControllers() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _roleController.clear();
    _experienceController.clear();
    _shiftController.clear();
    _stationNameController.clear();
  }

  void _populateControllers(bool isManager) {
    if (isManager) {
      _nameController.text = manager['name']!;
      _emailController.text = manager['email']!;
      _phoneController.text = manager['phone']!;
      _stationNameController.text = manager['stationName']!;
    } else {
      _nameController.text = _editingPerson.name;
      _emailController.text = _editingPerson.email;
      _phoneController.text = _editingPerson.phone;
      _roleController.text = _editingPerson.role;
      _experienceController.text = _editingPerson.experience;
      _shiftController.text = _editingPerson.shiftTime;
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
          if (!isManager) ...[
            _buildTextField(_roleController, 'Role'),
            _buildTextField(_shiftController, 'Shift Time'),
          ],
          if (isManager) ...[
            _buildTextField(_stationNameController, 'Station Name'),
          ]
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
        onPressed: () {
          setState(() {
            if (_isManager) {
              manager['name'] = _nameController.text;
              manager['email'] = _emailController.text;
              manager['phone'] = _phoneController.text;
              manager['stationName'] = _stationNameController.text;
            } else {
              _editingPerson.name = _nameController.text;
              _editingPerson.email = _emailController.text;
              _editingPerson.phone = _phoneController.text;
              _editingPerson.role = _roleController.text;
              _editingPerson.shiftTime = _shiftController.text;
              _editingPerson.experience = _experienceController.text;
            }
          });
          Navigator.pop(context);
        },
        child: Text('Save', style: TextStyle(color: Colors.teal)),
      ),
    ];
  }

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
              onPressed: () {
                setState(() {
                  employees.removeAt(index);
                });
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
        title: Text('Fuel Station Profile'),
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
          'Name: ${manager['name']}\nEmail: ${manager['email']}\nPhone: ${manager['phone']}\nFuel Station: ${manager['stationName']}',
          style: TextStyle(fontSize: 16),
        ),
        trailing: IconButton(
          icon: Icon(Icons.edit, color: Colors.teal),
          onPressed: () => _editProfile(manager, isManager: true),
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
          'Role: ${employee.role}\nExperience: ${employee.experience}\nShift: ${employee.shiftTime}',
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
