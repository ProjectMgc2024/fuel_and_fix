import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageTowStation extends StatefulWidget {
  @override
  _ManageTowStationState createState() => _ManageTowStationState();
}

class _ManageTowStationState extends State<ManageTowStation> {
  List<Map<String, dynamic>> towShops = [];

  @override
  void initState() {
    super.initState();
    _fetchtowShops(); // Fetch the tow shops when the page is loaded
  }

  Future<void> _fetchtowShops() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('tow').get();
      List<Map<String, dynamic>> towList = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
      setState(() {
        towShops = towList;
      });
    } catch (e) {
      print('Error fetching tow stations: $e');
    }
  }

  // Delete the tow shop from Firestore
  Future<void> _deletetowShop(String id) async {
    try {
      await FirebaseFirestore.instance.collection('tow').doc(id).delete();
      setState(() {
        towShops.removeWhere((shop) => shop['id'] == id);
      });
    } catch (e) {
      print('Error deleting tow shop: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Tow stations'),
        backgroundColor: const Color.fromARGB(255, 131, 119, 149),
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
              // Tow Shops List Header
              Text(
                'List of Tow Stations',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontFamily: 'Roboto',
                ),
              ),
              SizedBox(height: 15),

              // Tow Shops List
              Expanded(
                child: towShops.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: towShops.length,
                        itemBuilder: (context, index) {
                          return towShopCard(
                            context,
                            towShops[index]['companyName'] ?? 'Unknown',
                            towShops[index]['email'] ?? 'Unknown',
                            towShops[index]['phoneNo'] ?? 'Unknown',
                            towShops[index]['status'] ?? false,
                            towShops[index]['employees'] ?? [],
                            towShops[index]['id'], // Passing the id
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

  // Tow Shop Card Widget
  Widget towShopCard(BuildContext context, String companyName, String email,
      String phoneNo, bool status, List employees, String id) {
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
          backgroundImage: NetworkImage(
              towShops.isNotEmpty ? towShops[0]['companyLogo'] ?? '' : ''),
        ),
        title: Text(
          companyName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.deepPurpleAccent,
          ),
        ),
        subtitle: Text(
          'Email: $email\nPhone: $phoneNo\nStatus: ${status ? 'Active' : 'Inactive'}',
          style: TextStyle(color: Colors.black54),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.deepPurple),
              onPressed: () {
                // Navigate to the Edit Page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EdittowShopPage(
                      towShopId: id,
                      companyName: companyName,
                      email: email,
                      phoneNo: phoneNo,
                      status: status,
                      employees: employees,
                    ),
                  ),
                ).then((updatedShop) {
                  if (updatedShop != null) {
                    setState(() {
                      // Update the list with the new data
                      int index =
                          towShops.indexWhere((shop) => shop['id'] == id);
                      if (index != -1) {
                        towShops[index] = updatedShop;
                      }
                    });
                  }
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // Confirm deletion
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Delete Tow Shop'),
                      content: Text(
                          'Are you sure you want to delete this tow shop?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            _deletetowShop(id); // Delete the tow shop
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: Text('Delete'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
        onTap: () {
          // Navigate to Tow Shop Detail Page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EdittowShopPage(
                companyName: companyName,
                email: email,
                phoneNo: phoneNo,
                status: status,
                employees: employees,
                towShopId: '',
              ),
            ),
          );
        },
      ),
    );
  }
}

class EdittowShopPage extends StatefulWidget {
  final String towShopId;
  final String companyName;
  final String email;
  final String phoneNo;
  final bool status;
  final List employees;

  const EdittowShopPage({
    required this.towShopId,
    required this.companyName,
    required this.email,
    required this.phoneNo,
    required this.status,
    required this.employees,
  });

  @override
  _EdittowShopPageState createState() => _EdittowShopPageState();
}

class _EdittowShopPageState extends State<EdittowShopPage> {
  late TextEditingController _companyNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNoController;

  bool _status = false;

  @override
  void initState() {
    super.initState();
    _companyNameController = TextEditingController(text: widget.companyName);
    _emailController = TextEditingController(text: widget.email);
    _phoneNoController = TextEditingController(text: widget.phoneNo);
    _status = widget.status;
  }

  // Update tow shop details in Firestore
  Future<void> _updateTowShop() async {
    try {
      await FirebaseFirestore.instance
          .collection('tow')
          .doc(widget.towShopId)
          .update({
        'companyName': _companyNameController.text,
        'email': _emailController.text,
        'phoneNo': _phoneNoController.text,
        'status': _status,
      });

      // After updating, pass the updated data back to the previous screen
      Navigator.pop(context, {
        'id': widget.towShopId,
        'companyName': _companyNameController.text,
        'email': _emailController.text,
        'phoneNo': _phoneNoController.text,
        'status': _status,
        'employees': widget.employees,
      });
    } catch (e) {
      print('Error updating tow shop: $e');
    }
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _emailController.dispose();
    _phoneNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Tow Shop'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text field for Company Name
            TextField(
              controller: _companyNameController,
              decoration: InputDecoration(labelText: 'Company Name'),
            ),
            SizedBox(height: 15),

            // Text field for Email
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 15),

            // Text field for Phone Number
            TextField(
              controller: _phoneNoController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            SizedBox(height: 15),

            // Toggle Switch for Status
            Row(
              children: [
                Text('Status:'),
                Switch(
                  value: _status,
                  onChanged: (value) {
                    setState(() {
                      _status = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 15),

            // Save Button to update data in Firestore
            ElevatedButton(
              onPressed: _updateTowShop,
              child: Text('Save Changes'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
