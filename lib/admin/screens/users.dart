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

  // 🔄 Toggle user status between enabled and disabled
  void _toggleUserStatus(int index) async {
    String userId = filteredUsers[index]['id']; // Get the Firestore document ID
    bool isDisabled = filteredUsers[index]['disabled'] ?? false;
    try {
      await adminAuthServices.updateUserStatus(
          userId, !isDisabled); // Toggle status
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User status updated successfully'),
          backgroundColor: Colors.greenAccent,
          duration: Duration(seconds: 2),
        ),
      );
      _fetchUsers(); // Refresh the user list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update user status: $e'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // 📑 View user details in a new screen (Updated: Removed location and image)
  void _viewUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('User Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Username: ${user['username']}'),
                Text('Email: ${user['email']}'),
                Text('Phone: ${user['phoneno']}'),
                Text('License: ${user['license']}'),
                Text('Registration No: ${user['registrationNo']}'),
                Text('Vehicle Type: ${user['vehicleType']}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Close'),
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
                            leading: CircleAvatar(
                              radius:
                                  30, // Adjust the radius as per your design
                              backgroundImage: NetworkImage(user['userImage']),
                              backgroundColor: Colors.transparent,
                            ),
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
                              icon: Icon(
                                user['disabled'] == true
                                    ? Icons.lock
                                    : Icons.lock_open,
                                color: Colors.orange,
                              ),
                              onPressed: () => _toggleUserStatus(index),
                            ),
                            onTap: () =>
                                _viewUserDetails(user), // View details on tap
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
