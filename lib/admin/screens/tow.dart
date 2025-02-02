import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageTowStation extends StatefulWidget {
  @override
  _ManageTowStationState createState() => _ManageTowStationState();
}

class _ManageTowStationState extends State<ManageTowStation>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> towShops = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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

  // Accept the tow shop by updating the isApproved field
  Future<void> _acceptTowShop(String id) async {
    try {
      await FirebaseFirestore.instance.collection('tow').doc(id).update({
        'isApproved': true,
      });
      setState(() {
        int index = towShops.indexWhere((shop) => shop['id'] == id);
        if (index != -1) {
          towShops[index]['isApproved'] = true;
        }
      });
    } catch (e) {
      print('Error accepting tow shop: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Tow Stations'),
        backgroundColor: const Color.fromARGB(255, 131, 119, 149),
        centerTitle: true,
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Pending'),
            Tab(text: 'Accepted'),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTowShopList(context, false), // Pending tow shops
                    _buildTowShopList(context, true), // Accepted tow shops
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTowShopList(BuildContext context, bool isApproved) {
    List<Map<String, dynamic>> filteredShops =
        towShops.where((shop) => shop['isApproved'] == isApproved).toList();

    return filteredShops.isEmpty
        ? Center(child: Text('No tow shops available'))
        : ListView.builder(
            itemCount: filteredShops.length,
            itemBuilder: (context, index) {
              return _towShopCard(
                context,
                filteredShops[index],
                isApproved,
              );
            },
          );
  }

  // Tow Shop Card Widget
  Widget _towShopCard(
      BuildContext context, Map<String, dynamic> shop, bool isApproved) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ExpansionTile(
        leading: shop['companyLogo'] != null && shop['companyLogo'] != ''
            ? Image.network(
                shop['companyLogo'],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
            : Icon(Icons.local_car_wash, color: Colors.deepPurple),
        title: Text(
          shop['companyName'],
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.deepPurpleAccent),
        ),
        subtitle: Text(
          'Email: ${shop['email']}',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display Phone Number and Company License
                Text(
                  'Phone No: ${shop['phoneNo']}',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Company License: ${shop['companyLicense']}',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 15),

                Text(
                  'Employees:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurpleAccent),
                ),
                SizedBox(height: 8),
                shop['employees'] != null && shop['employees'].isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...shop['employees'].map<Widget>((employee) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ListTile(
                                title:
                                    Text(employee['employeeName'] ?? 'Unknown'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Email: ${employee['employeeEmail'] ?? 'N/A'}'),
                                    Text(
                                        'Phone: ${employee['employeePhoneNo'] ?? 'N/A'}'),
                                    Text(
                                        'Role: ${employee['employeeRole'] ?? 'N/A'}'),
                                  ],
                                ),
                                leading: Icon(Icons.person,
                                    color: Colors.deepPurple),
                              ),
                            );
                          }).toList(),
                        ],
                      )
                    : Text('No employees available'),

                if (!isApproved)
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => _acceptTowShop(shop['id']),
                      child: Text('Accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          )
        ],
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'Delete') {
              _confirmDeleteTowShop(context, shop['id']);
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(value: 'Delete', child: Text('Delete')),
            ];
          },
        ),
      ),
    );
  }

  // Confirmation dialog for tow shop deletion
  void _confirmDeleteTowShop(BuildContext context, String shopId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Tow Shop'),
          content: Text('Are you sure you want to delete this tow shop?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _deletetowShop(shopId);
                Navigator.pop(context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
