import 'package:flutter/material.dart';
import 'package:fuel_and_fix/admin/services/firebase_admin_auth.dart';

class ManageUser extends StatefulWidget {
  @override
  _ManageUsersPageState createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUser> {
  List<Map<String, dynamic>> users =
      []; // List to store user data from Firestore
  List<Map<String, dynamic>> filteredUsers = [];
  TextEditingController searchController = TextEditingController();
  AdminAuthServices adminAuthServices = AdminAuthServices();

  @override
  void initState() {
    super.initState();
    _fetchUsers(); // Fetch users from Firestore on init
    searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // 🔥 Fetch users from Firestore
  void _fetchUsers() async {
    List<Map<String, dynamic>> fetchedUsers =
        await adminAuthServices.fetchAllUsers();
    setState(() {
      users = fetchedUsers;
      filteredUsers = users; // Initialize filtered list with full users list
    });
  }

  // 🔍 Filter users based on the search query
  void _filterUsers() {
    setState(() {
      filteredUsers = users
          .where((user) => user['username']
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  // ❌ Show confirmation dialog before deleting a user
  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this user?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteUser(index); // Proceed to delete
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // ❌ Delete a user from Firestore and update the local list
  void _deleteUser(int index) async {
    String userId = filteredUsers[index]['id']; // Get the Firestore document ID
    try {
      await adminAuthServices.deleteUser(userId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User deleted successfully'),
          backgroundColor: Colors.greenAccent,
          duration: Duration(seconds: 2),
        ),
      );
      _fetchUsers(); // Refresh the user list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete user: $e'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Users'),
        backgroundColor: const Color.fromARGB(255, 103, 179, 189),
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔍 Stylish Search Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(blurRadius: 10, color: Colors.grey)],
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search by Username...',
                  prefixIcon: Icon(Icons.search, color: Colors.teal),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            // 📜 User List with Stylish Cards
            Expanded(
              child: filteredUsers.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> user = filteredUsers[index];
                        return Card(
                          elevation: 5,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            title: Text(
                              user['username'],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            subtitle: Text(
                              user['email'],
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            trailing: IconButton(
                              icon:
                                  Icon(Icons.delete_forever, color: Colors.red),
                              onPressed: () => _showDeleteConfirmation(index),
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
}
