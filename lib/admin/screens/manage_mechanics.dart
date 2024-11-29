import 'package:flutter/material.dart';

class MechanicPage extends StatefulWidget {
  @override
  _MechanicPageState createState() => _MechanicPageState();
}

class _MechanicPageState extends State<MechanicPage> {
  List<Map<String, String>> mechanics = [
    {
      'name': 'Mechanic 1',
      'email': 'mechanic1@example.com',
      'status': 'Available'
    },
    {
      'name': 'Mechanic 2',
      'email': 'mechanic2@example.com',
      'status': 'Unavailable'
    },
    // Add more mechanics as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Mechanics'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add Mechanic Button
              ElevatedButton.icon(
                onPressed: () {
                  _showAddMechanicDialog(context);
                },
                icon: Icon(Icons.add, color: Colors.white),
                label: Text('Add Mechanic'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  elevation: 5,
                ),
              ),
              SizedBox(height: 30),

              // Mechanic List Header
              Text(
                'List of Mechanics',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontFamily: 'Roboto',
                ),
              ),
              SizedBox(height: 15),

              // Mechanic List
              Expanded(
                child: ListView.builder(
                  itemCount: mechanics.length,
                  itemBuilder: (context, index) {
                    return _mechanicCard(
                      context,
                      mechanics[index]['name']!,
                      mechanics[index]['email']!,
                      mechanics[index]['status']!,
                      index,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Mechanic Card Widget
  Widget _mechanicCard(BuildContext context, String name, String email,
      String status, int index) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.deepPurple,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.deepPurpleAccent,
          ),
        ),
        subtitle: Text(
          email,
          style: TextStyle(color: Colors.black54),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'Edit') {
              _showEditMechanicDialog(context, name, email, index);
            } else if (value == 'Delete') {
              _confirmDeleteMechanic(context, name, index);
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(value: 'Edit', child: Text('Edit')),
              PopupMenuItem(value: 'Delete', child: Text('Delete')),
            ];
          },
        ),
      ),
    );
  }

  // Add Mechanic Dialog
  void _showAddMechanicDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _mechanicFormDialog(
          context,
          'Add Mechanic',
          onSubmit: (String name, String email) {
            setState(() {
              mechanics.add({
                'name': name,
                'email': email,
                'status': 'Available',
              });
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  // Edit Mechanic Dialog
  void _showEditMechanicDialog(
      BuildContext context, String name, String email, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _mechanicFormDialog(
          context,
          'Edit Mechanic',
          onSubmit: (String updatedName, String updatedEmail) {
            setState(() {
              mechanics[index] = {
                'name': updatedName,
                'email': updatedEmail,
                'status': mechanics[index]['status']!,
              };
            });
            Navigator.pop(context);
          },
          initialName: name,
          initialEmail: email,
        );
      },
    );
  }

  // Confirm Delete Mechanic
  void _confirmDeleteMechanic(BuildContext context, String name, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: Text(
            'Delete Mechanic',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete $name?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: TextStyle(color: Colors.deepPurpleAccent)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  mechanics.removeAt(index);
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

  // Mechanic Form Dialog (Add/Edit)
  Widget _mechanicFormDialog(
    BuildContext context,
    String title, {
    required Function(String name, String email) onSubmit,
    String? initialName,
    String? initialEmail,
  }) {
    final _nameController = TextEditingController(text: initialName ?? '');
    final _emailController = TextEditingController(text: initialEmail ?? '');
    final _emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'); // Email regex pattern
    bool _isEmailValid = true;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.deepPurpleAccent,
          fontSize: 22,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              labelStyle: TextStyle(color: Colors.deepPurpleAccent),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          SizedBox(height: 15),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(color: Colors.deepPurpleAccent),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              errorText: !_isEmailValid && _emailController.text.isNotEmpty
                  ? 'Please enter a valid email'
                  : null,
            ),
            onChanged: (text) {
              setState(() {
                // Check if the entered text is a valid email
                _isEmailValid = _emailRegex.hasMatch(text);
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child:
              Text('Cancel', style: TextStyle(color: Colors.deepPurpleAccent)),
        ),
        ElevatedButton(
          onPressed: () {
            String name = _nameController.text.trim();
            String email = _emailController.text.trim();
            if (name.isNotEmpty && email.isNotEmpty) {
              if (_isEmailValid) {
                onSubmit(name, email);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a valid email')),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please fill in both fields')),
              );
            }
          },
          child: Text('Save'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ],
    );
  }
}
