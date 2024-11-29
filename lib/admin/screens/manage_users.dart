import 'package:flutter/material.dart';

class ManageUser extends StatefulWidget {
  @override
  _ManageUsersPageState createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUser> {
  List<String> users = ["John Doe", "Jane Smith", "Alice Brown", "Bob White"];
  TextEditingController searchController = TextEditingController();

  // Add a new user (for demonstration purposes)
  void _addUser(String user) {
    setState(() {
      users.add(user);
    });
  }

  // Delete a user (for demonstration purposes)
  void _deleteUser(int index) {
    setState(() {
      users.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Users'),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showAddUserDialog();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search Users',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                setState(() {});
              },
            ),
            SizedBox(height: 20),
            // User List
            Expanded(
              child: ListView.builder(
                itemCount: users
                    .where((user) => user
                        .toLowerCase()
                        .contains(searchController.text.toLowerCase()))
                    .toList()
                    .length,
                itemBuilder: (context, index) {
                  String user = users
                      .where((user) => user
                          .toLowerCase()
                          .contains(searchController.text.toLowerCase()))
                      .toList()[index];
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(user),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _showEditUserDialog(user);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteUser(index);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show Add User dialog
  void _showAddUserDialog() {
    TextEditingController userController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New User'),
          content: TextField(
            controller: userController,
            decoration: InputDecoration(labelText: 'Enter User Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (userController.text.isNotEmpty) {
                  _addUser(userController.text);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Show Edit User dialog
  void _showEditUserDialog(String currentUser) {
    TextEditingController userController =
        TextEditingController(text: currentUser);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit User'),
          content: TextField(
            controller: userController,
            decoration: InputDecoration(labelText: 'Edit User Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (userController.text.isNotEmpty) {
                  setState(() {
                    users[users.indexOf(currentUser)] = userController.text;
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
