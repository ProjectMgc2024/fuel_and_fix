import 'package:flutter/material.dart';

class Employee {
  String name;
  String email;
  String phone;
  String role;
  String experience;
  String shiftTime;
  List<String> skills; // Skills related to repair tasks

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
  // Manager Information (editable)
  final Map<String, String> manager = {
    'name': 'John Doe',
    'email': 'john.doe@example.com',
    'phone': '123-456-7890',
    'workshopName': 'Super Repair Workshop',
  };

  // List of Employees working under the repair workshop
  List<Employee> employees = [
    Employee(
      name: 'Mechanic 1',
      email: 'mechanic1@example.com',
      phone: '987-654-3210',
      role: 'Senior Mechanic',
      experience: '5 years in engine repair',
      shiftTime: '8:00 AM - 4:00 PM',
      skills: ['Engine Repair', 'Brake System', 'Electrical Systems'],
    ),
    Employee(
      name: 'Mechanic 2',
      email: 'mechanic2@example.com',
      phone: '555-123-4567',
      role: 'Junior Mechanic',
      experience: '2 years in bodywork',
      shiftTime: '10:00 AM - 6:00 PM',
      skills: ['Bodywork', 'Paint Job', 'Dent Removal'],
    ),
  ];

  // Modal controllers for Edit Employee and Manager
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _shiftController = TextEditingController();
  final TextEditingController _workshopNameController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();

  // Track the employee or manager being edited
  dynamic _editingPerson;
  bool _isManager = false;

  // Open Edit Profile Modal (Manager's Profile)
  void _editProfile(dynamic person, {bool isManager = false}) {
    _editingPerson = person;
    _isManager = isManager;

    // Clear controllers before populating
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _roleController.clear();
    _experienceController.clear();
    _shiftController.clear();
    _workshopNameController.clear();
    _skillsController.clear();

    // Populate text controllers with current data
    if (isManager) {
      _nameController.text = person['name'];
      _emailController.text = person['email'];
      _phoneController.text = person['phone'];
      _workshopNameController.text = person['workshopName'];
    } else {
      _nameController.text = person.name;
      _emailController.text = person.email;
      _phoneController.text = person.phone;
      _roleController.text = person.role;
      _experienceController.text = person.experience;
      _shiftController.text = person.shiftTime;
      _skillsController.text = person.skills.join(', ');
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text(
            isManager ? 'Edit Manager Profile' : 'Edit Employee Profile',
            style: TextStyle(color: Colors.blueAccent),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
              ),
              if (!isManager)
                TextField(
                  controller: _roleController,
                  decoration: InputDecoration(labelText: 'Role'),
                ),
              if (!isManager)
                TextField(
                  controller: _shiftController,
                  decoration: InputDecoration(labelText: 'Shift Time'),
                ),
              if (!isManager)
                TextField(
                  controller: _skillsController,
                  decoration: InputDecoration(labelText: 'Skills'),
                ),
              if (isManager)
                TextField(
                  controller: _workshopNameController,
                  decoration: InputDecoration(labelText: 'Workshop Name'),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cancel editing
              },
              child: Text('Cancel', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  // Update manager data
                  if (isManager) {
                    manager['name'] = _nameController.text;
                    manager['email'] = _emailController.text;
                    manager['phone'] = _phoneController.text;
                    manager['workshopName'] = _workshopNameController.text;
                  } else {
                    // Update employee data
                    _editingPerson.name = _nameController.text;
                    _editingPerson.email = _emailController.text;
                    _editingPerson.phone = _phoneController.text;
                    _editingPerson.role = _roleController.text;
                    _editingPerson.shiftTime = _shiftController.text;
                    _editingPerson.skills = _skillsController.text.split(', ');
                    _editingPerson.experience = _experienceController.text;
                  }
                });
                Navigator.pop(context); // Save changes
              },
              child: Text('Save', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  // Delete Employee
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
              onPressed: () {
                Navigator.pop(context);
              },
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
        title: Text('Repair Workshop Profile'),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Manager Profile Section
            Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 5,
              child: ListTile(
                title: Text('Manager Profile',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Text(
                  'Name: ${manager['name']}\nEmail: ${manager['email']}\nPhone: ${manager['phone']}\nWorkshop: ${manager['workshopName']}',
                  style: TextStyle(fontSize: 16),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.edit,
                      color: const Color.fromARGB(255, 5, 28, 68)),
                  onPressed: () => _editProfile(manager, isManager: true),
                ),
              ),
            ),

            // Employees Section
            Text(
              'Employees',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 4, 86, 119)),
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
                    'Name: ${employees[i].name}\nEmail: ${employees[i].email}\nPhone: ${employees[i].phone}\nRole: ${employees[i].role}\nSkills: ${employees[i].skills.join(', ')}\nShift: ${employees[i].shiftTime}\nExperience: ${employees[i].experience}',
                    style: TextStyle(fontSize: 16),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit,
                            color: const Color.fromARGB(255, 4, 45, 79)),
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
