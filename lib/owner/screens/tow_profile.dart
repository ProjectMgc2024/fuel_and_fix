import 'package:flutter/material.dart';

// Tow Service Person class to represent each person's details
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
  // Sample Manager information
  final Map<String, String> manager = {
    'name': 'Jane Doe',
    'email': 'jane.doe@example.com',
    'phone': '321-654-9870',
    'companyName': 'Reliable Tow Services',
  };

  // List of Tow Service People (drivers, dispatchers, etc.)
  List<TowServicePerson> people = [
    TowServicePerson(
      name: 'Tow Driver 1',
      email: 'driver1@example.com',
      phone: '555-555-1111',
      role: 'Senior Tow Driver',
      experience: '7 years in towing',
      shiftTime: '7:00 AM - 3:00 PM',
    ),
    TowServicePerson(
      name: 'Dispatcher 1',
      email: 'dispatcher1@example.com',
      phone: '555-555-3333',
      role: 'Lead Dispatcher',
      experience: '5 years in dispatching',
      shiftTime: '9:00 AM - 5:00 PM',
    ),
    TowServicePerson(
      name: 'Tow Driver 2',
      email: 'driver2@example.com',
      phone: '555-555-2222',
      role: 'Junior Tow Driver',
      experience: '3 years in towing',
      shiftTime: '9:00 AM - 5:00 PM',
    ),
  ];

  // Controllers for the profile edit modal
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _shiftController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();

  // Track the person being edited
  dynamic _editingPerson;
  bool _isManager = false;

  // Open the edit modal for a manager or tow service person
  void _editProfile(dynamic person, {bool isManager = false}) {
    _editingPerson = person;
    _isManager = isManager;

    // Clear text controllers before populating them with the current data
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _roleController.clear();
    _experienceController.clear();
    _shiftController.clear();
    _companyNameController.clear();

    // Populate the text controllers with current values
    if (isManager) {
      _nameController.text = person['name'];
      _emailController.text = person['email'];
      _phoneController.text = person['phone'];
      _companyNameController.text = person['companyName'];
    } else {
      _nameController.text = person.name;
      _emailController.text = person.email;
      _phoneController.text = person.phone;
      _roleController.text = person.role;
      _experienceController.text = person.experience;
      _shiftController.text = person.shiftTime;
    }

    // Show the edit dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text(
            isManager ? 'Edit Manager Profile' : 'Edit Tow Service Profile',
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
                  controller: _experienceController,
                  decoration: InputDecoration(labelText: 'Experience'),
                ),
              if (!isManager)
                TextField(
                  controller: _shiftController,
                  decoration: InputDecoration(labelText: 'Shift Time'),
                ),
              if (isManager)
                TextField(
                  controller: _companyNameController,
                  decoration: InputDecoration(labelText: 'Company Name'),
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
                  // Save the updated information
                  if (isManager) {
                    manager['name'] = _nameController.text;
                    manager['email'] = _emailController.text;
                    manager['phone'] = _phoneController.text;
                    manager['companyName'] = _companyNameController.text;
                  } else {
                    _editingPerson.name = _nameController.text;
                    _editingPerson.email = _emailController.text;
                    _editingPerson.phone = _phoneController.text;
                    _editingPerson.role = _roleController.text;
                    _editingPerson.experience = _experienceController.text;
                    _editingPerson.shiftTime = _shiftController.text;
                  }
                });
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Save', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  // Delete a Tow Service Person
  void _deletePerson(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text('Delete Person', style: TextStyle(color: Colors.red)),
          content: Text('Are you sure you want to delete this person?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cancel deletion
              },
              child: Text('Cancel', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  people.removeAt(index); // Remove the person
                });
                Navigator.pop(context); // Close the dialog
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
        title: Text('Tow Service Profiles'),
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
                  'Name: ${manager['name']}\nEmail: ${manager['email']}\nPhone: ${manager['phone']}\nCompany: ${manager['companyName']}',
                  style: TextStyle(fontSize: 16),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editProfile(manager, isManager: true),
                ),
              ),
            ),

            // Tow Service People Section
            Text(
              'Tow Service People',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 2, 52, 73)),
            ),
            for (int i = 0; i < people.length; i++) ...[
              Card(
                margin: EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 5,
                child: ListTile(
                  title: Text(people[i].name,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'Role: ${people[i].role}\nEmail: ${people[i].email}\nPhone: ${people[i].phone}\nExperience: ${people[i].experience}\nShift: ${people[i].shiftTime}',
                    style: TextStyle(fontSize: 16),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editProfile(people[i]),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deletePerson(i),
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
