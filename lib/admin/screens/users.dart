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

  // ❌ Delete a user from Firestore and update the local list
  void _deleteUser(int index) async {
    String userId = filteredUsers[index]['id']; // Get the Firestore document ID
    try {
      await adminAuthServices.deleteUser(userId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _fetchUsers(); // Refresh the user list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete user: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Users'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔍 Search bar
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search Users',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // 📜 User List
            Expanded(
              child: filteredUsers.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> user = filteredUsers[index];
                        return Card(
                          elevation: 4,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(user['username']),
                            subtitle: Text(user['email']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
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
}
